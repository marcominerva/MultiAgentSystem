using System.Collections.Concurrent;
using MultiAgentSystem.AgentArtifacts;

namespace MultiAgentSystem.Stores;

/// <summary>
/// Singleton in-memory cache for temporary artifact downloads produced during streaming agent runs.
/// Artifacts are stored with a short TTL so they can be retrieved by the browser immediately after the stream ends.
/// </summary>
public sealed class ArtifactDownloadCache
{
    private readonly ConcurrentDictionary<string, CachedArtifact> cache = new();

    public void Store(string id, AgentArtifact artifact) => cache[id] = new CachedArtifact(artifact, DateTimeOffset.UtcNow.AddMinutes(5));

    public AgentArtifact? Get(string id)
    {
        if (cache.TryGetValue(id, out var cached) && cached.ExpiresAt > DateTimeOffset.UtcNow)
        {
            cache.TryRemove(id, out _);
            return cached.Artifact;
        }

        return null;
    }

    private sealed record CachedArtifact(AgentArtifact Artifact, DateTimeOffset ExpiresAt);
}
