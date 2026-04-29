using Microsoft.Agents.AI;

namespace MultiAgentSystem.ContextProviders;

public class UserContextProvider : AIContextProvider
{
    protected override ValueTask<AIContext> ProvideAIContextAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        // Get relevant information from a knowledge base or other source. Here we hardcode it for simplicity.
        var aiContext = new AIContext()
        {
            Instructions = """
                ## User Context:
                Name: Marco
                Timezone: Italy
                """
        };

        return ValueTask.FromResult(aiContext);
    }
}
