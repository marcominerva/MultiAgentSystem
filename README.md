# .NET Multi Agent System

A multi-agent system built with .NET 10 and [Microsoft Agent Framework](https://github.com/microsoft/agent-framework) that uses Azure OpenAI to answer user questions through a chat API. The system is composed of an **orchestrator agent** that routes requests to specialized agents:

- **SQL Agent**: retrieves database schema, generates and executes SQL `SELECT` queries to answer questions about data stored in a SQL Server database.
- **Export Agent**: generates files in various formats (Excel, Word, PDF) from data provided by other agents or the user.

The orchestrator handles general conversation, automatically chains data retrieval and file generation when needed, and manages chat history with a configurable message reducer.

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0)
- An [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) resource with a deployed chat model
- A SQL Server or Azure SQL Database instance

## Database setup

The repository includes a `Scripts.sql` file that contains all the DDL statements to create the required tables (`Categories`, `Cities`, `Products`, `ProductSuppliers`, `Suppliers`) along with indexes, foreign keys, and a set of sample data. Run this script against your SQL Server database to get started:

```bash
sqlcmd -S <server> -d <database> -i Scripts.sql
```

## Configuration

Application settings are defined in `appsettings.json` (or, for local overrides, in `appsettings.local.json` which is not tracked by source control).

### Azure OpenAI

```json
"AzureOpenAI": {
    "Endpoint": "",
    "Deployment": "",
    "ApiKey": ""
}
```

| Property | Description |
|---|---|
| `Endpoint` | The full endpoint URL of your Azure OpenAI resource (e.g. `https://<resource-name>.openai.azure.com/openai/v1`). **Must** end with `/openai/v1`. |
| `Deployment` | The name of the deployed chat model (e.g. `gpt-4o`). |
| `ApiKey` | The API key for authenticating with the Azure OpenAI resource. |

### SQL Agent Settings

```json
"SqlAgentSettings": {
    "ConnectionString": "",
    "IncludedTables": [],
    "ExcludedTables": [ "dbo.__EFMigrationsHistory" ]
}
```

| Property | Description |
|---|---|
| `ConnectionString` | The ADO.NET connection string to the SQL Server database. |
| `IncludedTables` | An optional list of tables (in `schema.table` format, e.g. `"dbo.Products"`) to expose to the agent. When specified, **only** these tables will be visible. |
| `ExcludedTables` | An optional list of tables to hide from the agent. Ignored if `IncludedTables` is specified. |

> **Note**: `IncludedTables` and `ExcludedTables` are mutually exclusive. If `IncludedTables` contains any entry, `ExcludedTables` is ignored.

## Running the application

```bash
dotnet run --project MultiAgentSystem
```

The API exposes a single endpoint:

```
POST /api/chat
```

With a JSON body:

```json
{
    "message": "What are the most expensive products?",
    "conversationId": null
}
```

The `conversationId` is optional on the first request and returned in the response to maintain conversation context across subsequent calls. A Swagger UI is available at the root URL for interactive testing.