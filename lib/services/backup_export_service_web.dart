import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/utils/formatters.dart';
import '../data/app_database.dart';
import '../data/models/installment.dart';
import '../data/models/loan.dart';

class BackupExportService {
  final AppDatabase database;

  BackupExportService(this.database);

  Future<void> shareBackup() async {
    final data = await database.exportAll();
    final String encoded = database.encodeBackup(data);
    _downloadText(
      filename: 'moed-backup.json',
      contents: encoded,
      mimeType: 'application/json;charset=utf-8',
    );
  }

  Future<bool> restoreBackup() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = '.json,application/json';
    input.click();

    await input.onChange.first;
    if (input.files == null || input.files!.isEmpty) return false;

    final html.File file = input.files!.first;
    final html.FileReader reader = html.FileReader();
    reader.readAsText(file);
    await reader.onLoad.first;

    final Object? result = reader.result;
    if (result is! String) return false;

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(jsonDecode(result) as Map);

    if (data['version'] != 1 || data['loans'] is! List) {
      throw const FormatException('فایل پشتیبان معتبر نیست');
    }

    await database.importAll(data);
    return true;
  }

  Future<void> shareCsv(
    List<Loan> loans,
    List<Installment> items,
  ) async {
    final Map<int, Loan> loanMap = <int, Loan>{
      for (final Loan loan in loans) loan.id!: loan,
    };

    final StringBuffer buffer = StringBuffer(
      'loan,installment,due_date,amount,paid,remaining,status\n',
    );

    for (final Installment item in items) {
      final Loan? loan = loanMap[item.loanId];
      buffer.writeln(
        '"${loan?.title ?? ''}",${item.sequence},${jalaliShort(item.dueDate)},${item.amount},${item.paidAmount},${item.remaining},${item.status}',
      );
    }

    _downloadText(
      filename: 'moed-report.csv',
      contents: '\uFEFF${buffer.toString()}',
      mimeType: 'text/csv;charset=utf-8',
    );
  }

  Future<void> shareLoanPdf(
    Loan loan,
    List<Installment> items,
  ) async {
    final List<int> png = await _renderPersianReport(loan, items);
    final pw.Document doc = pw.Document();
    final pw.MemoryImage image = pw.MemoryImage(Uint8List.fromList(png));

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );

    final Uint8List bytes = Uint8List.fromList(await doc.save());
    _downloadBytes(
      filename: 'moed-${loan.id}.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  Future<List<int>> _renderPersianReport(
    Loan loan,
    List<Installment> items,
  ) async {
    const double width = 1240;
    const double height = 1754;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawColor(
      const Color(0xFFF4F8FF),
      BlendMode.src,
    );

    void drawText(
      String text,
      double y, {
      double size = 34,
      FontWeight weight = FontWeight.w500,
      Color color = const Color(0xFF13233E),
    }) {
      final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          fontSize: size,
          fontWeight: weight,
          fontFamily: 'Vazirmatn',
        ),
      )
        ..pushStyle(ui.TextStyle(color: color))
        ..addText(text);

      final ui.Paragraph paragraph = builder.build()
        ..layout(const ui.ParagraphConstraints(width: 1080));
      canvas.drawParagraph(paragraph, Offset(80, y));
    }

    drawText(
      'موعد • گزارش اقساط',
      80,
      size: 46,
      weight: FontWeight.w800,
      color: const Color(0xFF3488FF),
    );
    drawText(loan.title, 155, size: 42, weight: FontWeight.w800);
    drawText(
      'مانده: ${money(items.fold<int>(0, (int sum, Installment item) => sum + item.remaining))}',
      220,
    );

    double y = 310;
    for (final Installment item in items.take(16)) {
      final String status = item.isPaid
          ? 'پرداخت‌شده'
          : item.status == 'partial'
              ? 'پرداخت جزئی'
              : 'در انتظار';
      drawText(
        'قسط ${toPersianDigits(item.sequence)}   ${jalaliShort(item.dueDate)}   ${money(item.amount)}   $status',
        y,
        size: 27,
      );
      y += 72;
    }

    drawText(
      'خروجی ساخته‌شده توسط اپ موعد',
      1650,
      size: 22,
      color: const Color(0xFF6F7F98),
    );

    final ui.Image image = await recorder.endRecording().toImage(
          width.toInt(),
          height.toInt(),
        );
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return data!.buffer.asUint8List();
  }

  void _downloadText({
    required String filename,
    required String contents,
    required String mimeType,
  }) {
    _downloadBytes(
      filename: filename,
      bytes: Uint8List.fromList(utf8.encode(contents)),
      mimeType: mimeType,
    );
  }

  void _downloadBytes({
    required String filename,
    required Uint8List bytes,
    required String mimeType,
  }) {
    final html.Blob blob = html.Blob(<Object>[bytes], mimeType);
    final String url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
