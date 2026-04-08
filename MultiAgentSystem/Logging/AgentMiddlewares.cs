using System.Text;
using Microsoft.Agents.AI;
using Microsoft.Extensions.AI;

namespace AgentWithTools.Logging;

public static class AgentMiddlewares
{
    public static async ValueTask<object?> ToolCallMiddleware(AIAgent agent, FunctionInvocationContext context, Func<FunctionInvocationContext, CancellationToken, ValueTask<object?>> next, CancellationToken cancellationToken)
    {
        var functionCallDetails = new StringBuilder();
        functionCallDetails.Append($"[{agent.Name}] Tool Call: '{context.Function.Name}'");

        if (context.Arguments.Count > 0)
        {
            functionCallDetails.Append($" (Args: {string.Join(",", context.Arguments.Select(x => $"[{x.Key} = {x.Value}]"))}");
        }

        var originalColor = Console.ForegroundColor;
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine(functionCallDetails.ToString());
        Console.WriteLine();
        Console.ForegroundColor = originalColor;

        return await next(context, cancellationToken);
    }
}
