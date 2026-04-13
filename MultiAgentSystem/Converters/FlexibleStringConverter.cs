using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace MultiAgentSystem.Converters;

public sealed class FlexibleStringConverter : JsonConverter<string?>
{
    public override string? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        return reader.TokenType switch
        {
            JsonTokenType.Null => null,
            _ => Encoding.UTF8.GetString(reader.ValueSpan)
        };
    }

    public override void Write(Utf8JsonWriter writer, string? value, JsonSerializerOptions options) => writer.WriteStringValue(value);
}