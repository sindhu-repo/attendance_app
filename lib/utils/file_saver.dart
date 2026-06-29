// Conditional export: dart.library.html is only true on web (dart2js).
// dart.library.io is only true on native (Windows, macOS, Linux, Android, iOS).
export 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';
