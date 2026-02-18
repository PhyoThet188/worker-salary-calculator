import 'package:flutter/material.dart';
import '../../models/worker.dart';
import '../../models/worker_data.dart';
import 'worker_detail_page.dart';

class WorkstationsPage extends StatelessWidget {
  const WorkstationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> workstationStats = {};
    
    for (var worker in WorkerData.workers) {
      if (!workstationStats.containsKey(worker.workstation)) {
        workstationStats[worker.workstation] = {
          'workers': <Worker>[],
          'totalSalary': 0.0,
          'totalPresent': 0,
          'totalLeave': 0,
        };
      }
      workstationStats[worker.workstation]!['workers'].add(worker);
      workstationStats[worker.workstation]!['totalSalary'] = 
          (workstationStats[worker.workstation]!['totalSalary'] as double) + worker.baseSalary;
      workstationStats[worker.workstation]!['totalPresent'] = 
          (workstationStats[worker.workstation]!['totalPresent'] as int) + worker.totalPresentDays;
      workstationStats[worker.workstation]!['totalLeave'] = 
          (workstationStats[worker.workstation]!['totalLeave'] as int) + worker.totalLeaveDays;
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workstations Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Workstations: ${workstationStats.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search workstation...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workstationStats.length,
              itemBuilder: (context, index) {
                String stationName = workstationStats.keys.elementAt(index);
                Map<String, dynamic> stats = workstationStats[stationName]!;
                List<Worker> workers = stats['workers'];
                double avgSalary = stats['totalSalary'] / workers.length;
                int avgPresent = stats['totalPresent'] ~/ workers.length;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      stationName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${workers.length} workers'),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: avgPresent / 26,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            avgPresent >= 23 ? Colors.green : 
                            (avgPresent >= 20 ? Colors.orange : Colors.red)
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(avgSalary / 1000).toStringAsFixed(0)}K MMK',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey.shade50,
                        child: Column(
                          children: [
                            _buildWorkstationStats(
                              'Average Present Rate',
                              '${((avgPresent / 26) * 100).toStringAsFixed(1)}%',
                              avgPresent >= 23 ? Colors.green : 
                              (avgPresent >= 20 ? Colors.orange : Colors.red),
                            ),
                            const SizedBox(height: 8),
                            _buildWorkstationStats(
                              'Total Payroll',
                              '${(stats['totalSalary'] / 1000000).toStringAsFixed(1)}M MMK',
                              Colors.blue,
                            ),
                            const SizedBox(height: 8),
                            _buildWorkstationStats(
                              'Total Leave Days',
                              '${stats['totalLeave']} days',
                              stats['totalLeave'] > workers.length * 3 ? Colors.red : Colors.green,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workers.length > 5 ? 5 : workers.length,
                        itemBuilder: (context, i) {
                          Worker w = workers[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: w.totalLeaveDays <= 3 ? Colors.green.shade100 : 
                                             (w.totalLeaveDays <= 5 ? Colors.orange.shade100 : Colors.red.shade100),
                              child: Text(
                                w.name[0],
                                style: TextStyle(
                                  color: w.totalLeaveDays <= 3 ? Colors.green : 
                                         (w.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              w.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${w.position} • ID: ${w.id}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${w.baseSalary.toStringAsFixed(0)} MMK',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: w.totalLeaveDays <= 3 ? Colors.green : 
                                               (w.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${w.totalLeaveDays} leaves',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkerDetailPage(worker: w),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      if (workers.length > 5)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextButton(
                            onPressed: () {
                              // Show all workers in this workstation
                            },
                            child: Text('View all ${workers.length} workers'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWorkstationDialog(context);
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildWorkstationStats(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWorkstationDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Workstation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workstation Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Supervisor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: ['Aung Kyaw', 'Thiri Aung', 'Zaw Min', 'Hla Hla']
                  .map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workstation added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}