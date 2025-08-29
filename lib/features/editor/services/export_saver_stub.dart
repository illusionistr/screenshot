import 'dart:typed_data';

import 'export_saver.dart';

ExportSaverPlatform getExportSaver() => _StubSaver();

class _StubSaver implements ExportSaverPlatform {
  @override
  void saveBytes(Uint8List bytes, String filename) {
    throw UnimplementedError('Saving not supported on this platform');
  }
}

