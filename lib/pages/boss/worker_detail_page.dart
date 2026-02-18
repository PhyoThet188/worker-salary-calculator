import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../models/salary_calculator.dart';

class WorkerDetailPage extends StatelessWidget {
  final Worker worker;

  const WorkerDetailPage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(worker.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        worker.name[0],
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      worker.position,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Worker ID', worker.id),
                    _buildInfoRow('Phone', worker.phone),
                    _buildInfoRow('Join Date', worker.joinDate),
                    _buildInfoRow('Workstation', worker.workstation),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Salary Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Base Salary', 
                        SalaryCalculator.formatCurrency(worker.baseSalary)),
                    _buildInfoRow('Daily Rate', 
                        SalaryCalculator.formatCurrency(worker.dailyRate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Summary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Total Present Days', '${worker.totalPresentDays} days'),
                    _buildInfoRow('Total Leave Days', '${worker.totalLeaveDays} days'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: worker.totalLeaveDays <= 3 ? Colors.green.withOpacity(0.1) :
                               (worker.totalLeaveDays <= 5 ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            worker.totalLeaveDays <= 3 ? Icons.emoji_events : 
                            (worker.totalLeaveDays <= 5 ? Icons.warning : Icons.error),
                            color: worker.totalLeaveDays <= 3 ? Colors.green :
                                   (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              worker.totalLeaveDays <= 3 ? 'Eligible for Full Attendance Bonus (50,000 MMK)' :
                              (worker.totalLeaveDays <= 5 ? 'Eligible for Good Attendance Bonus (20,000 MMK)' : 
                               'Not eligible for attendance bonus'),
                              style: TextStyle(
                                color: worker.totalLeaveDays <= 3 ? Colors.green :
                                       (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}