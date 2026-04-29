using Microsoft.Agents.AI;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.ContextProviders;

/// <summary>
/// Injects a summary of all stored <see cref="ToolResult"/> items into the conversation context
/// so the LLM can reference content IDs across turns, even after chat history reduction.
/// </summary>
public class ContentStoreContextProvider(IContentStore contentStore) : AIContextProvider
{
    protected override async ValueTask<AIContext> ProvideAIContextAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        var results = await contentStore.GetAllAsync(cancellationToken);
        var summaries = results.Select(r => r.ToString()).ToList();

        if (summaries.Count == 0)
        {
            return new AIContext();
        }

        var aiContext = new AIContext()
        {
            Instructions = $"""
                ## Content Store Information:
                The following stored results are available for export or further processing:
                {string.Join(Environment.NewLine, summaries)}
                When the user asks to export or reference previous data, if available use the corresponding ContentId.
                """
        };

        return aiContext;
    }
}
