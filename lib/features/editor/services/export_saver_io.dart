import 'dart:typed_data';

import 'export_saver.dart';

ExportSaverPlatform getExportSaver() => _IoSaver();

class _IoSaver implements ExportSaverPlatform {
  @override
  void saveBytes(Uint8List bytes, String filename) {
    // TODO: Implement saving for mobile/desktop using path_provider + dart:io
    throw UnimplementedError('Saving not implemented for mobile/desktop');
  }
}

