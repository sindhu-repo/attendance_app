// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web: triggers a browser download. Returns null because the browser
/// controls the destination path.
Future<String?> saveExcelFile(String filename, List<int> bytes) async {
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  return null;
}
