using System.Collections.Concurrent;
using System.Text.Json;
using Microsoft.Agents.AI;
using Microsoft.Agents.AI.Hosting;

namespace AgentWithTools.Stores;

public class InMemorySessionStore : AgentSessionStore
{
    private readonly ConcurrentDictionary<string, JsonElement> sessions = new();

    public override async ValueTask<AgentSession> GetSessionAsync(AIAgent agent, string conversationId, CancellationToken cancellationToken = default)
    {
        JsonElement? sessionContent = sessions.TryGetValue(conversationId, out var session) ? session : null;

        return sessionContent switch
        {
            null => await agent.CreateSessionAsync(cancellationToken),
            _ => await agent.DeserializeSessionAsync(sessionContent.Value, cancellationToken: cancellationToken),
        };
    }

    public override async ValueTask SaveSessionAsync(AIAgent agent, string conversationId, AgentSession session, CancellationToken cancellationToken = default)
        => sessions[conversationId] = await agent.SerializeSessionAsync(session, cancellationToken: cancellationToken);
}
