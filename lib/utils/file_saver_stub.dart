/// Fallback — never reached when running on web or native.
Future<String?> saveExcelFile(String filename, List<int> bytes) async {
  throw UnsupportedError('saveExcelFile is not supported on this platform');
}
