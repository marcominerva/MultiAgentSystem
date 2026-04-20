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

        // If the producer provided a ContentId, use it; otherwise generate a new short ID.
        var id = result.ContentId ?? Guid.NewGuid().ToString("N")[..8];
        result.ContentId = id;

        // Serialize Data to JSON for table content so export tools receive a ready-to-use string.
        var serializedData = result.Data is string data ? data : JsonSerializer.Serialize(result.Data, JsonSerializerOptions.Web);

        contents[id] = result with { Data = serializedData };

        return Task.FromResult(id);
    }

    /// <inheritdoc/>
    public Task<ToolResult?> GetAsync(string contentId)
        => Task.FromResult(contents.GetValueOrDefault(contentId));

    /// <inheritdoc/>
    public Task<IEnumerable<ToolResult>> GetAllAsync()
        => Task.FromResult<IEnumerable<ToolResult>>([.. contents.Values]);
}

/// <summary>
/// Store that holds content produced by tool calls so that other tools can
/// render it deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Supports both tabular data (JSON arrays of homogeneous objects) and free-form text/markdown.
/// Producers call <see cref="StoreAsync"/> to save a <see cref="ToolResult"/> and receive a short ID;
/// export tools call <see cref="GetAsync"/> with that ID to retrieve the full content.
/// </remarks>
public interface IContentStore
{
    /// <summary>
    /// Stores a <see cref="ToolResult"/>, assigning it a short content identifier,
    /// and returns the identifier.
    /// </summary>
    /// <remarks>
    /// For tabular results the <see cref="ToolResult.Data"/> payload is serialized to JSON;
    /// for text results it is stored as-is.
    /// </remarks>
    Task<string> StoreAsync(ToolResult result);

    /// <summary>
    /// Retrieves a previously stored <see cref="ToolResult"/> by its identifier,
    /// or <see langword="null"/> if the identifier is not found.
    /// </summary>
    Task<ToolResult?> GetAsync(string contentId);

    /// <summary>
    /// Asynchronously retrieves all tool results. This is necessary so that the LLM knows what content is available in the store and can reference it by ID, since the LLM doesn't have memory of previous interactions and can't be expected to know what content IDs exist.
    /// </summary>
    Task<IEnumerable<ToolResult>> GetAllAsync();
}