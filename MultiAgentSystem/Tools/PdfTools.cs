using System.ComponentModel;
using MultiAgentSystem.AgentArtifacts;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using QuestPDF.Markdown;

namespace MultiAgentSystem.Tools;

public sealed class PdfTools(IHttpClientFactory httpClientFactory, AgentArtifactStore artifactStore)
{
    static PdfTools()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    [Description("""
        Generates a PDF document (.pdf) from data.
        Use when the user asks to create, export, or save data as a PDF document.
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
}
