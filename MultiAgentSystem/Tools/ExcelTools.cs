using System.ComponentModel;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Serialization;
using ClosedXML.Excel;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Converters;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Tools;

public sealed class ExcelTools(AgentArtifactStore artifactStore, ContentStore contentStore)
{
    [Description("""
        Generates an Excel file (.xlsx) from tabular data with optional per-cell formatting.
        Use when the user asks to create, export, or save data as an Excel spreadsheet.
        """)]
    public string GenerateExcel(
        [Description("The file name without extension.")] string fileName,
        [Description("The name of the worksheet.")] string sheetName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("Column headers for the spreadsheet.")] ExcelCell[] headers,
        [Description("Data rows for the spreadsheet.")] ExcelRow[] rows)
    {
        using var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add(string.IsNullOrWhiteSpace(sheetName) ? "Sheet1" : sheetName);

        for (var col = 0; col < headers.Length; col++)
        {
            var headerCell = headers[col];
            var cell = worksheet.Cell(1, col + 1);
            cell.Value = NormalizeValue(headerCell.Value);
            ApplyFormatting(cell, headerCell, isHeader: true);
        }

        for (var row = 0; row < rows.Length; row++)
        {
            var dataCells = rows[row].Cells;
            for (var col = 0; col < dataCells.Length; col++)
            {
                var dataCell = dataCells[col];
                var cell = worksheet.Cell(row + 2, col + 1);
                SetTypedCellValue(cell, dataCell);
                ApplyFormatting(cell, dataCell);
            }
        }

        worksheet.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);

        artifactStore.Add(new($"{fileName}.xlsx", stream.ToArray()));

        return description;
    }

    [Description("""
        Generates an Excel file from previously stored structured data (e.g., query results) identified by a Content ID.
        Use this instead of GenerateExcel when exporting tabular data that was produced by another tool.
        The tool reads ALL data from the store — nothing is truncated.
        """)]
    public string GenerateExcelFromContent(
        [Description("The Content ID of the stored data.")] string contentId,
        [Description("The file name without extension.")] string fileName,
        [Description("The name of the worksheet.")] string sheetName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("Column definitions specifying which fields to include, display headers, and unconditional styles.")] RenderColumn[] columns,
        [Description("Optional conditional formatting rules (e.g., highlight prices > 100 in red).")] ConditionalRule[]? rules = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(contentId);
        ArgumentNullException.ThrowIfNull(columns);

        var json = contentStore.Get(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        using var doc = JsonDocument.Parse(json);
        using var workbook = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add(string.IsNullOrWhiteSpace(sheetName) ? "Sheet1" : sheetName);

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
            for (var col = 0; col < columns.Length; col++)
            {
                var column = columns[col];
                var cell = worksheet.Cell(rowIndex, col + 1);

                if (item.TryGetProperty(column.Field, out var prop))
                {
                    SetCellValueFromJson(cell, prop);
                }

                var effectiveStyle = ResolveStyle(item, column, rules);
                ApplyCellStyleFromSpec(cell, effectiveStyle);
            }

            rowIndex++;
        }

        worksheet.Columns().AdjustToContents();

        using var stream = new MemoryStream();
        workbook.SaveAs(stream);

        artifactStore.Add(new($"{fileName}.xlsx", stream.ToArray()));

        return description;
    }

    private static CellStyle ResolveStyle(JsonElement row, RenderColumn column, ConditionalRule[]? rules)
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

                if (row.TryGetProperty(rule.Column, out var evalProp) && ConditionEvaluator.Evaluate(evalProp, rule))
                {
                    style = ConditionEvaluator.MergeStyles(style, rule.Style);
                }
            }
        }

        return style ?? new();
    }

    private static void SetCellValueFromJson(IXLCell cell, JsonElement element)
    {
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
                var str = element.GetString();
                if (DateTime.TryParse(str, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
                {
                    cell.Value = date;
                    cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                }
                else if (double.TryParse(str, CultureInfo.InvariantCulture, out var num))
                {
                    cell.Value = num;
                    cell.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                }
                else
                {
                    cell.Value = str;
                }

                break;
            default:
                cell.Value = Blank.Value;
                break;
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
}