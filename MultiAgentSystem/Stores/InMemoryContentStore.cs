using System.Collections.Concurrent;
using System.Text.Json;
using MultiAgentSystem.Models;

namespace MultiAgentSystem.Stores;

/// <summary>
/// In-memory singleton store that holds <see cref="ToolResult"/> objects produced by tool calls
/// so that export tools can render content deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Supports both tabular data and free-form text/markdown content.
/// Producers call <see cref="StoreAsync"/> to save a result and receive a short ID;
/// export tools call <see cref="GetAsync"/> with that ID to retrieve the full content.
/// </remarks>
public sealed class InMemoryContentStore : IContentStore
{
    private readonly ConcurrentDictionary<string, ToolResult> contents = new();

    /// <inheritdoc/>
    public Task<string> StoreAsync(ToolResult result)
    {
        ArgumentNullException.ThrowIfNull(result);

        var id = Guid.NewGuid().ToString("N")[..8];

        // Serialize Data to JSON for table content so export tools receive a ready-to-use string.
        var serializedData = result.Data is string data ? data : JsonSerializer.Serialize(result.Data, JsonSerializerOptions.Web);

        contents[id] = result with { ContentId = id, Data = serializedData };

        return Task.FromResult(id);
    }

    /// <inheritdoc/>
    public Task<ToolResult?> GetAsync(string contentId)
        => Task.FromResult(contents.GetValueOrDefault(contentId));
}
