using System.ComponentModel;
using MultiAgentSystem.AgentArtifacts;
using DocSharp.Markdown;

namespace MultiAgentSystem.Tools;

public sealed class WordTools(AgentArtifactStore artifactStore)
{
    [Description("""
        Generates a Word file (.docx) from data.
        Use when the user asks to create, export, or save data as a Word document.
        """)]
    public string GenerateWord(
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The markdown content of the file.")] string content)
    {
        var markdown = MarkdownSource.FromMarkdownString(content);

        var converter = new MarkdownConverter();
        var docx = converter.ToDocxBytes(markdown);

        artifactStore.Add(new($"{fileName}.docx", docx));

        return description;
    }
}