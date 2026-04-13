using System.ComponentModel;
using DocSharp.Markdown;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Tools;

public sealed class WordTools(AgentArtifactStore artifactStore, ITableContentStore tableContentStore)
{
    [Description("""
        Generates a Word document (.docx).
        If a contentId is provided, the tool reads ALL rows directly from the store and renders a formatted table — nothing is truncated. Provide columns and optional rules to control layout and conditional formatting.
        If no contentId is provided, provide markdown content directly (for narrative text, stories, reports, or any free-form content).
        """)]
    public async Task<string> GenerateWordAsync(
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The Content ID of previously stored tabular data. When provided, the tool reads data from the store and 'content' is ignored.")] string? contentId = null,
        [Description("Column definitions for content-based export: which fields to include, display headers, unconditional styles. Required when contentId is provided.")] RenderColumn[]? columns = null,
        [Description("Optional conditional formatting rules for content-based export (bold/italic only in Word).")] ConditionalRule[]? rules = null,
        [Description("Optional title displayed above the table when using contentId.")] string? title = null,
        [Description("Markdown content for narrative/free-form documents. Used only when no contentId is provided.")] string? content = null)
    {
        var markdownContent = !string.IsNullOrWhiteSpace(contentId)
            ? await BuildFromContentTableAsync(contentId, title, columns ?? [], rules)
            : content ?? string.Empty;

        var markdown = MarkdownSource.FromMarkdownString(markdownContent);

        var converter = new MarkdownConverter();
        var docx = converter.ToDocxBytes(markdown);

        artifactStore.Add(new($"{fileName}.docx", docx));

        return description;
    }

    private async Task<string> BuildFromContentTableAsync(string contentId, string? title, RenderColumn[] columns, ConditionalRule[]? rules)
    {
        var json = await tableContentStore.GetAsync(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        return MarkdownTableBuilder.Build(json, title, columns, rules);
    }
}