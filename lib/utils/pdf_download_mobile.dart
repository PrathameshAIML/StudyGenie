import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

Future<void> downloadPdf(
  String pdfBase64,
  String filename,
) async {
  final bytes = base64Decode(pdfBase64);

  final dir = await getApplicationDocumentsDirectory();

  final file = File(
    '${dir.path}/$filename',
  );

  await file.writeAsBytes(bytes);

  await OpenFilex.open(file.path);
}