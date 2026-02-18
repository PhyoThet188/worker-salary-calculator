import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../models/worker.dart';
import '../models/worker_data.dart';

class ReportService {
  
  // Generate Excel Report with complete worker information
  static Future<void> generateExcelReport() async {
    try {
      // Create Excel file
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Workers Complete Report'];
      
      // Add headers with all worker information
      sheetObject.appendRow([
        'ID',
        'Name',
        'Position',
        'Workstation',
        'Base Salary (MMK)',
        'Daily Rate (MMK)',
        'Present Days',
        'Leave Days',
        'Bonus Status',
        'Bonus Amount (MMK)',
        'Total Salary (MMK)',
        'Phone',
        'Email',
        'Address',
        'Emergency Contact',
        'Join Date',
        'Username',
      ]);
      
      // Style headers
      var headerRow = sheetObject.row(0);
      for (var cell in headerRow) {
        cell?.cellStyle = CellStyle(
          backgroundColorHex: '#4472C4',
          fontColorHex: '#FFFFFF',
          bold: true,
        );
      }
      
      // Add worker data with complete information
      for (var worker in WorkerData.workers) {
        String bonusStatus = _getBonusStatus(worker.totalLeaveDays);
        double bonusAmount = _getBonusAmount(worker.totalLeaveDays);
        double totalSalary = worker.baseSalary + bonusAmount;
        
        sheetObject.appendRow([
          worker.id,
          worker.name,
          worker.position,
          worker.workstation,
          worker.baseSalary,
          worker.dailyRate,
          worker.totalPresentDays,
          worker.totalLeaveDays,
          bonusStatus,
          bonusAmount,
          totalSalary,
          worker.phone,
          worker.email,
          worker.address,
          worker.emergencyContact,
          worker.joinDate,
          worker.username,
        ]);
      }
      
      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/workers_complete_report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        final file = File(path);
        await file.writeAsBytes(fileBytes);
        
        print('Excel file saved at: $path');
        await OpenFile.open(path);
      }
    } catch (e) {
      print('Error generating Excel: $e');
      rethrow;
    }
  }
  
  // Generate PDF Report with complete worker details
  static Future<void> generatePdfReport() async {
    try {
      final pdf = pw.Document();
      
      // Add multiple pages with complete worker information
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          header: (context) => pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              children: [
                pw.Text(
                  'Worker Salary Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.Text(
                  'Complete Worker Information',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
              ],
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Generated on ${DateTime.now().toString().substring(0, 16)} | Page ${context.pageNumber}',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey,
              ),
            ),
          ),
          build: (context) => [
            _buildSummaryTable(context),
            pw.SizedBox(height: 30),
            pw.Text(
              'Complete Worker Details',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            ..._buildCompleteWorkerDetailsPages(context),
          ],
        ),
      );
      
      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/workers_complete_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(path);
      await file.writeAsBytes(await pdf.save());
      
      print('PDF file saved at: $path');
      await OpenFile.open(path);
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }
  
  // Share Report via Email (Excel format with complete data)
  static Future<void> shareReport() async {
    try {
      // Create Excel file for sharing with complete data
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Workers Complete Report'];
      
      // Add headers
      sheetObject.appendRow([
        'ID',
        'Name',
        'Position',
        'Workstation',
        'Base Salary (MMK)',
        'Present Days',
        'Leave Days',
        'Bonus Status',
        'Total Salary (MMK)',
        'Phone',
        'Email',
      ]);
      
      // Add worker data (limit to 500 for email)
      for (var worker in WorkerData.workers.take(500)) {
        String bonusStatus = _getBonusStatus(worker.totalLeaveDays);
        double bonusAmount = _getBonusAmount(worker.totalLeaveDays);
        double totalSalary = worker.baseSalary + bonusAmount;
        
        sheetObject.appendRow([
          worker.id,
          worker.name,
          worker.position,
          worker.workstation,
          worker.baseSalary,
          worker.totalPresentDays,
          worker.totalLeaveDays,
          bonusStatus,
          totalSalary,
          worker.phone,
          worker.email,
        ]);
      }
      
      var fileBytes = excel.save();
      if (fileBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/workers_report_share.xlsx';
        final file = File(path);
        await file.writeAsBytes(fileBytes);
        
        // Share the file
        await Share.shareXFiles(
          [XFile(path)],
          text: 'Worker Complete Salary Report\nGenerated: ${DateTime.now().toString().substring(0, 16)}',
        );
      }
    } catch (e) {
      print('Error sharing report: $e');
      rethrow;
    }
  }
  
  // Generate Summary Report as Text
  static String generateSummaryText() {
    int totalWorkers = WorkerData.workers.length;
    double totalSalary = WorkerData.workers.fold(0, (sum, w) => sum + w.baseSalary);
    double averageSalary = totalSalary / totalWorkers;
    int totalPresent = WorkerData.workers.fold(0, (sum, w) => sum + w.totalPresentDays);
    int totalLeave = WorkerData.workers.fold(0, (sum, w) => sum + w.totalLeaveDays);
    
    int fullAttendance = WorkerData.workers.where((w) => w.totalLeaveDays <= 3).length;
    int goodAttendance = WorkerData.workers.where((w) => w.totalLeaveDays > 3 && w.totalLeaveDays <= 5).length;
    
    // Calculate total bonus amount
    double totalBonus = WorkerData.workers.fold(0, (sum, w) => sum + _getBonusAmount(w.totalLeaveDays));
    
    return '''
╔══════════════════════════════════════════════════════════╗
║                 WORKER SALARY REPORT                      ║
╚══════════════════════════════════════════════════════════╝

Generated: ${DateTime.now().toString().substring(0, 16)}

📊 SUMMARY STATISTICS
═══════════════════════════════════════════════════════════
Total Workers:        ${totalWorkers.toString().padLeft(8)}
Total Payroll:        ${totalSalary.toStringAsFixed(0).padLeft(8)} MMK
Average Salary:       ${averageSalary.toStringAsFixed(0).padLeft(8)} MMK
Total Bonus Payout:   ${totalBonus.toStringAsFixed(0).padLeft(8)} MMK

📈 ATTENDANCE STATISTICS
═══════════════════════════════════════════════════════════
Total Present Days:   ${totalPresent.toString().padLeft(8)}
Total Leave Days:     ${totalLeave.toString().padLeft(8)}
Average Attendance:   ${((totalPresent / (totalWorkers * 26)) * 100).toStringAsFixed(1)}%

🏆 BONUS DISTRIBUTION
═══════════════════════════════════════════════════════════
Full Attendance (≤3 days):  ${fullAttendance.toString().padLeft(4)} workers
Good Attendance (≤5 days):  ${goodAttendance.toString().padLeft(4)} workers
No Bonus:                   ${(totalWorkers - fullAttendance - goodAttendance).toString().padLeft(4)} workers

💰 TOP 5 HIGHEST PAID WORKERS
═══════════════════════════════════════════════════════════''';
  }
  
  static String _getBonusStatus(int leaveDays) {
    if (leaveDays <= 3) return 'Full Attendance';
    if (leaveDays <= 5) return 'Good Attendance';
    return 'No Bonus';
  }
  
  static double _getBonusAmount(int leaveDays) {
    if (leaveDays <= 3) return 50000;
    if (leaveDays <= 5) return 20000;
    return 0;
  }
  
  static pw.Widget _buildSummaryTable(pw.Context context) {
    int totalWorkers = WorkerData.workers.length;
    double totalSalary = WorkerData.workers.fold(0, (sum, w) => sum + w.baseSalary);
    double averageSalary = totalSalary / totalWorkers;
    int fullAttendance = WorkerData.workers.where((w) => w.totalLeaveDays <= 3).length;
    int goodAttendance = WorkerData.workers.where((w) => w.totalLeaveDays > 3 && w.totalLeaveDays <= 5).length;
    double totalBonus = WorkerData.workers.fold(0, (sum, w) => sum + _getBonusAmount(w.totalLeaveDays));
    
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Metric', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Workers')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$totalWorkers')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Payroll')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${totalSalary.toStringAsFixed(0)} MMK')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Average Salary')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${averageSalary.toStringAsFixed(0)} MMK')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Bonus')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${totalBonus.toStringAsFixed(0)} MMK')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Full Attendance')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$fullAttendance')),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Good Attendance')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$goodAttendance')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static List<pw.Widget> _buildCompleteWorkerDetailsPages(pw.Context context) {
    List<pw.Widget> pages = [];
    const int workersPerPage = 5;
    
    for (int i = 0; i < WorkerData.workers.length; i += workersPerPage) {
      int endIndex = (i + workersPerPage < WorkerData.workers.length) 
          ? i + workersPerPage 
          : WorkerData.workers.length;
      
      var pageWorkers = WorkerData.workers.sublist(i, endIndex);
      
      pages.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Workers ${i + 1} - $endIndex',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
            pw.SizedBox(height: 10),
            ...pageWorkers.map((worker) => _buildWorkerDetailCard(worker)).toList(),
          ],
        ),
      );
      
      // Add page break if not the last page
      if (i + workersPerPage < WorkerData.workers.length) {
        pages.add(pw.SizedBox(height: 20));
      }
    }
    
    return pages;
  }
  
  static pw.Widget _buildWorkerDetailCard(Worker worker) {
    String bonusStatus = _getBonusStatus(worker.totalLeaveDays);
    double bonusAmount = _getBonusAmount(worker.totalLeaveDays);
    double totalSalary = worker.baseSalary + bonusAmount;
    
    PdfColor bonusColor = worker.totalLeaveDays <= 3 
        ? PdfColors.green 
        : (worker.totalLeaveDays <= 5 ? PdfColors.orange : PdfColors.red);
    
    // Create light version of color by using a lighter shade
    PdfColor lightBonusColor = worker.totalLeaveDays <= 3 
        ? PdfColors.green100 
        : (worker.totalLeaveDays <= 5 ? PdfColors.orange100 : PdfColors.red100);
    
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with name and ID
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                worker.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Text(
                  worker.id,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Personal Information
          pw.Text(
            'Personal Information',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey,
            ),
          ),
          pw.Divider(),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Position', worker.position),
                    _buildInfoRow('Workstation', worker.workstation),
                    _buildInfoRow('Phone', worker.phone),
                    _buildInfoRow('Email', worker.email),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Join Date', worker.joinDate),
                    _buildInfoRow('Username', worker.username),
                    _buildInfoRow('Address', worker.address),
                    _buildInfoRow('Emergency', worker.emergencyContact),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Salary Information
          pw.Text(
            'Salary Information',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey,
            ),
          ),
          pw.Divider(),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Base Salary', '${worker.baseSalary.toStringAsFixed(0)} MMK'),
                    _buildInfoRow('Daily Rate', '${worker.dailyRate.toStringAsFixed(0)} MMK'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Present Days', '${worker.totalPresentDays} days'),
                    _buildInfoRow('Leave Days', '${worker.totalLeaveDays} days'),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Bonus and Total - Using light color without opacity
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: lightBonusColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: bonusColor,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          worker.totalLeaveDays <= 3 ? '🏆' : 
                          (worker.totalLeaveDays <= 5 ? '⚠️' : '❌'),
                          style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      bonusStatus,
                      style: pw.TextStyle(
                        color: bonusColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Total: ${totalSalary.toStringAsFixed(0)} MMK',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}