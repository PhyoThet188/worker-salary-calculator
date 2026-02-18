import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../models/salary_calculator.dart';

class SalaryRecordPage extends StatefulWidget {
  final Worker worker;

  const SalaryRecordPage({super.key, required this.worker});  // Add required worker parameter

  @override
  State<SalaryRecordPage> createState() => _SalaryRecordPageState();
}

class _SalaryRecordPageState extends State<SalaryRecordPage> {
  List<Map<String, dynamic>> salaryHistory = [];

  @override
  void initState() {
    super.initState();
    _generateMockHistory();
  }

  void _generateMockHistory() {
    for (int i = 0; i < 12; i++) {
      salaryHistory.add({
        'month': 'Month ${i + 1}',
        'year': '2024',
        'amount': widget.worker.baseSalary + (i * 25000),
        'presentDays': 26 - (i % 5),
        'leaveDays': i % 5,
        'date': '2024-${(i + 1).toString().padLeft(2, '0')}-15',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Salary Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${salaryHistory.length} Records',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: salaryHistory.length,
              itemBuilder: (context, index) {
                final record = salaryHistory[salaryHistory.length - 1 - index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '${record['month'].toString().split(' ')[1]}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text('${record['month']} ${record['year']}'),
                    subtitle: Text(
                      'Present: ${record['presentDays']} days | Leave: ${record['leaveDays']} days',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          SalaryCalculator.formatCurrency(record['amount']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          record['date'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      _showSalaryDetail(context, record);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSalaryDetail(BuildContext context, Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Salary Details - ${record['month']} ${record['year']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Present Days:', '${record['presentDays']} days'),
            _buildDetailRow('Leave Days:', '${record['leaveDays']} days'),
            _buildDetailRow('Base Salary:', 
                SalaryCalculator.formatCurrency(record['amount'] * 0.8)),
            _buildDetailRow('Overtime:', 
                SalaryCalculator.formatCurrency(record['amount'] * 0.1)),
            _buildDetailRow('Bonus:', 
                SalaryCalculator.formatCurrency(record['amount'] * 0.1)),
            const Divider(),
            _buildDetailRow('Total:', 
                SalaryCalculator.formatCurrency(record['amount']),
                isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}