namespace AgentWithTools.Models;

public record class ChatResponse(string ConversationId, string Response, long TotalTokenCount);
