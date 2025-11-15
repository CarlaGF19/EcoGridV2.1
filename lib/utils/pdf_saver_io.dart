import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> savePdf(Uint8List bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = "${dir.path}/$fileName";
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(filePath);
}