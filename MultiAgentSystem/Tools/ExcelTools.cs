using System.ComponentModel;
using System.Globalization;
using AgentWithTools.AgentArtifacts;
using ClosedXML.Excel;

namespace AgentWithTools.Tools;

public sealed class ExcelTools(AgentArtifactStore artifactStore)
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