using System.Text.Json;
using MultiAgentSystem.Models;

namespace MultiAgentSystem.Extensions;

/// <summary>
/// Resolves LLM-generated <see cref="RenderColumn.Field"/> values to actual JSON property names.
/// Handles case differences, separator normalization, and falls back to positional mapping
/// when the LLM translates field names to a different language.
/// </summary>
internal static class ColumnResolver
{
    /// <summary>
    /// Maps each column's <see cref="RenderColumn.Field"/> to the corresponding JSON property name.
    /// Uses three passes: exact/case-insensitive/normalized match first, then positional fallback
    /// for any columns that still don't match.
    /// </summary>
    public static RenderColumn[] Resolve(JsonElement array, RenderColumn[] columns)
    {
        if (array.GetArrayLength() == 0 || columns.Length == 0)
        {
            return columns;
        }

        var jsonProps = array[0].EnumerateObject().Select(p => p.Name).ToList();
        var matchedProps = new HashSet<string>(StringComparer.Ordinal);
        var unmatchedIndices = new List<int>();

        // First pass: match via exact, case-insensitive, or normalized comparison.
        for (var i = 0; i < columns.Length; i++)
        {
            var match = FindMatch(jsonProps, columns[i].Field, matchedProps);
            if (match is not null)
            {
                matchedProps.Add(match);
                columns[i].Field = match;
            }
            else
            {
                unmatchedIndices.Add(i);
            }
        }

        // Second pass: positional fallback for unmatched columns.
        // Preserves the original order — if the LLM translated field names but kept the same column order,
        // each unmatched column maps to the next unmatched JSON property.
        var unmatchedProps = jsonProps.Where(p => !matchedProps.Contains(p)).ToList();

        for (var i = 0; i < Math.Min(unmatchedIndices.Count, unmatchedProps.Count); i++)
        {
            var colIdx = unmatchedIndices[i];
            columns[colIdx].Field = unmatchedProps[i];
        }

        return columns;
    }

    private static string? FindMatch(List<string> jsonProps, string field, HashSet<string> alreadyMatched)
    {
        var normalizedField = Normalize(field);

        foreach (var prop in jsonProps)
        {
            if (alreadyMatched.Contains(prop))
            {
                continue;
            }

            if (string.Equals(prop, field, StringComparison.OrdinalIgnoreCase)
                || Normalize(prop) == normalizedField)
            {
                return prop;
            }
        }

        return null;
    }

    private static string Normalize(string name)
        => name.Replace("_", "").Replace(" ", "").Replace("-", "").ToLowerInvariant();
}
