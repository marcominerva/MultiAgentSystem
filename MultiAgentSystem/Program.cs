using System.ClientModel;
using System.ClientModel.Primitives;
using AgentWithTools.AgentArtifacts;
using AgentWithTools.ContextProviders;
using AgentWithTools.Logging;
using AgentWithTools.Models;
using AgentWithTools.Settings;
using AgentWithTools.Stores;
using AgentWithTools.Tools;
using Microsoft.Agents.AI;
using Microsoft.Agents.AI.Hosting;
using Microsoft.Extensions.AI;
using OpenAI;
using TinyHelpers.AspNetCore.Extensions;
using ChatResponse = AgentWithTools.Models.ChatResponse;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.local.json", optional: true, reloadOnChange: true);

// Add services to the container.
builder.Services.AddHttpClient();

var openAISettings = builder.Services.ConfigureAndGet<AzureOpenAISettings>(builder.Configuration, "AzureOpenAI")!;
builder.Services.AddChatClient(_ =>
{
    // Endpoint must end with /openai/v1 for Azure OpenAI.
    var openAIClient = new OpenAIClient(new ApiKeyCredential(openAISettings.ApiKey), new()
    {
        Endpoint = new(openAISettings.Endpoint),
        Transport = new HttpClientPipelineTransport(new HttpClient(new TraceHttpClientHandler()))
    });

    return openAIClient.GetChatClient(openAISettings.Deployment).AsIChatClient();
});

_ = builder.Services.ConfigureAndGet<SqlAgentSettings>(builder.Configuration, nameof(SqlAgentSettings))!;

// Register Context Providers as scoped, because they might have dependencies that are scoped, such as a DbContext for retrieving information from a database.
builder.Services.AddScoped<UserContextProvider>();
builder.Services.AddScoped<ExportingContextProvider>();
builder.Services.AddScoped<SqlAgentContextProvider>();

builder.Services.AddScoped<AgentArtifactStore>();
builder.Services.AddScoped<ExcelTools>();
builder.Services.AddScoped<WordTools>();
builder.Services.AddScoped<PdfTools>();
builder.Services.AddScoped<SqlTools>();

builder.Services.AddAIAgent("MainAgent", (services, key) =>
{
    var chatClient = services.GetRequiredService<IChatClient>();
    var loggerFactory = services.GetRequiredService<ILoggerFactory>();

    var chatHistoryProvider = new InMemoryChatHistoryProvider(new()
    {
        ChatReducer = new MessageCountingChatReducer(20),   //new SummarizingChatReducer(chatClient, 1, 10)
        ReducerTriggerEvent = InMemoryChatHistoryProviderOptions.ChatReducerTriggerEvent.AfterMessageAdded,
        //ProvideOutputMessageFilter = messages =>
        //{
        //    // This method is called BEFORE actually sends the messages to the LLM, so we can filter out messages that we don't want the LLM to use.
        //    return messages.Where(m => m.GetAgentRequestMessageSourceType() != AgentRequestMessageSourceType.ChatHistory
        //      && m.GetAgentRequestMessageSourceType() != AgentRequestMessageSourceType.AIContextProvider);
        //},
        StorageInputRequestMessageFilter = messages =>
        {
            // The messages list contains the request messages of the current turn, but it does not contain the response messages yet,
            // as we are still in the process of handling the request.
            // This method is called AFTER the response is received from the LLM, but before storing the response messages in the chat history,
            // so we can filter out request messages that we don't want to store.
            // For example, we can filter out messages from the AI Context Providers, as they can be re-generated if needed.
            // By default the chat history provider will store all messages, except for those that came from chat history in the first place.
            // We also want to maintain that exclusion here.
            return messages.Where(m => m.GetAgentRequestMessageSourceType() != AgentRequestMessageSourceType.ChatHistory
                && m.GetAgentRequestMessageSourceType() != AgentRequestMessageSourceType.AIContextProvider);
        }
    });

    // SQL specialist agent: retrieves database schema, generates and executes SQL queries.
    var sqlAgent = chatClient.AsAIAgent(new()
    {
        Id = "sql-agent",
        Name = "sql-agent",
        Description = "Specialist agent for querying databases about suppliers, products, categories, and any related data",
        ChatOptions = new()
        {
            Instructions = """
                You are a SQL specialist agent. Your job is to:
                1. You receive the list of available tables in the database from context. Based on the user's question, identify the candidate tables.
                2. Call GetDatabaseSchemaAsync with the candidate table names to retrieve their columns, data types, and relationships.
                3. Using the schema information, generate a SQL SELECT query that answers the user's question.
                4. Call ExecuteQueryAsync with the generated query and return the results.
                Only generate SELECT queries. Never modify, insert, or delete data.
                Always call GetDatabaseSchemaAsync before generating a query.
                After presenting results, STOP. Never append follow-up offers, suggestions, or prompts (e.g., "Let me know if...", "Would you like...", "I can also...", "If you want...", "If you need..."). End with the answer itself.
                """,
            Tools = [AIFunctionFactory.Create(services.GetRequiredService<SqlTools>().GetDatabaseSchemaAsync),
                AIFunctionFactory.Create(services.GetRequiredService<SqlTools>().ExecuteQueryAsync)]
        },
        AIContextProviders = [services.GetRequiredService<SqlAgentContextProvider>()]
    },
    loggerFactory: loggerFactory,
    services: services)
    .AsBuilder().Use(AgentMiddlewares.ToolCallMiddleware).Build();

    // Export specialist agent: generates files in various formats (Excel, Word, PDF, etc.).
    var exportAgent = chatClient.AsAIAgent(new()
    {
        Id = "export-agent",
        Name = "export-agent",
        Description = "Specialist agent for exporting data to files in various formats such as Excel, Word and PDF",
        ChatOptions = new()
        {
            Instructions = """
                You are an export specialist agent. Your job is to generate files from data provided to you.
                Choose the appropriate export tool based on the user's requested format.
                If the user does not specify a format, default to Excel.
                Choose appropriate column headers, data types, and formatting.
                IMPORTANT: Only use data that is explicitly provided in the message. Never generate, invent, or assume data. If no actual data is provided, ask for it instead of making it up.
                When you generate a file, just briefly describe its content. Never mention that the file can be downloaded, never include download links or sandbox paths.
                After presenting results, STOP. Never append follow-up offers, suggestions, or prompts (e.g., "Let me know if...", "Would you like...", "I can also...", "If you want...", "If you need..."). End with the answer itself.
                """,
            Tools = [AIFunctionFactory.Create(services.GetRequiredService<ExcelTools>().GenerateExcel),
                AIFunctionFactory.Create(services.GetRequiredService<WordTools>().GenerateWord),
                AIFunctionFactory.Create(services.GetRequiredService<PdfTools>().GeneratePdf)]
        },
        AIContextProviders = [services.GetRequiredService<ExportingContextProvider>()]
    },
    loggerFactory: loggerFactory,
    services: services)
    .AsBuilder().Use(AgentMiddlewares.ToolCallMiddleware).Build();

    // Orchestrator agent: handles general conversation and delegates to specialist agents exposed as tools.
    var orchestratorAgent = chatClient.AsAIAgent(new()
    {
        Id = "orchestrator-agent",
        Name = key,
        Description = "Routes messages to the appropriate specialist agent",
        ChatOptions = new()
        {
            Instructions = """
                You are a helpful assistant that provides concise and accurate information.
                You have access to specialist tools for specific domains. Use the tool whose description best matches the user's request.
                Delegate seamlessly: never mention, narrate, or explain the use of specialist tools to the user.

                You cannot create, convert, or export files yourself. Any file operation MUST be performed by invoking the appropriate specialist tool. When a tool is needed, invoke it immediately — never describe what you plan to do or list the data before calling the tool.
                When a request requires both data retrieval and file generation (e.g., "create an excel with the products"), you MUST chain the tools: first call the data-retrieval tool to obtain the data, then call the export tool passing the full results. Never ask the user to provide data that you can retrieve yourself.
                When delegating to a specialist tool, you MUST include all the actual data in your message. Specialist tools have no access to your conversation history, so they only see what you explicitly pass to them. Never refer to "the previous results" or "the data above" — always embed the full data.
                When the user references data or results from earlier in the conversation (e.g., "use those", "do it with the previous data", "apply that to…"), resolve the reference yourself by looking back through the conversation, extract the relevant information, and embed it in the tool call. Never ask the user to repeat information that is already present in the conversation history.

                CRITICAL: You do NOT know the current date or time. Your training data has a cutoff date.
                Before answering ANY question involving time references (e.g., 'last X years', 'recent', 'latest', 'current year', 'since', 'until now'), you MUST call GetCurrentDateTime first to determine today's date.
                
                Use UTC by default. Ask the user for their time zone only when exact local time is needed
                (e.g., scheduling, alarms) and it is not already known.

                After presenting results, STOP. Never append follow-up offers, suggestions, or prompts (e.g., "Let me know if...", "Would you like...", "I can also...", "If you want...", "If you need..."). End with the answer itself.
                When you generate a file, just briefly describe its content. Never mention that the file can be downloaded, never include download links or sandbox paths.
                """,
            Tools = [AIFunctionFactory.Create(DateTimeTools.GetCurrentDateTime),
                sqlAgent.AsAIFunction(),
                exportAgent.AsAIFunction()]
        },
        AIContextProviders = [services.GetRequiredService<UserContextProvider>()],
        ChatHistoryProvider = chatHistoryProvider
    },
    loggerFactory: loggerFactory,
    services: services)
    .AsBuilder().Use(AgentMiddlewares.ToolCallMiddleware).Build();

    return orchestratorAgent;

}, ServiceLifetime.Scoped)
.WithSessionStore((services, key) =>
{
    return new InMemorySessionStore();
});

builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseHttpsRedirection();

app.MapOpenApi();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/openapi/v1.json", app.Environment.ApplicationName);
});

app.MapPost("/api/chat", async Task<IResult> (HttpContext httpContext, ChatRequest request, [FromKeyedServices("MainAgent")] AIAgent agent, [FromKeyedServices("MainAgent")] AgentSessionStore store, AgentArtifactStore artifactStore) =>
{
    var conversationId = request.ConversationId ?? Guid.NewGuid().ToString("N");
    var session = await store.GetSessionAsync(agent, conversationId);

    var response = await agent.RunAsync(request.Message, session);

    await store.SaveSessionAsync(agent, conversationId, session);

    if (artifactStore.HasArtifacts)
    {
        // If a file was produced, return it as a download with the agent response in a header.
        httpContext.Response.Headers["x-response"] = Uri.EscapeDataString(response.Text).Replace("%20", " ");
        httpContext.Response.Headers["x-conversation-id"] = conversationId;
        httpContext.Response.Headers["x-token-count"] = (response.Usage?.TotalTokenCount ?? 0).ToString();

        var artifact = artifactStore.Artifacts[0];
        return TypedResults.File(artifact.Content, artifact.ContentType, artifact.FileName);
    }

    return TypedResults.Ok(new ChatResponse(conversationId, response.Text, response.Usage?.TotalTokenCount ?? 0));
})
.Produces<ChatResponse>();

app.Run();