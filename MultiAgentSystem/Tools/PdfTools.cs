using System.ComponentModel;
using MultiAgentSystem.AgentArtifacts;
using MultiAgentSystem.Models;
using MultiAgentSystem.Stores;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using QuestPDF.Markdown;

namespace MultiAgentSystem.Tools;

public sealed class PdfTools(IHttpClientFactory httpClientFactory, AgentArtifactStore artifactStore, ITableContentStore tableContentStore)
{
    static PdfTools()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    [Description("""
        Generates a PDF document (.pdf).
        If a contentId is provided, the tool reads ALL rows directly from the store and renders a formatted table — nothing is truncated. Provide columns and optional rules to control layout and conditional formatting.
        If no contentId is provided, provide markdown content directly (for narrative text, stories, reports, or any free-form content).
        """)]
    public async Task<string> GeneratePdfAsync(
        [Description("The file name without extension.")] string fileName,
        [Description("A brief summary of the generated file content. Do not include download links or references to downloading the file.")] string description,
        [Description("The Content ID of previously stored tabular data. When provided, the tool reads data from the store and 'content' is ignored.")] string? contentId = null,
        [Description("Column definitions for content-based export: which fields to include, display headers, unconditional styles. Required when contentId is provided.")] RenderColumn[]? columns = null,
        [Description("Optional conditional formatting rules for content-based export (bold/italic only in PDF).")] ConditionalRule[]? rules = null,
        [Description("Optional title displayed above the table when using contentId.")] string? title = null,
        [Description("Markdown content for narrative/free-form documents. Used only when no contentId is provided.")] string? content = null)
    {
        string markdownContent;

        if (!string.IsNullOrWhiteSpace(contentId))
        {
            var json = await tableContentStore.GetAsync(contentId)
                ?? throw new InvalidOperationException($"No content found for Content ID '{contentId}'.");

            markdownContent = MarkdownTableBuilder.Build(json, title, columns ?? [], rules);
        }
        else
        {
            markdownContent = content ?? string.Empty;
            var parsed = ParsedMarkdownDocument.FromText(markdownContent);
            await parsed.DownloadImages(httpClient: httpClientFactory.CreateClient());
        }

        var bytes = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.PageColor(Colors.White);
                page.Margin(2, Unit.Centimetre);
                page.Content().Markdown(markdownContent);
            });
        }).GeneratePdf();

        artifactStore.Add(new($"{fileName}.pdf", bytes));

        return description;
    }
}
