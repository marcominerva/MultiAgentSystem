using MimeMapping;

namespace AgentWithTools.AgentArtifacts;

/// <summary>
/// Represents a file artifact produced by a tool during an agent run.
/// </summary>
public record class AgentArtifact(string FileName, byte[] Content)
{
    public string ContentType => MimeUtility.GetMimeMapping(FileName);
}