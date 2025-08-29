import 'dart:typed_data';

import 'export_saver_stub.dart'
    if (dart.library.html) 'export_saver_web.dart'
    if (dart.library.io) 'export_saver_io.dart';

abstract class ExportSaverPlatform {
  void saveBytes(Uint8List bytes, String filename);
}

final ExportSaverPlatform exportSaver = getExportSaver();

