using System.Collections.Concurrent;

namespace MultiAgentSystem.AgentArtifacts;

/// <summary>
/// Cache for temporary artifact downloads produced during streaming agent runs.
/// Artifacts are stored with a short TTL so they can be retrieved by the browser immediately after the stream ends.
/// </summary>
public interface IArtifactDownloadCache
{
    /// <summary>
    /// Stores an <see cref="AgentArtifact"/> in the cache, associating it with the specified identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the artifact.</param>
    /// <param name="artifact">The artifact to store.</param>
    /// <param name="cancellationToken">A token to cancel the operation.</param>
    Task SetAsync(string id, AgentArtifact artifact, CancellationToken cancellationToken = default);

    /// <summary>
    /// Retrieves the <see cref="AgentArtifact"/> associated with the specified identifier, if it exists and has not expired.
    /// </summary>
    /// <param name="id">The unique identifier of the artifact.</param>
    /// <param name="cancellationToken">A token to cancel the operation.</param>
    /// <returns>The cached artifact, or <see langword="null"/> if it does not exist or has expired.</returns>
    Task<AgentArtifact?> GetAsync(string id, CancellationToken cancellationToken = default);
}

/// <summary>
/// In-memory implementation of <see cref="IArtifactDownloadCache"/> backed by a <see cref="ConcurrentDictionary{TKey, TValue}"/>.
/// </summary>
/// <remarks>
/// Each call to <see cref="GetAsync"/> also evicts any entry whose TTL has expired, preventing the cache from growing unbounded.
/// </remarks>
public sealed class InMemoryArtifactDownloadCache(TimeProvider timeProvider) : IArtifactDownloadCache
{
    private static readonly TimeSpan ttl = TimeSpan.FromMinutes(5);

    private readonly ConcurrentDictionary<string, CachedArtifact> cache = new();

    public Task SetAsync(string id, AgentArtifact artifact, CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(id);
        ArgumentNullException.ThrowIfNull(artifact);

        cache[id] = new CachedArtifact(artifact, timeProvider.GetUtcNow().Add(ttl));
        return Task.CompletedTask;
    }

    public Task<AgentArtifact?> GetAsync(string id, CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(id);

        var now = timeProvider.GetUtcNow();

        // Evict every entry older than the TTL to keep the cache bounded.
        foreach (var entry in cache)
        {
            if (entry.Value.ExpiresAt <= now)
            {
                cache.TryRemove(entry.Key, out _);
            }
        }

        if (cache.TryRemove(id, out var cached) && cached.ExpiresAt > now)
        {
            return Task.FromResult<AgentArtifact?>(cached.Artifact);
        }

        return Task.FromResult<AgentArtifact?>(null);
    }

    private sealed record CachedArtifact(AgentArtifact Artifact, DateTimeOffset ExpiresAt);
}
