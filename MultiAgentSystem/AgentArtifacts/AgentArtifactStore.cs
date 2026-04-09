using System.Collections.Concurrent;

namespace MultiAgentSystem.AgentArtifacts;

/// <summary>
/// Scoped store that collects file artifacts produced by tool calls within a single request.
/// Tools push artifacts here; the endpoint inspects it after <c>RunAsync</c> to decide the response type.
/// </summary>
public sealed class AgentArtifactStore
{
    private readonly ConcurrentBag<AgentArtifact> artifacts = [];

    public void Add(AgentArtifact artifact) => artifacts.Add(artifact);

    public bool HasArtifacts => !artifacts.IsEmpty;

    public IReadOnlyList<AgentArtifact> Artifacts => [.. artifacts];
}