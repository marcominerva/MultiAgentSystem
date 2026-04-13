using MultiAgentSystem.Models;

namespace MultiAgentSystem.Stores;

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
}
