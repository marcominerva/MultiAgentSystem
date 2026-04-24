using System.ClientModel;
using System.ClientModel.Primitives;
using Microsoft.Agents.AI;
using Microsoft.Agents.AI.Hosting;
using Microsoft.Extensions.AI;
using MimeMapping;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.ContextProviders;
using MultiAgentSystem.Logging;
using MultiAgentSystem.Models;
using MultiAgentSystem.Settings;
using MultiAgentSystem.Stores;
using MultiAgentSystem.Tools;
using OpenAI;
using OpenAI.Responses;
using TinyHelpers.AspNetCore.Extensions;
using ChatResponse = MultiAgentSystem.Models.ChatResponse;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddJsonFile("appsettings.local.json", optional: true, reloadOnChange: true);

// Add services to the container.
builder.Services.AddHttpClient();

var openAISettings = builder.Services.ConfigureAndGet<AzureOpenAISettings>(builder.Configuration, "AzureOpenAI")!;

builder.Services.AddSingleton(_ =>
{
    // Endpoint must end with /openai/v1 for Azure OpenAI.
    var openAIClient = new OpenAIClient(new ApiKeyCredential(openAISettings.ApiKey), new()
    {
        Endpoint = new(openAISettings.Endpoint),
        Transport = new HttpClientPipelineTransport(new HttpClient(new TraceHttpClientHandler()))
    });

    return openAIClient;
});

builder.Services.AddChatClient(services =>
{
    var openAIClient = services.GetRequiredService<OpenAIClient>();
    return openAIClient.GetResponsesClient().AsIChatClientWithStoredOutputDisabled(openAISettings.Deployment);
});

_ = builder.Services.ConfigureAndGet<SqlAgentSettings>(builder.Configuration, nameof(SqlAgentSettings))!;

// Register Context Providers as scoped, because they might have dependencies that are scoped, such as a DbContext for retrieving information from a database.
builder.Services.AddScoped<UserContextProvider>();
builder.Services.AddScoped<SqlAgentContextProvider>();
builder.Services.AddScoped<ExportingContextProvider>();

builder.Services.AddScoped<AgentArtifactStore>();

// Register the content store and its provider as singletons, so the stored content is shared across all sessions and conversations, and can be referenced by contentId over multiple turns and by different agents.
builder.Services.AddSingleton<ContentStoreContextProvider>();
builder.Services.AddSingleton<IContentStore, InMemoryContentStore>();

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
        Description = "Specialist agent for querying the database. Only use this tool when the user explicitly asks about suppliers, products, or categories stored in the database. Do not use for general knowledge questions.",
        ChatOptions = new()
        {
            Instructions = """
                You are a SQL specialist agent. Your job is to:
                1. You receive the list of available tables in the database from context. Based on the user's question, identify the candidate tables.
                2. Call GetDatabaseSchema with the candidate table names to retrieve their columns, data types, and relationships.
                3. Using the schema information, generate a SQL SELECT query that answers the user's question.
                4. Call ExecuteQuery with the generated query and return the results.
                Only generate SELECT queries. Never modify, insert, or delete data.
                Always call GetDatabaseSchema before generating a query.
                ExecuteQuery returns a result object with "contentId", "contentType", "rowCount", "columns", and "data".
                When presenting results to the user, always format the data as a readable markdown table showing ALL rows from the "data" array. Never summarize, truncate, or just describe the data — display it in full.
                Always include the contentId at the end of your response (e.g., "ContentId: abc12345") so other agents can retrieve the full dataset for export.
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
                You are an export specialist agent. Your job is to generate files.
                Choose the appropriate tool based on the user's requested format. If not specified, default to Excel.
                When a contentId is provided, always pass it to the tool so it reads data directly from the store. The store supports both tabular data and text/markdown content.
                Excel export only supports tabular data. For text content, use Word or PDF instead.
                Never fabricate, invent, or assume data. If no data is provided and no contentId is available, report the issue instead of making up data.
                Apply any formatting or presentation instructions provided by the user.
                When you generate a file, just briefly describe its content. Never mention that the file can be downloaded, never include download links or sandbox paths.
                After presenting results, STOP. Never append follow-up offers, suggestions, or prompts (e.g., "Let me know if...", "Would you like...", "I can also...", "If you want...", "If you need..."). End with the answer itself.
                """,
            Tools = [AIFunctionFactory.Create(services.GetRequiredService<ExcelTools>().GenerateExcelAsync),
                AIFunctionFactory.Create(services.GetRequiredService<WordTools>().GenerateWordAsync),
                AIFunctionFactory.Create(services.GetRequiredService<PdfTools>().GeneratePdfAsync)]
        },
        AIContextProviders = [services.GetRequiredService<ExportingContextProvider>(),
            services.GetRequiredService<ContentStoreContextProvider>()]
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

                When a request involves generating a file (e.g., Excel, CSV, Word, PDF), use the code interpreter tool to write and execute the code that produces the file. Invoke the code interpreter immediately — never describe what you plan to do before calling it.
                When a request requires both data retrieval and file generation (e.g., "create an excel with the products"), first call the data-retrieval tool to obtain the data, then pass the full result set to the code interpreter to generate the file.

                CRITICAL: You do NOT know the current date or time. Your training data has a cutoff date.
                Before answering ANY question involving time references (e.g., 'last X years', 'recent', 'latest', 'current year', 'since', 'until now'), you MUST call GetCurrentDateTime first to determine today's date.

                Use UTC by default. Ask the user for their time zone only when exact local time is needed
                (e.g., scheduling, alarms) and it is not already known.

                After presenting results, STOP. Never append follow-up offers, suggestions, or prompts (e.g., "Let me know if...", "Would you like...", "I can also...", "If you want...", "If you need..."). End with the answer itself.
                """,
            Tools = [AIFunctionFactory.Create(DateTimeTools.GetCurrentDateTime),
                sqlAgent.AsAIFunction(),
                new HostedCodeInterpreterTool()]
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

app.MapPost("/api/chat", async Task<IResult> (HttpContext httpContext, ChatRequest request, [FromKeyedServices("MainAgent")] AIAgent agent, [FromKeyedServices("MainAgent")] AgentSessionStore store, AgentArtifactStore artifactStore,
    OpenAIClient openAIClient) =>
{
    var conversationId = request.ConversationId ?? Guid.NewGuid().ToString("N");
    var session = await store.GetSessionAsync(agent, conversationId);

    var response = await agent.RunAsync(request.Message, session);

    await store.SaveSessionAsync(agent, conversationId, session);

    foreach (var annotation in response.Messages.SelectMany(m => m.Contents).SelectMany(c => c.Annotations ?? []))
    {
        if (annotation.RawRepresentation is ContainerFileCitationMessageAnnotation containerFileCitation)
        {
            var containerClient = openAIClient.GetContainerClient();
            var fileContent = await containerClient.DownloadContainerFileAsync(containerFileCitation.ContainerId, containerFileCitation.FileId);

            // If a file was produced, return it as a download with the agent response in a header.
            httpContext.Response.Headers["x-response"] = Uri.EscapeDataString(response.Text).Replace("%20", " ");
            httpContext.Response.Headers["x-conversation-id"] = conversationId;
            httpContext.Response.Headers["x-token-count"] = (response.Usage?.TotalTokenCount ?? 0).ToString();

            return TypedResults.File(fileContent.Value.ToArray(), MimeUtility.GetMimeMapping(containerFileCitation.Filename), containerFileCitation.Filename);
        }
    }

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