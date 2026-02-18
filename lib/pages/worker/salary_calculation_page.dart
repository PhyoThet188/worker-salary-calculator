import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../models/salary_calculator.dart';

class SalaryCalculationPage extends StatefulWidget {
  final Worker worker;

  const SalaryCalculationPage({super.key, required this.worker});

  @override
  State<SalaryCalculationPage> createState() => _SalaryCalculationPageState();
}

class _SalaryCalculationPageState extends State<SalaryCalculationPage> {
  late int presentDays;
  late int leaveDays;
  Map<String, dynamic>? calculationResult;

  @override
  void initState() {
    super.initState();
    // Use actual attendance data from worker
    presentDays = widget.worker.totalPresentDays;
    leaveDays = widget.worker.totalLeaveDays;
    // Auto-calculate on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSalary();
    });
  }

  void _calculateSalary() {
    setState(() {
      calculationResult = SalaryCalculator.calculateSalary(
        widget.worker,
        presentDays,
        leaveDays,
      );
    });
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker Information Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Worker Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(),
                  _buildInfoRow('Name', widget.worker.name),
                  _buildInfoRow('ID', widget.worker.id),
                  _buildInfoRow('Workstation', widget.worker.workstation),
                  _buildInfoRow('Position', widget.worker.position),
                  _buildInfoRow('Base Salary', 
                      SalaryCalculator.formatCurrency(widget.worker.baseSalary)),
                  _buildInfoRow('Daily Rate', 
                      SalaryCalculator.formatCurrency(widget.worker.dailyRate)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Attendance Summary Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(),
                  
                  // Attendance Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttendanceStat(
                        'Present Days',
                        presentDays.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildAttendanceStat(
                        'Leave Days',
                        leaveDays.toString(),
                        Icons.calendar_today,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bonus Status
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonus Status',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                getBonusStatus(),
                                style: TextStyle(
                                  color: getBonusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Auto-calculation notice
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Salary calculated based on your actual attendance records',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
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

          const SizedBox(height: 16),

          // Salary Calculation Result
          if (calculationResult != null) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Salary Calculation Result',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Divider(),
                    
                    // Salary Breakdown
                    _buildResultRow('Base Salary', 
                        SalaryCalculator.formatCurrency(calculationResult!['baseSalary'])),
                    _buildResultRow('Overtime Pay', 
                        SalaryCalculator.formatCurrency(calculationResult!['overtimePay'])),
                    
                    // Bonus Row with color
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bonus (${calculationResult!['bonusType']})',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: getBonusColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              SalaryCalculator.formatCurrency(calculationResult!['bonus']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: getBonusColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    _buildResultRow('Total Salary', 
                        SalaryCalculator.formatCurrency(calculationResult!['totalSalary']),
                        isBold: true),
                    _buildResultRow('Tax', 
                        SalaryCalculator.formatCurrency(calculationResult!['tax'])),
                    
                    const Divider(),
                    
                    // Net Salary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Net Salary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            SalaryCalculator.formatCurrency(calculationResult!['netSalary']),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    
                    // Calculation Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Calculated: ${DateTime.now().toString().substring(0, 16)}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Refresh Button (optional)
          Center(
            child: OutlinedButton.icon(
              onPressed: _calculateSalary,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Calculation'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 16,
              color: isBold ? Colors.blue : null,
            ),
          ),
        ],
      ),
    );
  }
}