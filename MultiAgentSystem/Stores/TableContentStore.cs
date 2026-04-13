using System.Collections.Concurrent;

namespace MultiAgentSystem.Stores;

/// <summary>
/// Scoped store that holds tabular data produced by tool calls (e.g., query results as JSON arrays)
/// so that export tools can render it deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Only use for pure tabular data (JSON arrays of homogeneous objects).
/// Producers call <see cref="Store"/> to save content and receive a short ID;
/// export tools call <see cref="Get"/> with that ID to retrieve the full dataset.
/// </remarks>
public sealed class TableContentStore
{
    private readonly ConcurrentDictionary<string, string> contents = new();

    /// <summary>
    /// Stores content and returns a short identifier that can be passed between agents.
    /// </summary>
    public string Store(string content)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(content);

        var id = Guid.NewGuid().ToString("N")[..8];
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
