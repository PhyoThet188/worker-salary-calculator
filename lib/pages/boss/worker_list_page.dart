import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../models/worker_data.dart';
import '../../models/salary_calculator.dart';
import 'worker_detail_page.dart';

class WorkerListPage extends StatefulWidget {
  const WorkerListPage({super.key});

  @override
  State<WorkerListPage> createState() => _WorkerListPageState();
}

class _WorkerListPageState extends State<WorkerListPage> {
  String searchQuery = '';
  String filterBy = 'All';
  String sortBy = 'name'; // 'name', 'salary_high', 'salary_low', 'attendance_high', 'attendance_low'

  List<Worker> get filteredWorkers {
    List<Worker> workers = WorkerData.workers.where((worker) {
      if (searchQuery.isNotEmpty && 
          !worker.name.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !worker.id.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      
      if (filterBy == 'High Attendance' && worker.totalLeaveDays > 3) return false;
      if (filterBy == 'Low Attendance' && worker.totalLeaveDays <= 5) return false;
      
      return true;
    }).toList();

    // Apply sorting
    switch (sortBy) {
      case 'salary_high':
        workers.sort((a, b) => b.baseSalary.compareTo(a.baseSalary));
        break;
      case 'salary_low':
        workers.sort((a, b) => a.baseSalary.compareTo(b.baseSalary));
        break;
      case 'attendance_high':
        workers.sort((a, b) => b.totalPresentDays.compareTo(a.totalPresentDays));
        break;
      case 'attendance_low':
        workers.sort((a, b) => a.totalPresentDays.compareTo(b.totalPresentDays));
        break;
      case 'name':
      default:
        workers.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return workers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'All'),
                    _buildFilterChip('High Attendance', 'High Attendance'),
                    _buildFilterChip('Low Attendance', 'Low Attendance'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sort Options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Sort by:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: sortBy,
                items: const [
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'salary_high', child: Text('Salary (High to Low)')),
                  DropdownMenuItem(value: 'salary_low', child: Text('Salary (Low to High)')),
                  DropdownMenuItem(value: 'attendance_high', child: Text('Attendance (High to Low)')),
                  DropdownMenuItem(value: 'attendance_low', child: Text('Attendance (Low to High)')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      sortBy = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        // Worker List with Salary
        Expanded(
          child: ListView.builder(
            itemCount: filteredWorkers.length,
            itemBuilder: (context, index) {
              final worker = filteredWorkers[index];
              double bonusAmount = _getBonusAmount(worker.totalLeaveDays);
              double totalSalary = worker.baseSalary + bonusAmount;
              double dailyRate = worker.baseSalary / 26;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerDetailPage(worker: worker),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Main Row with Worker Info and Salary
                        Row(
                          children: [
                            // Worker Avatar and Basic Info
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: worker.totalLeaveDays <= 3 ? Colors.green.shade100 : 
                                                   (worker.totalLeaveDays <= 5 ? Colors.orange.shade100 : Colors.red.shade100),
                                    child: Text(
                                      worker.name[0],
                                      style: TextStyle(
                                        color: worker.totalLeaveDays <= 3 ? Colors.green : 
                                               (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          worker.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${worker.position} • ${worker.workstation}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${worker.id}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Salary Info Column
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    SalaryCalculator.formatCurrency(worker.baseSalary),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (bonusAmount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+ ${SalaryCalculator.formatCurrency(bonusAmount)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Salary Details Bar
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              // Attendance and Daily Rate
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Attendance Icons
                                  Row(
                                    children: [
                                      _buildSalaryDetail(
                                        Icons.calendar_today,
                                        'Present',
                                        '${worker.totalPresentDays}',
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 16),
                                      _buildSalaryDetail(
                                        Icons.beach_access,
                                        'Leave',
                                        '${worker.totalLeaveDays}',
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                                  
                                  // Daily Rate
                                  Row(
                                    children: [
                                      const Icon(Icons.timer, size: 14, color: Colors.purple),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Daily: ${SalaryCalculator.formatCurrency(dailyRate)}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.purple.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Total Salary and Bonus Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Bonus Status
                                  Row(
                                    children: [
                                      Icon(
                                        worker.totalLeaveDays <= 3 ? Icons.emoji_events : 
                                        (worker.totalLeaveDays <= 5 ? Icons.warning : Icons.error),
                                        size: 14,
                                        color: worker.totalLeaveDays <= 3 ? Colors.green : 
                                               (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _getBonusStatus(worker.totalLeaveDays),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: worker.totalLeaveDays <= 3 ? Colors.green : 
                                                 (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Total Salary
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.monetization_on, size: 14, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total: ${SalaryCalculator.formatCurrency(totalSalary)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: filterBy == value,
        onSelected: (selected) {
          setState(() {
            filterBy = value;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.orange,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: filterBy == value ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSalaryDetail(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _getBonusAmount(int leaveDays) {
    if (leaveDays <= 3) return 50000;
    if (leaveDays <= 5) return 20000;
    return 0;
  }

  String _getBonusStatus(int leaveDays) {
    if (leaveDays <= 3) return 'Full Attendance';
    if (leaveDays <= 5) return 'Good Attendance';
    return 'No Bonus';
  }
}