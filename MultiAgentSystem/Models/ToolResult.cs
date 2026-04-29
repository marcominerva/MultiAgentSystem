using System.ComponentModel;
using System.Text;
using System.Text.Json;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Models;

/// <summary>
/// Represents the result of a tool execution, supporting tabular, list, and text content.
/// </summary>
public record class ToolResult
{
    /// <summary>
    /// The Content ID for cross-agent data transfer. Tools use this value to retrieve the full dataset.
    /// </summary>
    [Description("The Content ID for cross-agent data transfer. Tools use this value to retrieve the full dataset.")]
    public string ContentId { get; set; } = Guid.NewGuid().ToString("N")[..8];

    /// <summary>
    /// The UTC timestamp when this result was produced. Useful to order results and apply
    /// retention policies (TTL, sliding windows) in the content store.
    /// </summary>
    [Description("The UTC timestamp when this result was produced.")]
    public DateTimeOffset CreatedAt { get; init; } = DateTimeOffset.UtcNow;

    /// <summary>
    /// The name of the tool that produced this result (e.g. <c>ExecuteQueryAsync</c>).
    /// Useful for diagnostics, auditing, and to disambiguate results in the content store.
    /// </summary>
    [Description("The name of the tool that produced this result.")]
    public string? ToolName { get; init; }

    /// <summary>
    /// A brief description of the data or purpose of the result, useful for export tools to provide context when rendering content.
    /// </summary>
    public string Description { get; init; }

    /// <summary>
    /// The type of content: <c>"table"</c> for tabular data, <c>"list"</c> for JSON object lists, or <c>"text"</c> for text/markdown content.
    /// See <see cref="ContentTypes"/> for the available values.
    /// </summary>
    [Description("The type of content: 'table' for tabular data, 'list' for JSON object lists, or 'text' for text/markdown content.")]
    public string ContentType { get; init; }

    /// <summary>
    /// The number of rows returned. Meaningful only when <see cref="ContentType"/> is <c>"table"</c> or <c>"list"</c>.
    /// </summary>
    [Description("The number of rows returned by the query. Meaningful only when ContentType is 'table' or 'list'.")]
    public int RowCount { get; init; }

    /// <summary>
    /// The column names in the result set. Meaningful only when <see cref="ContentType"/> is <c>"table"</c> or <c>"list"</c>.
    /// </summary>
    [Description("The column names in the result set. Meaningful only when ContentType is 'table' or 'list'.")]
    public IEnumerable<string> Columns { get; init; } = [];

    /// <summary>
    /// The result payload.
    /// Contains the JSON data array when <see cref="ContentType"/> is <c>"table"</c> or <c>"list"</c>,
    /// or the text/markdown content when <see cref="ContentType"/> is <c>"text"</c>.
    /// </summary>
    [Description("The result payload. Contains the data array when ContentType is 'table' or 'list', or the text/markdown content when ContentType is 'text'.")]
    public object Data { get; init; }

    /// <summary>
    /// Creates a tabular result with row count, column metadata, and the data array.
    /// </summary>
    public ToolResult(object data, int rowCount, IEnumerable<string> columns, string description)
    {
        Description = description;
        ContentType = ContentTypes.Table;
        RowCount = rowCount;
        Columns = columns;
        Data = data;
    }

    /// <summary>
    /// Creates a list result from a sequence of objects.
    /// The items are immediately serialized using <see cref="JsonSerializerOptions.Web"/> so that
    /// column names and their order are derived from the actual JSON output, regardless of the
    /// original object type or naming conventions.
    /// </summary>
    public ToolResult(IEnumerable<object> data, string description)
    {
        ArgumentNullException.ThrowIfNull(data);

        var json = JsonSerializer.Serialize(data, JsonSerializerOptions.Web);

        using var doc = JsonDocument.Parse(json);
        var array = doc.RootElement;

        var columns = array.GetArrayLength() > 0 && array[0].ValueKind is JsonValueKind.Object
            ? array[0].EnumerateObject().Select(p => p.Name).ToArray()
            : [];

        Description = description;
        ContentType = ContentTypes.List;
        RowCount = array.GetArrayLength();
        Columns = columns;
        Data = json;
    }

    /// <summary>
    /// Creates a text result containing free-form or markdown content.
    /// </summary>
    public ToolResult(string data, string description)
    {
        ArgumentNullException.ThrowIfNull(data);

        Description = description;
        ContentType = ContentTypes.Text;
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

        if (ContentType is ContentTypes.Table or ContentTypes.List)
        {
            builder.Append($", {RowCount} rows, columns: {string.Join(", ", Columns)}");
        }

        builder.Append(')');

        return builder.ToString();
    }
}
