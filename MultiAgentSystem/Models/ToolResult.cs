using System.ComponentModel;
using System.Text;

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
    public string ContentId { get; set; } = Guid.NewGuid().ToString("N")[..8];

    /// <summary>
    /// A brief description of the data or purpose of the result, useful for export tools to provide context when rendering content.
    /// </summary>
    public string Description { get; init; }

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
    /// Contains the JSON data array when <see cref="ContentType"/> is <c>"table"</c>,
    /// or the text/markdown content when <see cref="ContentType"/> is <c>"text"</c>.
    /// </summary>
    [Description("The result payload. Contains the data array when ContentType is 'table', or the text/markdown content when ContentType is 'text'.")]
    public object Data { get; init; }

    /// <summary>
    /// Creates a tabular result with row count, column metadata, and the data array.
    /// </summary>
    public ToolResult(object data, int rowCount, IEnumerable<string> columns, string description)
    {
        Description = description;
        ContentType = "table";
        RowCount = rowCount;
        Columns = columns;
        Data = data;
    }

    /// <summary>
    /// Creates a text result containing free-form or markdown content.
    /// </summary>
    public ToolResult(object data, string description)
    {
        Description = description;
        ContentType = "text";
        Data = data;
    }

    /// <summary>
    /// Returns a human-readable summary suitable for LLM context injection,
    /// including content ID, description, type, and column/row metadata when applicable.
    /// </summary>
    public override string ToString()
    {
        var builder = new StringBuilder();
        builder.Append($"[ContentId: {ContentId}] {Description} (type: {ContentType}");

        if (ContentType is "table")
        {
            builder.Append($", {RowCount} rows, columns: {string.Join(", ", Columns)}");
        }

        builder.Append(')');

        return builder.ToString();
    }
}
