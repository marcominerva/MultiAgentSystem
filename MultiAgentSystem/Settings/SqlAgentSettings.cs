namespace MultiAgentSystem.Settings;

public class SqlAgentSettings
{
    public string ConnectionString { get; init; } = null!;

    public string? SystemMessage { get; init; }

    public string[] IncludedTables { get; init; } = [];

    public string[] ExcludedTables { get; init; } = [];

    public string[] ExcludedColumns { get; init; } = [];

    public int MaxRetries { get; init; } = 3;
}
