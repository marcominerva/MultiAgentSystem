using System.Collections.Concurrent;
using System.Text.Json;
using MultiAgentSystem.Models;

namespace MultiAgentSystem.Stores;

/// <summary>
/// In-memory singleton store that holds <see cref="ToolResult"/> objects produced by tool calls
/// so that export tools can render content deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Supports tabular data, JSON object lists, and free-form text/markdown content.
/// Producers call <see cref="SetAsync"/> to save a result and receive a short ID;
/// export tools call <see cref="GetAsync"/> with that ID to retrieve the full content.
/// </remarks>
public sealed class InMemoryContentStore(TimeProvider timeProvider) : IContentStore
{
    private static readonly TimeSpan ttl = TimeSpan.FromMinutes(5);

    private readonly ConcurrentDictionary<string, StoredContent> contents = new();

    /// <inheritdoc/>
    public Task<string> SetAsync(ToolResult result, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(result);
        cancellationToken.ThrowIfCancellationRequested();

        // If the producer provided a ContentId, use it; otherwise generate a new short ID.
        var id = result.ContentId ?? Guid.NewGuid().ToString("N")[..8];
        result.ContentId = id;

        // Text and list payloads are already strings; only table content needs serialization.
        var serializedData = result.ContentType is ContentTypes.Text or ContentTypes.List
            ? (string)result.Data : JsonSerializer.Serialize(result.Data, JsonSerializerOptions.Web);

        contents[id] = new StoredContent(result with { Data = serializedData }, timeProvider.GetUtcNow().Add(ttl));

        return Task.FromResult(id);
    }

    /// <inheritdoc/>
    public Task<ToolResult?> GetAsync(string contentId, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        EvictExpiredEntries();
        return Task.FromResult(contents.TryGetValue(contentId, out var stored) ? stored.Result : null);
    }

    /// <inheritdoc/>
    public Task<IEnumerable<ToolResult>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        EvictExpiredEntries();
        return Task.FromResult<IEnumerable<ToolResult>>([.. contents.Values.Select(static c => c.Result)]);
    }

    /// <inheritdoc/>
    public Task<bool> RemoveAsync(string contentId, CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(contentId);
        cancellationToken.ThrowIfCancellationRequested();

        return Task.FromResult(contents.TryRemove(contentId, out _));
    }

    /// <inheritdoc/>
    public Task ClearAsync(CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        contents.Clear();
        return Task.CompletedTask;
    }

    private void EvictExpiredEntries()
    {
        var now = timeProvider.GetUtcNow();

        // Evict every entry older than the TTL to keep the store bounded.
        foreach (var entry in contents)
        {
            if (entry.Value.ExpiresAt <= now)
            {
                contents.TryRemove(entry.Key, out _);
            }
        }
    }

    private sealed record StoredContent(ToolResult Result, DateTimeOffset ExpiresAt);
}

/// <summary>
/// Store that holds content produced by tool calls so that other tools can
/// render it deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Supports tabular data, JSON object lists, and free-form text/markdown.
/// Producers call <see cref="SetAsync"/> to save a <see cref="ToolResult"/> and receive a short ID;
/// export tools call <see cref="GetAsync"/> with that ID to retrieve the full content.
/// </remarks>
public interface IContentStore
{
    /// <summary>
    /// Stores a <see cref="ToolResult"/>, assigning it a short content identifier,
    /// and returns the identifier.
    /// </summary>
    /// <remarks>
    /// For structured results the <see cref="ToolResult.Data"/> payload is serialized to JSON;
    /// for text results it is stored as-is.
    /// </remarks>
    Task<string> SetAsync(ToolResult result, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves a previously stored <see cref="ToolResult"/> by its identifier,
    /// or <see langword="null"/> if the identifier is not found.
    /// </summary>
    Task<ToolResult?> GetAsync(string contentId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Asynchronously retrieves all tool results. This is necessary so that the LLM knows what content is available in the store and can reference it by ID, since the LLM doesn't have memory of previous interactions and can't be expected to know what content IDs exist.
    /// </summary>
    Task<IEnumerable<ToolResult>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>
    /// Removes the entry identified by <paramref name="contentId"/> from the store.
    /// </summary>
    /// <returns><see langword="true"/> if an entry was found and removed; otherwise, <see langword="false"/>.</returns>
    Task<bool> RemoveAsync(string contentId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Removes all entries from the store. Typically invoked when starting a new conversation
    /// to discard previously generated content and reclaim memory.
    /// </summary>
    Task ClearAsync(CancellationToken cancellationToken = default);
}