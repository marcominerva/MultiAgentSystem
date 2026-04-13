using System.ComponentModel;
using System.Text.RegularExpressions;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Options;
using MultiAgentSystem.Settings;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Tools;

/// <summary>
/// Provides tools for natural language to SQL query workflows.
/// </summary>
public sealed partial class SqlTools(IOptions<SqlAgentSettings> options, ITableContentStore tableContentStore)
{
#pragma warning disable IDE0028 // Simplify collection initialization
    private static readonly HashSet<string> forbiddenKeywords = new(StringComparer.OrdinalIgnoreCase)
#pragma warning restore IDE0028 // Simplify collection initialization
    {
        "INSERT", "UPDATE", "DELETE", "DROP", "ALTER", "TRUNCATE",
        "CREATE", "EXEC", "EXECUTE", "MERGE", "GRANT", "REVOKE",
        "DENY"
    };

    private readonly SqlAgentSettings settings = options.Value;

    [Description("Retrieves columns, data types, and foreign key relationships for the specified tables. Call this to understand the structure before generating a query.")]
    public async Task<DatabaseSchema> GetDatabaseSchemaAsync(
        [Description("Fully qualified table names (e.g. 'dbo.Products', 'dbo.Categories') whose schema should be retrieved.")] string[] tableNames, CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(tableNames);

        await using var connection = new SqlConnection(settings.ConnectionString);

        var columnsQuery = """
            SELECT
                TABLE_SCHEMA AS TableSchema,
                TABLE_NAME AS TableName,
                COLUMN_NAME AS ColumnName,
                DATA_TYPE AS DataType,
                IS_NULLABLE AS IsNullable
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA + '.' + TABLE_NAME IN @tableNames
            ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION
            """;

        var columns = await connection.QueryAsync<ColumnSchema>(new(columnsQuery, new { tableNames }, cancellationToken: cancellationToken));

        var fkQuery = """
            SELECT
                fk.name AS FkName,
                OBJECT_SCHEMA_NAME(fk.parent_object_id) + '.' + OBJECT_NAME(fk.parent_object_id) AS FkTable,
                COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS FkColumn,
                OBJECT_SCHEMA_NAME(fk.referenced_object_id) + '.' + OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
                COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn
            FROM sys.foreign_keys fk
            INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
            WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) + '.' + OBJECT_NAME(fk.parent_object_id) IN @tableNames
                OR OBJECT_SCHEMA_NAME(fk.referenced_object_id) + '.' + OBJECT_NAME(fk.referenced_object_id) IN @tableNames
            """;

        var foreignKeys = await connection.QueryAsync<ForeignKeySchema>(fkQuery, new { tableNames });

        return new DatabaseSchema(columns, foreignKeys);
    }

    [Description("Executes a read-only SQL SELECT query against the database. Returns a result object with a contentId for cross-agent data transfer, rowCount, and the full data array.")]
    public async Task<QueryResult> ExecuteQueryAsync(
        [Description("The SQL SELECT query to execute. Must not contain INSERT, UPDATE, DELETE, DROP, or any other data-modification statement.")] string sqlQuery, CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sqlQuery);

        if (!IsReadOnlyQuery(sqlQuery))
        {
            throw new InvalidOperationException("Only SELECT queries are allowed. Data-modification statements are forbidden.");
        }

        await using var connection = new SqlConnection(settings.ConnectionString);

        var results = (await connection.QueryAsync(new(sqlQuery, cancellationToken: cancellationToken))).AsList();
        var columnNames = results.Count > 0 ? ((IDictionary<string, object>)results[0]).Keys : [];
        var contentId = await tableContentStore.StoreAsync(results);

        return new QueryResult(contentId, results.Count, columnNames, results);
    }

    private static bool IsReadOnlyQuery(string sql)
    {
        // Strip single-line and multi-line comments, then check for forbidden keywords as whole words.
        var cleaned = StripComments(sql);
        return !forbiddenKeywords.Any(keyword => ForbiddenKeywordRegex(keyword).IsMatch(cleaned));
    }

    private static string StripComments(string sql)
    {
        var result = SingleLineCommentPattern().Replace(sql, " ");
        result = MultiLineCommentPattern().Replace(result, " ");
        return result;
    }

    private static Regex ForbiddenKeywordRegex(string keyword)
        => new($@"\b{Regex.Escape(keyword)}\b", RegexOptions.IgnoreCase, TimeSpan.FromSeconds(1));

    [GeneratedRegex(@"--[^\r\n]*")]
    private static partial Regex SingleLineCommentPattern();

    [GeneratedRegex(@"/\*[\s\S]*?\*/")]
    private static partial Regex MultiLineCommentPattern();
}

/// <summary>
/// Represents a column in a database table schema.
/// </summary>
public record class ColumnSchema(string TableSchema, string TableName, string ColumnName, string DataType, string IsNullable);

/// <summary>
/// Represents a foreign key relationship between database tables.
/// </summary>
public record class ForeignKeySchema(string FkName, string FkTable, string FkColumn, string ReferencedTable, string ReferencedColumn);

/// <summary>
/// Contains the complete schema information including columns and foreign key relationships for a set of database tables.
/// </summary>
/// <param name="Columns">The column definitions for the requested tables.</param>
/// <param name="ForeignKeys">The foreign key relationships involving the requested tables.</param>
public record class DatabaseSchema(IEnumerable<ColumnSchema> Columns, IEnumerable<ForeignKeySchema> ForeignKeys);

/// <summary>
/// Represents the result of a SQL query execution, including metadata and the full data array.
/// </summary>
/// <param name="ContentId">The Content ID for cross-agent data transfer. Export tools use this to retrieve the full dataset.</param>
/// <param name="RowCount">The number of rows returned by the query.</param>
/// <param name="Columns">The column names in the result set.</param>
/// <param name="Data">The full data array returned by the query.</param>
public record class QueryResult(
    [property: Description("The Content ID for cross-agent data transfer. Export tools use this to retrieve the full dataset.")] string ContentId,
    [property: Description("The number of rows returned by the query.")] int RowCount,
    [property: Description("The column names in the result set.")] IEnumerable<string> Columns,
    [property: Description("The full data array returned by the query.")] object Data);
