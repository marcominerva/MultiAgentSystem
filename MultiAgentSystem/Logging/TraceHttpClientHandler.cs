using System.Text.Encodings.Web;
using System.Text.Json;

namespace MultiAgentSystem.Logging;

public class TraceHttpClientHandler : HttpClientHandler
{
    private static readonly JsonSerializerOptions jsonSerializerOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var requestString = request.Content is null ? "(no request body)" : await request.Content.ReadAsStringAsync(cancellationToken);

        PrintText($"Raw Request ({request.RequestUri})", ConsoleColor.Green);
        PrintText(FormatJson(requestString), ConsoleColor.DarkGray);
        PrintSeparator();

        var response = await base.SendAsync(request, cancellationToken);

        return response;

        static void PrintText(string message, ConsoleColor color)
        {
            var originalColor = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.WriteLine(message);
            Console.ForegroundColor = originalColor;
        }

        static void PrintSeparator() => Console.WriteLine(new string('-', 50));
    }

    private static string FormatJson(string input)
    {
        try
        {
            var jsonElement = JsonSerializer.Deserialize<JsonElement>(input);
            return JsonSerializer.Serialize(jsonElement, jsonSerializerOptions);
        }
        catch
        {
            return input;
        }
    }
}