using System.ComponentModel;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using QuestPDF.Markdown;

namespace MultiAgentSystem.Tools;

public sealed class PdfTools(IHttpClientFactory httpClientFactory, AgentArtifactStore artifactStore, ContentStore contentStore)
{
    static PdfTools()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    [Description("""
        Generates a PDF document (.pdf) from markdown content.
        Use for narrative or free-form content such as stories, reports, or letters.
        Do NOT use this for tabular data that has a Content ID — use GeneratePdfFromContent instead.
        """)]
    public async Task<string> GeneratePdfAsync(
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The markdown content of the file.")] string content)
    {
        var markdown = ParsedMarkdownDocument.FromText(content);
        await markdown.DownloadImages(httpClient: httpClientFactory.CreateClient());

        var bytes = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.PageColor(Colors.White);
                page.Margin(2, Unit.Centimetre);
                page.Content().Markdown(content);
            });
        }).GeneratePdf();

        artifactStore.Add(new($"{fileName}.pdf", bytes));

        return description;
    }

    [Description("""
        Generates a PDF document with a formatted table from previously stored structured data (e.g., query results) identified by a Content ID.
        Use this instead of GeneratePdfAsync when exporting tabular data.
        The tool reads ALL data from the store — nothing is truncated.
        Bold and italic styles are applied via markdown. Colors are not supported in PDF tables.
        """)]
    public string GeneratePdfFromContent(
        [Description("The Content ID of the stored data.")] string contentId,
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("Optional title displayed above the table.")] string? title,
        [Description("Column definitions specifying which fields to include, display headers, and unconditional styles.")] RenderColumn[] columns,
        [Description("Optional conditional formatting rules (bold/italic only in PDF).")] ConditionalRule[]? rules = null)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(contentId);
        ArgumentNullException.ThrowIfNull(columns);

        var json = contentStore.Get(contentId)
            ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

        var markdown = MarkdownTableBuilder.Build(json, title, columns, rules);

        var bytes = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.PageColor(Colors.White);
                page.Margin(2, Unit.Centimetre);
                page.Content().Markdown(markdown);
            });
        }).GeneratePdf();

        artifactStore.Add(new($"{fileName}.pdf", bytes));

        return description;
    }
}
