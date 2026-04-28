using System.Text.Json;

namespace MultiAgentSystem.Stores;

/// <summary>
/// Defines the content type identifiers used by <see cref="IContentStore"/> to distinguish
/// how the payload stored in a <see cref="Models.ToolResult"/> should be interpreted.
/// </summary>
internal static class ContentTypes
{
    /// <summary>
    /// Tabular data produced by a database query. The payload is a JSON array of homogeneous objects
    /// whose keys are the column names returned by the query.
    /// </summary>
    public const string Table = "table";

    /// <summary>
    /// A JSON object list produced from an <see cref="IEnumerable{T}"/> of objects.
    /// The payload is a JSON array serialized with <see cref="JsonSerializerOptions.Web"/>;
    /// column names are derived from the JSON property names of the first element.
    /// </summary>
    public const string List = "list";

    /// <summary>
    /// Free-form text or markdown content. The payload is stored as a plain string.
    /// </summary>
    public const string Text = "text";
}
