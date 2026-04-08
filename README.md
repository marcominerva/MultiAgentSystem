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

## How the SQL Agent works

When the orchestrator delegates a data question to the SQL Agent, the following steps are executed:

1. **Table discovery** — A context provider (`SqlAgentContextProvider`) queries `INFORMATION_SCHEMA.TABLES` at the beginning of each turn and injects the list of available table names into the agent's prompt. The list is filtered according to the `IncludedTables` / `ExcludedTables` configuration.
2. **Schema retrieval** — The agent calls `GetDatabaseSchemaAsync` with the candidate table names identified from the user's question. The tool queries `INFORMATION_SCHEMA.COLUMNS` and `sys.foreign_keys` to return column names, data types, nullability, and foreign key relationships.
3. **Query generation** — Using the schema information, the agent generates a SQL `SELECT` query that answers the user's question.
4. **Query execution** — The agent calls `ExecuteQueryAsync` with the generated query. Before execution, the tool validates that the query is read-only by stripping comments and checking for forbidden keywords (`INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `TRUNCATE`, etc.). If a forbidden keyword is detected, the call is rejected. Results are returned as a JSON array of objects.

The agent is instructed to **always** retrieve the schema before generating a query, ensuring it works with the actual database structure rather than assumptions.

## How file export works

When a request involves file generation (e.g. *"export the products to Excel"*), the orchestrator chains the SQL Agent to retrieve data and then delegates to the Export Agent, which produces the file using the appropriate tool (`ExcelTools`, `WordTools`, or `PdfTools`).

### Artifact flow

File generation relies on a scoped artifact store that decouples tool execution from response handling:

1. **`AgentArtifact`** — A record that represents a file produced by a tool, holding the file name, its binary content, and deriving the MIME content type from the file extension.
2. **`AgentArtifactStore`** — A scoped, thread-safe store (backed by a `ConcurrentBag`) that collects artifacts produced during a single request. Each export tool pushes an `AgentArtifact` into the store after generating the file.
3. **Endpoint response** — After `RunAsync` completes, the `/api/chat` endpoint inspects the store:
   - **If artifacts are present**, the first artifact is returned as a binary file download. The agent's text response and the conversation ID are included in the `x-response` and `x-conversation-id` response headers respectively.
   - **If no artifacts are present**, the agent's text response is returned as a standard JSON body.

This design keeps the tools unaware of HTTP concerns, while giving the endpoint full control over how files are delivered to the client.

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

The `conversationId` is optional on the first request and returned in the response to maintain conversation context across subsequent calls.

### Text response

When the agent answers with plain text, the endpoint returns a JSON body:

```json
{
    "conversationId": "a1b2c3d4e5f6...",
    "response": "The most expensive product is ...",
    "totalTokenCount": 1234
}
```

| Field | Description |
|---|---|
| `conversationId` | The conversation identifier to pass in subsequent requests. |
| `response` | The agent's text answer. |
| `totalTokenCount` | Total tokens consumed by the request (prompt + completion). |

### File response

When the agent produces a file (Excel, Word, PDF), the HTTP response body contains the **binary file content** with the appropriate `Content-Type` and `Content-Disposition` headers. The agent's text message and conversation ID are returned in custom response headers:

| Header | Description |
|---|---|
| `x-response` | The agent's text description of the generated file (URL-encoded). |
| `x-conversation-id` | The conversation identifier to pass in subsequent requests. |
| `x-total-token-count` | Total tokens consumed by the request (prompt + completion). |

A Swagger UI is available at the root URL for interactive testing.