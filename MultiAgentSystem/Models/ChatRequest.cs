using System.ComponentModel.DataAnnotations;

namespace MultiAgentSystem.Models;

public record class ChatRequest(string? ConversationId, [Required] string Message);
