using Microsoft.Agents.AI;
using Microsoft.Extensions.AI;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.ContextProviders;

/// <summary>
/// Injects a summary of all stored <see cref="ToolResult"/> items into the conversation context
/// so the LLM can reference content IDs across turns, even after chat history reduction.
/// </summary>
public class ContentStoreContextProvider(IContentStore contentStore) : MessageAIContextProvider
{
    protected override async ValueTask<IEnumerable<ChatMessage>> ProvideMessagesAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        var results = await contentStore.GetAllAsync();
        var summaries = results.Select(r => r.ToString());

        if (!summaries.Any())
        {
            return [];
        }

        var message = $"""
            The following stored results are available for export or further processing:
            {string.Join(Environment.NewLine, summaries)}
            When the user asks to export or reference previous data, if available use the corresponding ContentId.
            """;

        return [new(ChatRole.User, message)];
    }
}
