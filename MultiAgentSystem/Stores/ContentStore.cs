using System.Collections.Concurrent;

namespace MultiAgentSystem.Stores;

/// <summary>
/// Scoped store that holds content produced by tool calls (e.g., query results, generated text)
/// so that it can be reliably retrieved by other tools within the same request.
/// </summary>
/// <remarks>
/// This avoids passing large payloads through LLM-generated text, which is lossy.
/// Producers call <see cref="Store"/> to save content and receive a short ID;
/// consumers call <see cref="Get"/> with that ID to retrieve the full content.
/// </remarks>
public sealed class ContentStore
{
    private readonly ConcurrentDictionary<string, string> contents = new();

    /// <summary>
    /// Stores content and returns a short identifier that can be passed between agents.
    /// </summary>
    public string Store(string content)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(content);

        var id = Guid.NewGuid().ToString("N");
        contents[id] = content;

        return id;
    }

    /// <summary>
    /// Retrieves previously stored content by its identifier,
    /// or <see langword="null"/> if the identifier is not found.
    /// </summary>
    public string? Get(string contentId)
        => contents.GetValueOrDefault(contentId);
}
