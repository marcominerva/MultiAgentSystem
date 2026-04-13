using System.Collections.Concurrent;
using System.Text.Json;

namespace MultiAgentSystem.Stores;

/// <summary>
/// Singleton store that holds tabular data produced by tool calls (e.g., query results as JSON arrays)
/// so that export tools can render it deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Only use for pure tabular data (JSON arrays of homogeneous objects).
/// Producers call <see cref="Store"/> to save content and receive a short ID;
/// export tools call <see cref="Get"/> with that ID to retrieve the full dataset.
/// </remarks>
public sealed class InMemoryTableContentStore : ITableContentStore
{
    private readonly ConcurrentDictionary<string, string> contents = new();

    /// <inheritdoc/>
    public Task<string> StoreAsync(object content)
    {
        ArgumentNullException.ThrowIfNull(content);

        var id = Guid.NewGuid().ToString("N")[..8];
        contents[id] = JsonSerializer.Serialize(content, JsonSerializerOptions.Web);

        return Task.FromResult(id);
    }

    /// <inheritdoc/>
    public Task<string?> GetAsync(string contentId)
        => Task.FromResult(contents.GetValueOrDefault(contentId));
}
