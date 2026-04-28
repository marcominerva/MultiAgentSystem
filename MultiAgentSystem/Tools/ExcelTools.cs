using System.ComponentModel;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;
using ClosedXML.Excel;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Converters;
using MultiAgentSystem.Extensions;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Tools;

public sealed class ExcelTools(AgentArtifactStore artifactStore, IContentStore contentStore)
{
    [Description("""
        Generates an Excel file (.xlsx).
        If a contentId is provided, the tool reads tabular data or JSON object lists directly from the store - nothing is truncated. Provide columns and optional rules to control layout and conditional formatting.
        Text content is not supported for Excel export.
        If no contentId is provided, provide headers and rows with the data to include.
        """)]
    public async Task<string> GenerateExcelAsync(
        [Description("The file name without extension.")] string fileName,
        [Description("The name of the worksheet.")] string sheetName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The Content ID of previously stored tabular data or JSON object lists. When provided, the tool reads data from the store and 'headers'/'rows' are ignored.")] string? contentId = null,
        [Description("Column definitions for content-based export: which fields to include, display headers, unconditional styles. Required when contentId is provided.")] RenderColumn[]? columns = null,
        [Description("Optional cell-level formatting rules for content-based export (e.g., highlight prices > 100 in red). Used only when contentId is provided for table or list content.")] CellRule[]? rules = null,
        [Description("Optional row-level styling rules (e.g., alternating row colors with 'odd'/'even', or every N-th row). Applied to all cells in matching rows with lower priority than cell-level styles. Used only when contentId is provided for table or list content.")] RowRule[]? rowRules = null,
        [Description("Column headers. Used only when no contentId is provided.")] ExcelCell[]? headers = null,
        [Description("Data rows. Used only when no contentId is provided.")] ExcelRow[]? rows = null)
    {
        using var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add(string.IsNullOrWhiteSpace(sheetName) ? "Sheet1" : sheetName);

        if (!string.IsNullOrWhiteSpace(contentId))
        {
            await GenerateFromContentTableAsync(worksheet, contentId, columns ?? [], rules, rowRules);
        }
        else
        {
            GenerateFromProvidedData(worksheet, headers ?? [], rows ?? []);
        }

        worksheet.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);

        artifactStore.Add(new($"{fileName}.xlsx", stream.ToArray()));

        return description;
    }

    private async Task GenerateFromContentTableAsync(IXLWorksheet worksheet, string contentId, RenderColumn[] columns, CellRule[]? cellRules, RowRule[]? rowRules)
    {
        var stored = await contentStore.GetAsync(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        if (stored.ContentType is not ContentTypes.Table and not ContentTypes.List)
        {
            throw new NotSupportedException($"Excel export is only supported for tabular data and JSON object lists. The content with ID '{contentId}' has type '{stored.ContentType}'.");
        }

        using var doc = JsonDocument.Parse((string)stored.Data);
        columns = ColumnResolver.Resolve(doc.RootElement, columns);

        for (var col = 0; col < columns.Length; col++)
        {
            var column = columns[col];
            var cell = worksheet.Cell(1, col + 1);
            cell.Value = column.Header ?? column.Field;
            cell.Style.Font.Bold = true;

            if (column.Style?.Align is { } headerAlign)
            {
                cell.Style.Alignment.Horizontal = ParseAlignment(headerAlign);
            }
        }

        var rowIndex = 2;
        foreach (var item in doc.RootElement.EnumerateArray())
        {
            var dataRowNumber = rowIndex - 1; // 1-based data row number

            for (var col = 0; col < columns.Length; col++)
            {
                var column = columns[col];
                var cell = worksheet.Cell(rowIndex, col + 1);

                if (item.TryGetPropertyIgnoreCase(column.Field, out var prop))
                {
                    SetCellValueFromJson(cell, prop, column.Type);
                }

                var effectiveStyle = ResolveStyle(item, column, cellRules);
                ApplyCellStyleFromSpec(cell, effectiveStyle);

                // Column-level format is the default; conditional/style-level format takes precedence.
                if (!string.IsNullOrWhiteSpace(column.Format) && string.IsNullOrWhiteSpace(effectiveStyle.Format))
                {
                    cell.Style.NumberFormat.Format = column.Format;
                }
            }

            ApplyRowRules(worksheet, rowIndex, columns.Length, dataRowNumber, rowRules);

            rowIndex++;
        }
    }

    private static void GenerateFromProvidedData(IXLWorksheet worksheet, ExcelCell[] headers, ExcelRow[] rows)
    {
        for (var col = 0; col < headers.Length; col++)
        {
            var headerCell = headers[col];
            var cell = worksheet.Cell(1, col + 1);
            cell.Value = NormalizeValue(headerCell.Value);
            ApplyFormatting(cell, headerCell, isHeader: true);
        }

        for (var row = 0; row < rows.Length; row++)
        {
            var excelRow = rows[row];
            var dataCells = excelRow.Cells;
            var worksheetRow = row + 2;
            var dataRowNumber = row + 1; // 1-based data row number

            for (var col = 0; col < dataCells.Length; col++)
            {
                var dataCell = dataCells[col];
                var cell = worksheet.Cell(worksheetRow, col + 1);
                SetTypedCellValue(cell, dataCell);
                ApplyFormatting(cell, dataCell);

                // Row-level background color applies to all cells unless the cell has its own.
                if (dataCell.BackgroundColor is null && excelRow.BackgroundColor is { } rowBg && !IsDefaultWhite(rowBg))
                {
                    ApplyColor(rowBg, color =>
                    {
                        cell.Style.Fill.BackgroundColor = color;
                        cell.Style.Fill.PatternType = XLFillPatternValues.Solid;
                    });
                }
            }
        }
    }

    private static CellStyle ResolveStyle(JsonElement row, RenderColumn column, CellRule[]? rules)
    {
        var style = column.Style;

        if (rules is not null)
        {
            foreach (var rule in rules)
            {
                if (!string.Equals(rule.Column, column.Field, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (row.TryGetPropertyIgnoreCase(rule.Column, out var evalProp) && ConditionEvaluator.Evaluate(evalProp, rule))
                {
                    style = ConditionEvaluator.MergeStyles(style, rule.Style);
                }
            }
        }

        return style ?? new();
    }

    private static bool IsRowRuleMatch(RowRule rule, int dataRowNumber) => rule.Condition.ToLowerInvariant() switch
    {
        "odd" => dataRowNumber % 2 != 0,
        "even" => dataRowNumber % 2 == 0,
        "every" => rule.Interval is > 0 && dataRowNumber % rule.Interval == 0,
        _ => false
    };

    private static void ApplyRowRules(IXLWorksheet worksheet, int worksheetRow, int columnCount, int dataRowNumber, RowRule[]? rowRules)
    {
        if (rowRules is null)
        {
            return;
        }

        foreach (var rule in rowRules)
        {
            if (!IsRowRuleMatch(rule, dataRowNumber))
            {
                continue;
            }

            for (var c = 1; c <= columnCount; c++)
            {
                var cell = worksheet.Cell(worksheetRow, c);
                // Row rules have lowest priority: skip cells that already have explicit styling.
                if (cell.Style.Fill.PatternType is not XLFillPatternValues.Solid)
                {
                    ApplyCellStyleFromSpec(cell, rule.Style);
                }
            }
        }
    }

    private static void SetCellValueFromJson(IXLCell cell, JsonElement element, string? type = null)
    {
        var normalizedType = type?.ToLowerInvariant();

        switch (element.ValueKind)
        {
            case JsonValueKind.Number:
                cell.Value = element.GetDouble();
                cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                break;

            case JsonValueKind.True:
                cell.Value = true;
                break;

            case JsonValueKind.False:
                cell.Value = false;
                break;

            case JsonValueKind.String:
                SetCellValueFromString(cell, element.GetString(), normalizedType);
                break;

            default:
                cell.Value = Blank.Value;
                break;
        }
    }

    private static void SetCellValueFromString(IXLCell cell, string? str, string? type)
    {
        switch (type)
        {
            case "number" or "currency" or "percentage" when double.TryParse(str, CultureInfo.InvariantCulture, out var num):
                cell.Value = num;
                cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                return;

            case "date" when DateTime.TryParse(str, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date):
                cell.Value = date;
                cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                return;

            case "time" when TimeSpan.TryParse(str, CultureInfo.InvariantCulture, out var time):
                cell.Value = time;
                cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                return;

            case "boolean" when bool.TryParse(str, out var boolean):
                cell.Value = boolean;
                return;
        }

        // No explicit type - infer from value content.
        if (DateTime.TryParse(str, CultureInfo.InvariantCulture, DateTimeStyles.None, out var inferredDate))
        {
            cell.Value = inferredDate;
            cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
        }
        else if (double.TryParse(str, CultureInfo.InvariantCulture, out var inferredNum))
        {
            cell.Value = inferredNum;
            cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
        }
        else
        {
            cell.Value = str;
        }
    }

    private static void ApplyCellStyleFromSpec(IXLCell cell, CellStyle style)
    {
        if (style.Bold)
        {
            cell.Style.Font.Bold = true;
        }

        if (style.Italic)
        {
            cell.Style.Font.Italic = true;
        }

        if (style.Underline)
        {
            cell.Style.Font.Underline = XLFontUnderlineValues.Single;
        }

        if (style.Size is { } size)
        {
            cell.Style.Font.FontSize = size;
        }

        if (style.ForegroundColor is { } fg)
        {
            ApplyColor(fg, color => cell.Style.Font.FontColor = color);
        }

        if (style.BackgroundColor is { } bg && !IsDefaultWhite(bg))
        {
            ApplyColor(bg, color =>
            {
                cell.Style.Fill.BackgroundColor = color;
                cell.Style.Fill.PatternType = XLFillPatternValues.Solid;
            });
        }

        if (style.Align is { } align)
        {
            cell.Style.Alignment.Horizontal = ParseAlignment(align);
        }

        if (!string.IsNullOrWhiteSpace(style.Format))
        {
            cell.Style.NumberFormat.Format = style.Format;
        }
    }

    private static XLAlignmentHorizontalValues ParseAlignment(string align) => align.ToLowerInvariant() switch
    {
        "left" => XLAlignmentHorizontalValues.Left,
        "center" => XLAlignmentHorizontalValues.Center,
        "right" => XLAlignmentHorizontalValues.Right,
        _ => XLAlignmentHorizontalValues.General
    };

    private static void SetTypedCellValue(IXLCell cell, ExcelCell excelCell)
    {
        var value = NormalizeValue(excelCell.Value);

        // If no type is defined, tries to infer it from the value content.
        // This allows for correct Excel formatting and alignment of numbers, dates, and booleans even when the type is not explicitly provided.
        var dataType = excelCell.Type?.ToLowerInvariant() ?? InferDataType(value);

        cell.Value = dataType switch
        {
            "number" or "currency" or "percentage" when double.TryParse(value, CultureInfo.InvariantCulture, out var number) => number,
            "date" when DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date) => date,
            "time" when TimeSpan.TryParse(value, CultureInfo.InvariantCulture, out var time) => time,
            "boolean" when bool.TryParse(value, out var boolean) => boolean,
            _ => value
        };

        if (dataType is "number" or "currency" or "percentage" or "date" or "time" && excelCell.Align is null)
        {
            // Sets the default alignment for numbers and date.
            cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
        }
    }

    private static string InferDataType(string? value) => value switch
    {
        _ when double.TryParse(value, CultureInfo.InvariantCulture, out _) => "number",
        _ when TimeSpan.TryParse(value, CultureInfo.InvariantCulture, out _) => "time",
        _ when DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out _) => "date",
        _ when bool.TryParse(value, out _) => "boolean",
        _ => "text"
    };

    private static void ApplyFormatting(IXLCell cell, ExcelCell excelCell, bool isHeader = false)
    {
        cell.Style.Font.Bold = isHeader || excelCell.Bold;
        cell.Style.Font.Italic = excelCell.Italic;
        cell.Style.Font.Underline = excelCell.Underline ? XLFontUnderlineValues.Single : XLFontUnderlineValues.None;

        if (excelCell.Size is { } size)
        {
            cell.Style.Font.FontSize = size;
        }

        if (excelCell.ForegroundColor is { } fg)
        {
            ApplyColor(fg, color => cell.Style.Font.FontColor = color);
        }

        if (excelCell.BackgroundColor is { } bg && !IsDefaultWhite(bg))
        {
            ApplyColor(bg, color =>
            {
                cell.Style.Fill.BackgroundColor = color;
                cell.Style.Fill.PatternType = XLFillPatternValues.Solid;
            });
        }

        if (excelCell.Align is { } align)
        {
            cell.Style.Alignment.Horizontal = align.ToLowerInvariant() switch
            {
                "left" => XLAlignmentHorizontalValues.Left,
                "center" => XLAlignmentHorizontalValues.Center,
                "right" => XLAlignmentHorizontalValues.Right,
                _ => XLAlignmentHorizontalValues.General
            };
        }

        if (!string.IsNullOrWhiteSpace(excelCell.Format))
        {
            cell.Style.NumberFormat.Format = excelCell.Format;
        }
    }

    private static bool IsDefaultWhite(string? color)
    {
        if (color is null)
        {
            return false;
        }

        var span = color.AsSpan().Trim();

        return span.Equals("white", StringComparison.OrdinalIgnoreCase) || span.Equals("#FFFFFF", StringComparison.OrdinalIgnoreCase) || span.Equals("#FFF", StringComparison.OrdinalIgnoreCase);
    }

    private static string? NormalizeValue(string? value) =>
        string.Equals(value, "null", StringComparison.OrdinalIgnoreCase) ? null : value;

    private static void ApplyColor(string? colorValue, Action<XLColor> apply)
    {
        if (string.IsNullOrWhiteSpace(colorValue))
        {
            return;
        }

        var color = colorValue.StartsWith('#') ? XLColor.FromHtml(colorValue) : XLColor.FromName(colorValue);
        apply(color);
    }
}

public sealed class ExcelCell
{
    [Description("The cell text value.")]
    [JsonConverter(typeof(FlexibleStringConverter))]
    public string? Value { get; init; }

    [Description("Data type: 'text', 'number', 'date', 'time', 'boolean', 'percentage', or 'currency'.")]
    public string? Type { get; init; } = "text";

    [Description("""
        Excel number format string (e.g., '0.00', 'dd/MM/yyyy', '#,##0.00 €').
        For currency values, try to determine the currency symbol from the user's language
        (e.g., Italian -> '#,##0.00 €', English US -> '$#,##0.00') or from context if available.
        """)]
    public string? Format { get; init; }

    [Description("Whether the text is bold.")]
    public bool Bold { get; init; }

    [Description("Whether the text is italic.")]
    public bool Italic { get; init; }

    [Description("Whether the text is underlined.")]
    public bool Underline { get; init; }

    [Description("Font size in points.")]
    public double? Size { get; init; }

    [Description("Text color as a hex code (e.g., '#FF0000') or named color (e.g., 'Red').")]
    public string? ForegroundColor { get; init; }

    [Description("Background color as a hex code (e.g., '#003366') or named color (e.g., 'White').")]
    public string? BackgroundColor { get; init; }

    [Description("Horizontal alignment: 'left', 'center', or 'right'.")]
    public string? Align { get; init; }
}

public sealed class ExcelRow
{
    [Description("The cells in this row.")]
    public required ExcelCell[] Cells { get; init; }

    [Description("Background color for the entire row as a hex code (e.g., '#D9E2F3') or named color. Use this for alternating row colors instead of setting BackgroundColor on individual cells.")]
    public string? BackgroundColor { get; init; }
}