using System.ComponentModel;
using System.Globalization;
using System.Text.Json;

namespace MultiAgentSystem.Models;

/// <summary>
/// Defines a column to include in the rendered output, mapping a JSON property to a display column.
/// </summary>
public sealed class RenderColumn
{
    [Description("The exact JSON property name from the data source. Use the column names returned in the 'columns' array of the query response (e.g., 'Name', 'UnitPrice', 'IsDiscontinued').")]
    public required string Field { get; set; }

    [Description("The display header for this column. Defaults to the Field name if not specified.")]
    public string? Header { get; init; }

    [Description("Data type: 'text', 'number', 'date', 'time', 'boolean', 'percentage', or 'currency'. Drives value parsing and default alignment in Excel. When set to 'currency' or 'percentage', also provide a Format string.")]
    public string? Type { get; init; }

    [Description("""
        Excel number format string (e.g., '0.00', 'dd/MM/yyyy', '#,##0.00 €').
        For currency values, determine the currency symbol from context or the user's language
        (e.g., Italian -> '#,##0.00 €', English US -> '$#,##0.00').
        Takes precedence over Style.Format when both are specified. Supported in Excel only.
        """)]
    public string? Format { get; init; }

    [Description("Unconditional style applied to every cell in this column (e.g., always bold).")]
    public CellStyle? Style { get; init; }
}

/// <summary>
/// A rule that applies a style to cells in a column when a condition on that column's value is met.
/// </summary>
/// <example>
/// To highlight prices greater than 100 in red:
/// <c>{ Column = "unitPrice", Condition = "gt", Threshold = "100", Style = { ForegroundColor = "#FF0000" } }</c>
/// To highlight prices between 50 and 100 in yellow:
/// <c>{ Column = "unitPrice", Condition = "between", Threshold = "50", ThresholdEnd = "100", Style = { BackgroundColor = "#FFFF00" } }</c>
/// </example>
public sealed class CellRule
{
    [Description("The JSON property name of the column whose value is evaluated and to which the style is applied.")]
    public required string Column { get; init; }

    [Description("Comparison operator: 'gt', 'gte', 'lt', 'lte', 'eq', 'neq', 'between', 'contains', 'startsWith', 'endsWith', 'isNull', 'isNotNull'.")]
    public required string Condition { get; init; }

    [Description("The value to compare against. Not required for 'isNull' and 'isNotNull'.")]
    public string? Threshold { get; init; }

    [Description("The upper bound for 'between' comparisons (inclusive). Required only when Condition is 'between'.")]
    public string? ThresholdEnd { get; init; }

    [Description("The style to apply when the condition is true.")]
    public required CellStyle Style { get; init; }
}

/// <summary>
/// A rule that applies a style to entire rows based on their position (e.g., alternating row colors).
/// </summary>
/// <example>
/// To apply alternating row colors (zebra stripes):
/// <c>{ Condition = "even", Style = { BackgroundColor = "#D9E2F3" } }</c>
/// To highlight every third row:
/// <c>{ Condition = "every", Interval = 3, Style = { BackgroundColor = "#FFFF00" } }</c>
/// </example>
public sealed class RowRule
{
    [Description("Row condition: 'odd' (1st, 3rd, 5th data rows), 'even' (2nd, 4th, 6th data rows), or 'every' (every N-th row, requires Interval).")]
    public required string Condition { get; init; }

    [Description("Row interval for 'every' condition (e.g., 3 means every 3rd row). Required only when Condition is 'every'.")]
    public int? Interval { get; init; }

    [Description("The style to apply to all cells in matching rows. Row-level style has lower priority than cell-level or conditional styles.")]
    public required CellStyle Style { get; init; }
}

/// <summary>
/// Visual styling for a table cell.
/// </summary>
/// <remarks>
/// Bold and italic are supported in all formats (Excel, PDF, Word).
/// Colors and number formats are supported in Excel only.
/// </remarks>
public sealed class CellStyle
{
    [Description("Whether the text is bold.")]
    public bool Bold { get; init; }

    [Description("Whether the text is italic.")]
    public bool Italic { get; init; }

    [Description("Whether the text is underlined.")]
    public bool Underline { get; init; }

    [Description("Font size in points. Supported in Excel only.")]
    public double? Size { get; init; }

    [Description("Text color as a hex code (e.g., '#FF0000') or named color. Supported in Excel only.")]
    public string? ForegroundColor { get; init; }

    [Description("Background color as a hex code or named color. Supported in Excel only.")]
    public string? BackgroundColor { get; init; }

    [Description("Horizontal alignment: 'left', 'center', or 'right'.")]
    public string? Align { get; init; }

    [Description("Excel number format string (e.g., '#,##0.00 €'). Supported in Excel only.")]
    public string? Format { get; init; }
}

/// <summary>
/// Evaluates <see cref="CellRule"/> conditions against JSON element values
/// and merges cell styles.
/// </summary>
public static class ConditionEvaluator
{
    /// <summary>
    /// Evaluates a conditional rule against a JSON element value.
    /// </summary>
    public static bool Evaluate(JsonElement element, CellRule rule)
    {
        return rule.Condition.ToLowerInvariant() switch
        {
            "gt" => CompareNumeric(element, rule.Threshold, (a, b) => a > b),
            "gte" => CompareNumeric(element, rule.Threshold, (a, b) => a >= b),
            "lt" => CompareNumeric(element, rule.Threshold, (a, b) => a < b),
            "lte" => CompareNumeric(element, rule.Threshold, (a, b) => a <= b),
            "between" => CompareBetween(element, rule.Threshold, rule.ThresholdEnd),
            "eq" => string.Equals(GetStringValue(element), rule.Threshold, StringComparison.OrdinalIgnoreCase),
            "neq" => !string.Equals(GetStringValue(element), rule.Threshold, StringComparison.OrdinalIgnoreCase),
            "contains" => GetStringValue(element)?.Contains(rule.Threshold ?? "", StringComparison.OrdinalIgnoreCase) is true,
            "startswith" => GetStringValue(element)?.StartsWith(rule.Threshold ?? "", StringComparison.OrdinalIgnoreCase) is true,
            "endswith" => GetStringValue(element)?.EndsWith(rule.Threshold ?? "", StringComparison.OrdinalIgnoreCase) is true,
            "isnull" => element.ValueKind is JsonValueKind.Null or JsonValueKind.Undefined,
            "isnotnull" => element.ValueKind is not JsonValueKind.Null and not JsonValueKind.Undefined,
            _ => false
        };
    }

    /// <summary>
    /// Merges two styles, with the conditional style taking precedence for non-default values.
    /// </summary>
    public static CellStyle MergeStyles(CellStyle? baseStyle, CellStyle? conditionalStyle)
    {
        if (baseStyle is null)
        {
            return conditionalStyle ?? new();
        }

        if (conditionalStyle is null)
        {
            return baseStyle;
        }

        return new()
        {
            Bold = baseStyle.Bold || conditionalStyle.Bold,
            Italic = baseStyle.Italic || conditionalStyle.Italic,
            Underline = baseStyle.Underline || conditionalStyle.Underline,
            Size = conditionalStyle.Size ?? baseStyle.Size,
            ForegroundColor = conditionalStyle.ForegroundColor ?? baseStyle.ForegroundColor,
            BackgroundColor = conditionalStyle.BackgroundColor ?? baseStyle.BackgroundColor,
            Align = conditionalStyle.Align ?? baseStyle.Align,
            Format = conditionalStyle.Format ?? baseStyle.Format
        };
    }

    private static bool CompareNumeric(JsonElement element, string? threshold, Func<double, double, bool> comparison)
    {
        if (threshold is null)
        {
            return false;
        }

        if (double.TryParse(threshold, CultureInfo.InvariantCulture, out var numericThreshold))
        {
            return element.ValueKind switch
            {
                JsonValueKind.Number => comparison(element.GetDouble(), numericThreshold),
                JsonValueKind.String when double.TryParse(element.GetString(), CultureInfo.InvariantCulture, out var val)
                    => comparison(val, numericThreshold),
                _ => false
            };
        }

        // Fall back to date/time comparison so gt, gte, lt, lte work with ISO 8601 strings.
        if (DateTimeOffset.TryParse(threshold, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateThreshold)
            && element.ValueKind is JsonValueKind.String && DateTimeOffset.TryParse(element.GetString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out var elementDate))
        {
            return comparison(elementDate.UtcTicks, dateThreshold.UtcTicks);
        }

        return false;
    }

    private static bool CompareBetween(JsonElement element, string? thresholdStart, string? thresholdEnd)
    {
        if (thresholdStart is null || thresholdEnd is null)
        {
            return false;
        }

        if (double.TryParse(thresholdStart, CultureInfo.InvariantCulture, out var low)
            && double.TryParse(thresholdEnd, CultureInfo.InvariantCulture, out var high))
        {
            return element.ValueKind switch
            {
                JsonValueKind.Number => element.GetDouble() is var v && v >= low && v <= high,
                JsonValueKind.String when double.TryParse(element.GetString(), CultureInfo.InvariantCulture, out var val)
                    => val >= low && val <= high,
                _ => false
            };
        }

        // Fall back to date/time comparison so between works with ISO 8601 strings.
        if (DateTimeOffset.TryParse(thresholdStart, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateLow)
            && DateTimeOffset.TryParse(thresholdEnd, CultureInfo.InvariantCulture, DateTimeStyles.None, out var dateHigh)
            && element.ValueKind is JsonValueKind.String
            && DateTimeOffset.TryParse(element.GetString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out var elementDate))
        {
            return elementDate >= dateLow && elementDate <= dateHigh;
        }

        return false;
    }

    private static string? GetStringValue(JsonElement element) => element.ValueKind switch
    {
        JsonValueKind.String => element.GetString(),
        JsonValueKind.Null or JsonValueKind.Undefined => null,
        _ => element.GetRawText()
    };
}
