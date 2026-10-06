import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/patient.dart';

class PrescriptionPdf {
  static Future<void> print({
    required Patient patient,
    required String diagnosis,
    required String medicines,
    String notes = '',
  }) async {
    final now = DateTime.now();
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('MediDesk Prescription',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 12),
              pw.Text('Date: ${DateFormat.yMMMd().format(now)}'),
              pw.Text('Time: ${DateFormat.jm().format(now)}'),
              pw.SizedBox(height: 12),
              pw.Text('Patient: ${patient.name}'),
              pw.Text('Patient ID: ${patient.patientId}'),
              pw.Text('Phone: ${patient.phone}'),
              pw.SizedBox(height: 20),
              pw.Text('Diagnosis:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(diagnosis),
              pw.SizedBox(height: 16),
              pw.Text('Medicines:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(medicines),
              pw.SizedBox(height: 16),
              pw.Text('Notes:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(notes.isEmpty ? '-' : notes),
              pw.SizedBox(height: 40),
              pw.Text('Doctor Signature: ____________________'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }
}
