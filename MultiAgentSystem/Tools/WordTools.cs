using System.ComponentModel;
using DocSharp.Markdown;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Extensions;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;

namespace MultiAgentSystem.Tools;

public sealed class WordTools(AgentArtifactStore artifactStore, IContentStore contentStore)
{
    [Description("""
        Generates a Word document (.docx).
        If a contentId is provided, the tool reads content directly from the store — for tabular data it renders a formatted table (nothing is truncated), for text it renders the stored markdown.
        Provide columns and optional rules to control layout and conditional formatting for tabular data.
        If no contentId is provided, provide markdown content directly (for narrative text, stories, reports, or any free-form content).
        """)]
    public async Task<string> GenerateWordAsync(
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The Content ID of previously stored data. When provided, the tool reads data from the store and 'content' is ignored.")] string? contentId = null,
        [Description("Column definitions for content-based export: which fields to include, display headers, unconditional styles. Required when contentId refers to tabular data.")] RenderColumn[]? columns = null,
        [Description("Optional cell-level formatting rules for content-based export (bold/italic only in Word). Used only when contentId is provided with tabular data.")] CellRule[]? rules = null,
        [Description("Optional title displayed above the table when using contentId with tabular data.")] string? title = null,
        [Description("Markdown content for narrative/free-form documents. Used only when no contentId is provided.")] string? content = null)
    {
        var markdownContent = !string.IsNullOrWhiteSpace(contentId)
            ? await BuildFromStoreAsync(contentId, title, columns ?? [], rules)
            : content ?? string.Empty;

        var markdown = MarkdownSource.FromMarkdownString(markdownContent);

        var converter = new MarkdownConverter();
        var docx = converter.ToDocxBytes(markdown);

        artifactStore.Add(new($"{fileName}.docx", docx));

        return description;
    }

    private async Task<string> BuildFromStoreAsync(string contentId, string? title, RenderColumn[] columns, CellRule[]? rules)
    {
        var stored = await contentStore.GetAsync(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        return stored.ContentType is "table"
            ? MarkdownTableBuilder.Build((string)stored.Data, title, columns, rules)
            : (string)stored.Data;
    }
}