import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../data/app_database.dart';
import '../data/models/loan.dart';
import '../data/models/installment.dart';
import '../core/utils/formatters.dart';

class BackupExportService {
  final AppDatabase database;
  BackupExportService(this.database);

  Future<void> shareBackup() async {
    final data = await database.exportAll(); final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/moed-backup-${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(database.encodeBackup(data));
    await SharePlus.instance.share(ShareParams(text: 'نسخه پشتیبان موعد', files: [XFile(file.path)]));
  }

  Future<bool> restoreBackup() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (r == null || r.files.single.path == null) return false;
    final raw = await File(r.files.single.path!).readAsString();
    final data = jsonDecode(raw) as Map<String,dynamic>;
    if (data['version'] != 1 || data['loans'] is! List) throw const FormatException('فایل پشتیبان معتبر نیست');
    await database.importAll(data); return true;
  }

  Future<void> shareCsv(List<Loan> loans, List<Installment> items) async {
    final loanMap={for(final l in loans) l.id!:l};
    final b=StringBuffer('loan,installment,due_date,amount,paid,remaining,status\\n');
    for(final i in items){ final l=loanMap[i.loanId]; b.writeln('"${l?.title ?? ''}",${i.sequence},${jalaliShort(i.dueDate)},${i.amount},${i.paidAmount},${i.remaining},${i.status}'); }
    final dir=await getTemporaryDirectory(); final f=File('${dir.path}/moed-report.csv'); await f.writeAsString('\uFEFF${b.toString()}');
    await SharePlus.instance.share(ShareParams(text:'گزارش اقساط موعد',files:[XFile(f.path)]));
  }

  Future<void> shareLoanPdf(Loan loan, List<Installment> items) async {
    final png = await _renderPersianReport(loan, items);
    final doc=pw.Document(); final image=pw.MemoryImage(png);
    doc.addPage(pw.Page(pageFormat: PdfPageFormat.a4, margin: pw.EdgeInsets.zero, build:(_)=>pw.Image(image,fit:pw.BoxFit.cover)));
    final dir=await getTemporaryDirectory(); final f=File('${dir.path}/moed-${loan.id}.pdf'); await f.writeAsBytes(await doc.save());
    await SharePlus.instance.share(ShareParams(text:'گزارش ${loan.title}',files:[XFile(f.path)]));
  }

  Future<Uint8List> _renderPersianReport(Loan loan,List<Installment> items) async {
    const w=1240.0,h=1754.0; final recorder=ui.PictureRecorder(); final canvas=Canvas(recorder); canvas.drawColor(const Color(0xFFF4F8FF), BlendMode.src);
    void txt(String s,double y,{double size=34,FontWeight weight=FontWeight.w500,Color color=const Color(0xFF13233E)}){
      final p=ui.ParagraphBuilder(ui.ParagraphStyle(textDirection:TextDirection.rtl,textAlign:TextAlign.right,fontSize:size,fontWeight:weight,fontFamily:'Vazirmatn'))..pushStyle(ui.TextStyle(color:color))..addText(s);
      final paragraph=p.build()..layout(const ui.ParagraphConstraints(width:1080)); canvas.drawParagraph(paragraph,Offset(80,y));
    }
    txt('موعد • گزارش اقساط',80,size:46,weight:FontWeight.w800,color:const Color(0xFF3488FF)); txt(loan.title,155,size:42,weight:FontWeight.w800); txt('مانده: ${money(items.fold(0,(s,e)=>s+e.remaining))}',220);
    var y=310.0; for(final i in items.take(16)){ txt('قسط ${toPersianDigits(i.sequence)}   ${jalaliShort(i.dueDate)}   ${money(i.amount)}   ${i.isPaid?'پرداخت‌شده':i.status=='partial'?'پرداخت جزئی':'در انتظار'}',y,size:27); y+=72; }
    txt('خروجی ساخته‌شده توسط اپ موعد',1650,size:22,color:const Color(0xFF6F7F98));
    final image=await recorder.endRecording().toImage(w.toInt(),h.toInt()); final data=await image.toByteData(format:ui.ImageByteFormat.png); return data!.buffer.asUint8List();
  }
}
