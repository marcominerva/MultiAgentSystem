namespace MultiAgentSystem.Stores;

/// <summary>
/// Store that holds tabular data produced by tool calls (e.g., query results as JSON arrays)
/// so that export tools can render it deterministically without LLM-mediated data transfer.
/// </summary>
/// <remarks>
/// Only use for pure tabular data (JSON arrays of homogeneous objects).
/// Producers call <see cref="Store"/> to save content and receive a short ID;
/// export tools call <see cref="Get"/> with that ID to retrieve the full dataset.
/// </remarks>
public interface ITableContentStore
{
    /// <summary>
    /// Serializes <paramref name="content"/> to JSON and stores it, returning a short identifier
    /// that can be passed between agents.
    /// </summary>
    Task<string> StoreAsync(object content);

    /// <summary>
    /// Retrieves previously stored content by its identifier,
    /// or <see langword="null"/> if the identifier is not found.
    /// </summary>
    Task<string?> GetAsync(string contentId);
}
