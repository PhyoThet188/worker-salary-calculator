import 'package:flutter/material.dart';
import '../../models/worker.dart';

class LeaveRecordsPage extends StatefulWidget {
  final Worker worker;

  const LeaveRecordsPage({super.key, required this.worker});  // Add required worker parameter

  @override
  State<LeaveRecordsPage> createState() => _LeaveRecordsPageState();
}

class _LeaveRecordsPageState extends State<LeaveRecordsPage> {
  List<Map<String, dynamic>> leaveHistory = [];

  @override
  void initState() {
    super.initState();
    _generateLeaveHistory();
  }

  void _generateLeaveHistory() {
    for (int i = 1; i <= 12; i++) {
      leaveHistory.add({
        'month': i,
        'year': '2024',
        'leaveDays': i % 7,
        'leaveType': i % 3 == 0 ? 'Sick Leave' : (i % 3 == 1 ? 'Personal Leave' : 'Emergency Leave'),
        'approved': i % 5 != 0,
      });
    }
  }

  String getBonusStatus() {
    if (widget.worker.totalLeaveDays <= 3) {
      return 'Full Attendance Bonus (50,000 MMK)';
    } else if (widget.worker.totalLeaveDays <= 5) {
      return 'Good Attendance Bonus (20,000 MMK)';
    } else {
      return 'No Attendance Bonus';
    }
  }

  Color getBonusColor() {
    if (widget.worker.totalLeaveDays <= 3) {
      return Colors.green;
    } else if (widget.worker.totalLeaveDays <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leave Summary',
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
                        '${widget.worker.totalLeaveDays} days',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getBonusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: getBonusColor()),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.worker.totalLeaveDays <= 3 ? Icons.emoji_events : 
                        (widget.worker.totalLeaveDays <= 5 ? Icons.warning : Icons.error),
                        color: getBonusColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getBonusStatus(),
                          style: TextStyle(
                            color: getBonusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: leaveHistory.length,
              itemBuilder: (context, index) {
                final record = leaveHistory[leaveHistory.length - 1 - index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: record['approved'] ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        record['approved'] ? Icons.check : Icons.close,
                        color: record['approved'] ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text('${record['leaveType']}'),
                    subtitle: Text('${record['month']}/${record['year']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${record['leaveDays']} days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: record['leaveDays'] > 0 ? Colors.orange : Colors.green,
                          ),
                        ),
                        Text(
                          record['approved'] ? 'Approved' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: record['approved'] ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}