import 'dart:convert';
import 'dart:html' as html;

Future<void> downloadPdf(
  String pdfBase64,
  String filename,
) async {
  final bytes = base64Decode(pdfBase64);

  final blob = html.Blob(
    [bytes],
    'application/pdf',
  );

  final url =
      html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute(
      'download',
      filename,
    )
    ..click();

  html.Url.revokeObjectUrl(url);
}