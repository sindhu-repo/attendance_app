import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Windows / macOS / Linux: saves the file to the Downloads folder if
/// available, otherwise falls back to the app documents directory.
/// Returns the full path of the saved file so the caller can display it.
Future<String?> saveExcelFile(String filename, List<int> bytes) async {
  Directory? dir;
  try {
    dir = await getDownloadsDirectory();
  } catch (_) {
    dir = null;
  }
  dir ??= await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
