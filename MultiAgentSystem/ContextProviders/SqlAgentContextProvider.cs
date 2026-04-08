using AgentWithTools.Settings;
using Dapper;
using Microsoft.Agents.AI;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.AI;
using Microsoft.Extensions.Options;

namespace AgentWithTools.ContextProviders;

public class SqlAgentContextProvider(IOptions<SqlAgentSettings> options) : MessageAIContextProvider
{
    private readonly SqlAgentSettings settings = options.Value;

    protected override async ValueTask<IEnumerable<ChatMessage>> ProvideMessagesAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        await using var connection = new SqlConnection(settings.ConnectionString);

        var query = "SELECT QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) AS TABLES FROM INFORMATION_SCHEMA.TABLES";
        IEnumerable<string>? tablesToQuery = null;

        if (settings.IncludedTables?.Length > 0)
        {
            query = $"{query} WHERE TABLE_SCHEMA + '.' + TABLE_NAME IN @tables";
            tablesToQuery = settings.IncludedTables;
        }
        else if (settings.ExcludedTables?.Length > 0)
        {
            query = $"{query} WHERE TABLE_SCHEMA + '.' + TABLE_NAME NOT IN @tables";
            tablesToQuery = settings.ExcludedTables;
        }

        var tables = await connection.QueryAsync<string>(new(query, new { tables = tablesToQuery }, cancellationToken: cancellationToken));

        return [new(ChatRole.User, $"The database contains the following tables: {string.Join(", ", tables)}. Use these table names to identify which ones are relevant to the user's question.")];
    }
}
