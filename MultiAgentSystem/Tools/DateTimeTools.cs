using System.ComponentModel;

namespace MultiAgentSystem.Tools;

public static class DateTimeTools
{
    [Description("Returns the current date and time. ALWAYS call this tool FIRST when the question involves ANY time reference, including: current date/time ('today', 'now', 'current year'), relative periods ('recent', 'last/past X days/months/years', 'in the last decade'), time ranges that depend on today's date ('from 2020 to now', 'since January'), time calculations ('how long since', 'time elapsed'), or temporal filtering ('latest', 'newest', 'most recent'). You do NOT know the current date - you MUST call this tool to determine it.")]
    public static DateTimeOffset GetCurrentDateTime([Description("Optional time zone in IANA format (e.g., 'Europe/Rome'). Provide it only when the exact local time is required.")] string? timeZone = null)
    {
        var timeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(timeZone ?? "UTC");
        return TimeZoneInfo.ConvertTime(DateTimeOffset.Now, timeZoneInfo);
    }
}
