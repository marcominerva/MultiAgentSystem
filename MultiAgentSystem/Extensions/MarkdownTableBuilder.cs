using System.Text;
using System.Text.Json;
using MultiAgentSystem.Models;
using MultiAgentSystem.Tools;

namespace MultiAgentSystem.Extensions;

/// <summary>
/// Builds a markdown table deterministically from JSON data and a render specification.
/// Shared by <see cref="PdfTools"/> and <see cref="WordTools"/> for content-based rendering.
/// </summary>
internal static class MarkdownTableBuilder
{
    /// <summary>
    /// Builds a complete markdown document with an optional title and a table
    /// containing all rows from the JSON array, with formatting applied via markdown syntax.
    /// </summary>
    public static string Build(string json, string? title, RenderColumn[] columns, CellRule[]? rules)
    {
        using var doc = JsonDocument.Parse(json);
        var array = doc.RootElement;

        columns = ColumnResolver.Resolve(array, columns);

        var sb = new StringBuilder();

        if (!string.IsNullOrWhiteSpace(title))
        {
            sb.AppendLine($"# {title}");
            sb.AppendLine();
        }

        AppendHeaderRow(sb, columns);
        AppendAlignmentRow(sb, columns);
        AppendDataRows(sb, array, columns, rules);

        return sb.ToString();
    }

    private static void AppendHeaderRow(StringBuilder sb, RenderColumn[] columns)
    {
        sb.Append('|');
        foreach (var col in columns)
        {
            sb.Append($" {col.Header ?? col.Field} |");
        }

        sb.AppendLine();
    }

    private static void AppendAlignmentRow(StringBuilder sb, RenderColumn[] columns)
    {
        sb.Append('|');
        foreach (var col in columns)
        {
            var marker = col.Style?.Align?.ToLowerInvariant() switch
            {
                "center" => ":---:",
                "right" => "---:",
                _ => ":---"
            };
            sb.Append($" {marker} |");
        }

        sb.AppendLine();
    }

    private static void AppendDataRows(StringBuilder sb, JsonElement array, RenderColumn[] columns, CellRule[]? rules)
    {
        foreach (var item in array.EnumerateArray())
        {
            sb.Append('|');
            foreach (var column in columns)
            {
                var value = item.TryGetPropertyIgnoreCase(column.Field, out var prop)
                    ? FormatJsonValue(prop)
                    : string.Empty;

                var style = ResolveStyle(item, column, rules);
                value = ApplyMarkdownFormatting(value, style);

                sb.Append($" {value} |");
            }

            sb.AppendLine();
        }
    }

    private static CellStyle ResolveStyle(JsonElement row, RenderColumn column, CellRule[]? rules)
    {
        var style = column.Style;

        if (rules is null)
        {
            return style ?? new();
        }

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

        return style ?? new();
    }

    private static string ApplyMarkdownFormatting(string value, CellStyle style)
    {
        if (string.IsNullOrEmpty(value))
        {
            return value;
        }

        if (style.Bold && style.Italic)
        {
            return $"***{value}***";
        }

        if (style.Bold)
        {
            return $"**{value}**";
        }

        if (style.Italic)
        {
            return $"*{value}*";
        }

        return value;
    }

    private static string FormatJsonValue(JsonElement element) => element.ValueKind switch
    {
        JsonValueKind.Null => string.Empty,
        JsonValueKind.String => element.GetString()?.Replace("|", "\\|") ?? string.Empty,
        _ => element.GetRawText().Replace("|", "\\|")
    };
}
