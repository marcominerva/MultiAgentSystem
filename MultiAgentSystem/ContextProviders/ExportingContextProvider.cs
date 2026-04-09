using Microsoft.Agents.AI;
using Microsoft.Extensions.AI;

namespace MultiAgentSystem.ContextProviders;

public class ExportingContextProvider : MessageAIContextProvider
{
    protected override ValueTask<IEnumerable<ChatMessage>> ProvideMessagesAsync(InvokingContext context, CancellationToken cancellationToken = default)
    {
        // Get relevant information from a knowledge base or other source. Here we hardcode it for simplicity.
        return ValueTask.FromResult<IEnumerable<ChatMessage>>(
            [new(ChatRole.User, "If there are currencies in the data, define them as currency in € format. All currencies must be expressed in Euros, including the related labels.")]
        );
    }
}