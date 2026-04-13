using System.ComponentModel;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;
using DocSharp.Markdown;

namespace MultiAgentSystem.Tools;

public sealed class WordTools(AgentArtifactStore artifactStore, ContentStore contentStore)
{
    [Description("""
        Generates a Word file (.docx) from markdown content.
        Use for narrative or free-form content such as stories, reports, or letters.
        Do NOT use this for tabular data that has a Content ID — use GenerateWordFromContent instead.
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

    [Description("""
        Generates a Word document with a formatted table from previously stored structured data (e.g., query results) identified by a Content ID.
        Use this instead of GenerateWord when exporting tabular data.
        The tool reads ALL data from the store — nothing is truncated.
        Bold and italic styles are applied via markdown. Colors are not supported in Word tables.
        """)]
    public string GenerateWordFromContent(
        [Description("The Content ID of the stored data.")] string contentId,
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("Optional title displayed above the table.")] string? title,
        [Description("Column definitions specifying which fields to include, display headers, and unconditional styles.")] RenderColumn[] columns,
        [Description("Optional conditional formatting rules (bold/italic only in Word).")] ConditionalRule[]? rules = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(contentId);
        ArgumentNullException.ThrowIfNull(columns);

        var json = contentStore.Get(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        var markdownContent = MarkdownTableBuilder.Build(json, title, columns, rules);

        var markdown = MarkdownSource.FromMarkdownString(markdownContent);

        var converter = new MarkdownConverter();
        var docx = converter.ToDocxBytes(markdown);

        artifactStore.Add(new($"{fileName}.docx", docx));

        return description;
    }
}