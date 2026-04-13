using System.ComponentModel;
using System.Globalization;
using System.Text.Json;

namespace MultiAgentSystem.Models;

/// <summary>
/// Defines a column to include in the rendered output, mapping a JSON property to a display column.
/// </summary>
public sealed class RenderColumn
{
    [Description("The JSON property name from the data source (e.g., 'productName', 'unitPrice').")]
    public required string Field { get; init; }

    [Description("The display header for this column. Defaults to the Field name if not specified.")]
    public string? Header { get; init; }

    [Description("Unconditional style applied to every cell in this column (e.g., always bold).")]
    public CellStyle? Style { get; init; }
}

/// <summary>
/// A rule that applies a style to cells in a column when a condition on that column's value is met.
/// </summary>
/// <example>
/// To highlight prices greater than 100 in red:
/// <c>{ Column = "unitPrice", Condition = "gt", Threshold = "100", Style = { ForegroundColor = "#FF0000" } }</c>
/// </example>
public sealed class ConditionalRule
{
    [Description("The JSON property name of the column whose value is evaluated and to which the style is applied.")]
    public required string Column { get; init; }

    [Description("Comparison operator: 'gt', 'gte', 'lt', 'lte', 'eq', 'neq', 'contains', 'startsWith', 'endsWith', 'isNull', 'isNotNull'.")]
    public required string Condition { get; init; }

    [Description("The value to compare against. Not required for 'isNull' and 'isNotNull'.")]
    public string? Threshold { get; init; }

    [Description("The style to apply when the condition is true.")]
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
/// Evaluates <see cref="ConditionalRule"/> conditions against JSON element values
/// and merges cell styles.
/// </summary>
public static class ConditionEvaluator
{
    /// <summary>
    /// Evaluates a conditional rule against a JSON element value.
    /// </summary>
    public static bool Evaluate(JsonElement element, ConditionalRule rule)
    {
        return rule.Condition.ToLowerInvariant() switch
        {
            "gt" => CompareNumeric(element, rule.Threshold, (a, b) => a > b),
            "gte" => CompareNumeric(element, rule.Threshold, (a, b) => a >= b),
            "lt" => CompareNumeric(element, rule.Threshold, (a, b) => a < b),
            "lte" => CompareNumeric(element, rule.Threshold, (a, b) => a <= b),
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
            ForegroundColor = conditionalStyle.ForegroundColor ?? baseStyle.ForegroundColor,
            BackgroundColor = conditionalStyle.BackgroundColor ?? baseStyle.BackgroundColor,
            Align = conditionalStyle.Align ?? baseStyle.Align,
            Format = conditionalStyle.Format ?? baseStyle.Format
        };
    }

    private static bool CompareNumeric(JsonElement element, string? threshold, Func<double, double, bool> comparison)
    {
        if (threshold is null || !double.TryParse(threshold, CultureInfo.InvariantCulture, out var thresholdValue))
        {
            return false;
        }

        return element.ValueKind switch
        {
            JsonValueKind.Number => comparison(element.GetDouble(), thresholdValue),
            JsonValueKind.String when double.TryParse(element.GetString(), CultureInfo.InvariantCulture, out var val)
                => comparison(val, thresholdValue),
            _ => false
        };
    }

    private static string? GetStringValue(JsonElement element) => element.ValueKind switch
    {
        JsonValueKind.String => element.GetString(),
        JsonValueKind.Null or JsonValueKind.Undefined => null,
        _ => element.GetRawText()
    };
}
