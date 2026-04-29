using Microsoft.Agents.AI;

namespace MultiAgentSystem.ContextProviders;

public class ExportingContextProvider : AIContextProvider
{
    protected override ValueTask<AIContext> ProvideAIContextAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        // Get relevant information from a knowledge base or other source. Here we hardcode it for simplicity.
        var aiContext = new AIContext()
        {
            Instructions = """
                ## Exporting Rules:            
                - If there are currencies in the data, define them as currency in € format. All currencies must be expressed in Euros, including the related labels.
                """
        };

        return ValueTask.FromResult(aiContext);
    }
}