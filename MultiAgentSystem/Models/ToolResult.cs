using System.ComponentModel;

namespace MultiAgentSystem.Models;

/// <summary>
/// Represents the result of a tool execution, supporting both tabular and text content.
/// </summary>
public record class ToolResult
{
    /// <summary>
    /// The Content ID for cross-agent data transfer. Tools use this value to retrieve the full dataset.
    /// </summary>
    [Description("The Content ID for cross-agent data transfer. Tools use this value to retrieve the full dataset.")]
    public string ContentId { get; init; } = string.Empty;

    /// <summary>
    /// The type of content: <c>"table"</c> for tabular data or <c>"text"</c> for text/markdown content.
    /// </summary>
    [Description("The type of content: 'table' for tabular data or 'text' for text/markdown content.")]
    public string ContentType { get; init; }

    /// <summary>
    /// The number of rows returned. Meaningful only when <see cref="ContentType"/> is <c>"table"</c>.
    /// </summary>
    [Description("The number of rows returned by the query. Meaningful only when ContentType is 'table'.")]
    public int RowCount { get; init; }

    /// <summary>
    /// The column names in the result set. Meaningful only when <see cref="ContentType"/> is <c>"table"</c>.
    /// </summary>
    [Description("The column names in the result set. Meaningful only when ContentType is 'table'.")]
    public IEnumerable<string> Columns { get; init; } = [];

    /// <summary>
    /// The result payload.
    /// Contains the data array when <see cref="ContentType"/> is <c>"table"</c>,
    /// or the text/markdown content when <see cref="ContentType"/> is <c>"text"</c>.
    /// </summary>
    [Description("The result payload. Contains the data array when ContentType is 'table', or the text/markdown content when ContentType is 'text'.")]
    public object Data { get; init; }

    /// <summary>
    /// Creates a tabular result with row count, column metadata, and the data array.
    /// </summary>
    public ToolResult(string contentId, int rowCount, IEnumerable<string> columns, object data)
    {
        ContentId = contentId;
        ContentType = "table";
        RowCount = rowCount;
        Columns = columns;
        Data = data;
    }

    /// <summary>
    /// Creates a text result containing free-form or markdown content.
    /// </summary>
    public ToolResult(string contentId, object data)
    {
        ContentId = contentId;
        ContentType = "text";
        Data = data;
    }
}
