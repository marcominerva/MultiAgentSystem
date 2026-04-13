using System.Text.Json;

namespace MultiAgentSystem.Extensions;

/// <summary>
/// Provides fuzzy property lookup on <see cref="JsonElement"/>,
/// because LLM-generated field names may not match the casing or formatting of the JSON properties
/// (e.g., <c>"unit_price"</c> vs <c>"UnitPrice"</c>).
/// </summary>
internal static class JsonElementExtensions
{
    extension(JsonElement element)
    {
        /// <summary>
        /// Attempts to get a property by name using progressively looser matching:
        /// exact → case-insensitive → normalized (strips <c>_</c>, <c>-</c>, spaces and compares lowercase).
        /// </summary>
        public bool TryGetPropertyIgnoreCase(string propertyName, out JsonElement value)
        {
            // Fast path: exact match.
            if (element.TryGetProperty(propertyName, out value))
            {
                return true;
            }

            // Second pass: case-insensitive exact, with normalized fallback collected in the same scan.
            var normalizedTarget = Normalize(propertyName);
            JsonElement? normalizedMatch = null;

            foreach (var property in element.EnumerateObject())
            {
                if (string.Equals(property.Name, propertyName, StringComparison.OrdinalIgnoreCase))
                {
                    value = property.Value;
                    return true;
                }

                if (normalizedMatch is null && Normalize(property.Name) == normalizedTarget)
                {
                    normalizedMatch = property.Value;
                }
            }

            if (normalizedMatch.HasValue)
            {
                value = normalizedMatch.Value;
                return true;
            }

            value = default;
            return false;
        }
    }

    private static string Normalize(string name)
        => name.Replace("_", "").Replace(" ", "").Replace("-", "").ToLowerInvariant();
}
