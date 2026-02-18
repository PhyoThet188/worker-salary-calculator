import 'package:flutter/material.dart';
import 'worker_list_page.dart';
import 'workstations_page.dart';
import '../worker/salary_record_page.dart';
import '../worker/leave_records_page.dart';
import '../worker/about_page.dart';
import '../worker/settings_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../models/worker_data.dart';
import '../../models/worker.dart';
import '../../models/salary_calculator.dart';
import 'worker_detail_page.dart';
import '../../services/report_service.dart';

class BossHomePage extends StatefulWidget {
  const BossHomePage({super.key});

  @override
  State<BossHomePage> createState() => _BossHomePageState();
}

class _BossHomePageState extends State<BossHomePage> {
  int _selectedIndex = 0;
  final worker = WorkerData.workers[0];

  late final List<Widget> _pages = [
    BossDashboard(),
    const WorkerListPage(),
    const WorkstationsPage(),
    BossLeaveRecordsPage(),
    const AboutPage(),
    const SettingsPage(),
  ];

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
    BottomNavItem(icon: Icons.people, label: 'Workers'),
    BottomNavItem(icon: Icons.work, label: 'Stations'),
    BottomNavItem(icon: Icons.calendar_today, label: 'Leaves'),
    BottomNavItem(icon: Icons.info, label: 'About'),
    BottomNavItem(icon: Icons.settings, label: 'Settings'),
  ];

  // Method to navigate to workers page with salary view
  void navigateToWorkersWithSalary() {
    setState(() {
      _selectedIndex = 1; // Workers page index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boss Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.orange),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}

class BossDashboard extends StatelessWidget {
  BossDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> stats = WorkerData.getDashboardStats();
    
    int totalWorkers = stats['totalWorkers'];
    int totalPresent = stats['totalPresent'];
    int totalLeave = stats['totalLeave'];
    double totalSalary = stats['totalSalary'];
    int fullAttendance = stats['fullAttendance'];
    int goodAttendance = stats['goodAttendance'];
    int noBonus = stats['noBonus'];
    double averageSalary = totalSalary / totalWorkers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Main Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildEnhancedStatCard(
                'Total Workers',
                totalWorkers.toString(),
                Icons.people,
                Colors.blue,
                'Active Employees',
              ),
              _buildEnhancedStatCard(
                'Present Today',
                totalPresent.toString(),
                Icons.check_circle,
                Colors.green,
                '${((totalPresent / totalWorkers) * 100).toStringAsFixed(1)}% Attendance',
              ),
              _buildEnhancedStatCard(
                'On Leave',
                totalLeave.toString(),
                Icons.calendar_today,
                Colors.orange,
                '${((totalLeave / totalWorkers) * 100).toStringAsFixed(1)}% of workforce',
              ),
              _buildEnhancedStatCard(
                'Total Payroll',
                '${(totalSalary / 1000000).toStringAsFixed(1)}M MMK',
                Icons.monetization_on,
                Colors.purple,
                'Avg: ${(averageSalary / 1000).toStringAsFixed(0)}K MMK',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Attendance Bonus Distribution
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Bonus Distribution',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBonusStat(
                          'Full Attendance',
                          fullAttendance,
                          totalWorkers,
                          Colors.green,
                          Icons.emoji_events,
                        ),
                      ),
                      Expanded(
                        child: _buildBonusStat(
                          'Good Attendance',
                          goodAttendance,
                          totalWorkers,
                          Colors.orange,
                          Icons.warning,
                        ),
                      ),
                      Expanded(
                        child: _buildBonusStat(
                          'No Bonus',
                          noBonus,
                          totalWorkers,
                          Colors.red,
                          Icons.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Salary Overview Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Salary Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Salary Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildSalaryStat(
                          'Average Salary',
                          '${(averageSalary / 1000).toStringAsFixed(0)}K MMK',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildSalaryStat(
                          'Min Salary',
                          '${(_getMinSalary() / 1000).toStringAsFixed(0)}K MMK',
                          Icons.trending_down,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildSalaryStat(
                          'Max Salary',
                          '${(_getMaxSalary() / 1000).toStringAsFixed(0)}K MMK',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Salary Range Distribution
                  const Text(
                    'Salary Distribution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSalaryRangeChart(),
                  
                  const SizedBox(height: 16),
                  
                  // Top Earners Preview
                  const Text(
                    'Top 5 Highest Paid',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._getTopEarners().map((worker) => ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        worker.name[0],
                        style: const TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                    title: Text(
                      worker.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      worker.position,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          SalaryCalculator.formatCurrency(worker.baseSalary),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Bonus: ${_getBonusStatus(worker.totalLeaveDays)}',
                          style: TextStyle(
                            fontSize: 9,
                            color: _getBonusColor(worker.totalLeaveDays),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkerDetailPage(worker: worker),
                        ),
                      );
                    },
                  )),
                  
                  const SizedBox(height: 8),
                  
                  // View All Button - Fixed to navigate to workers page
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Find the BossHomePageState and navigate to workers page
                        final bossHomePageState = context.findAncestorStateOfType<_BossHomePageState>();
                        if (bossHomePageState != null) {
                          bossHomePageState.navigateToWorkersWithSalary();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View All Workers with Salary'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Top Workstations
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Workstations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._getTopWorkstations().map((station) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildWorkstationOverview(station),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Add Worker',
                          Icons.person_add,
                          Colors.green,
                          () {
                            _showAddWorkerDialog(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Payroll',
                          Icons.receipt,
                          Colors.blue,
                          () {
                            _showPayrollDialog(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          'Reports',
                          Icons.bar_chart,
                          Colors.orange,
                          () {
                            _showReportsDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activities
          const Text(
            'Recent Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final worker = WorkerData.workers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      worker.name[0],
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                  title: Text(worker.name),
                  subtitle: Text('Salary calculated for ${worker.position}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${DateTime.now().hour - index}:${DateTime.now().minute}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '${worker.baseSalary.toStringAsFixed(0)} MMK',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerDetailPage(worker: worker),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusStat(String label, int count, int total, Color color, IconData icon) {
    double percentage = (count / total * 100);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSalaryRangeChart() {
    // Calculate salary ranges
    int range1 = WorkerData.workers.where((w) => w.baseSalary < 500000).length;
    int range2 = WorkerData.workers.where((w) => w.baseSalary >= 500000 && w.baseSalary < 700000).length;
    int range3 = WorkerData.workers.where((w) => w.baseSalary >= 700000 && w.baseSalary < 900000).length;
    int range4 = WorkerData.workers.where((w) => w.baseSalary >= 900000).length;
    
    return Column(
      children: [
        _buildSalaryRange('Below 500K', range1, Colors.blue.shade100),
        _buildSalaryRange('500K - 700K', range2, Colors.blue.shade200),
        _buildSalaryRange('700K - 900K', range3, Colors.blue.shade300),
        _buildSalaryRange('Above 900K', range4, Colors.blue.shade400),
      ],
    );
  }

  Widget _buildSalaryRange(String label, int count, Color color) {
    double percentage = count / WorkerData.workers.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 20,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count workers',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkstationOverview(Map<String, dynamic> station) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            station['name'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${station['workers']} workers',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          flex: 2,
          child: LinearProgressIndicator(
            value: station['attendance'] / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              station['attendance'] >= 90 ? Colors.green :
              (station['attendance'] >= 75 ? Colors.orange : Colors.red)
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${station['attendance']}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: station['attendance'] >= 90 ? Colors.green :
                   (station['attendance'] >= 75 ? Colors.orange : Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTopWorkstations() {
    Map<String, Map<String, dynamic>> workstationStats = {};
    
    for (var worker in WorkerData.workers) {
      if (!workstationStats.containsKey(worker.workstation)) {
        workstationStats[worker.workstation] = {
          'workers': 0,
          'totalPresent': 0,
        };
      }
      workstationStats[worker.workstation]!['workers'] = 
          (workstationStats[worker.workstation]!['workers'] as int) + 1;
      workstationStats[worker.workstation]!['totalPresent'] = 
          (workstationStats[worker.workstation]!['totalPresent'] as int) + worker.totalPresentDays;
    }

    List<Map<String, dynamic>> stats = [];
    workstationStats.forEach((name, data) {
      int workers = data['workers'];
      int totalPresent = data['totalPresent'];
      double avgAttendance = (totalPresent / (workers * 26)) * 100;
      
      stats.add({
        'name': name,
        'workers': workers,
        'attendance': avgAttendance.round(),
      });
    });

    stats.sort((a, b) => b['attendance'].compareTo(a['attendance']));
    return stats.take(5).toList();
  }

  List<Worker> _getTopEarners() {
    List<Worker> sorted = List.from(WorkerData.workers);
    sorted.sort((a, b) => b.baseSalary.compareTo(a.baseSalary));
    return sorted.take(5).toList();
  }

  double _getMinSalary() {
    return WorkerData.workers.map((w) => w.baseSalary).reduce((a, b) => a < b ? a : b);
  }

  double _getMaxSalary() {
    return WorkerData.workers.map((w) => w.baseSalary).reduce((a, b) => a > b ? a : b);
  }

  String _getBonusStatus(int leaveDays) {
    if (leaveDays <= 3) return 'Full Bonus';
    if (leaveDays <= 5) return 'Good Bonus';
    return 'No Bonus';
  }

  Color _getBonusColor(int leaveDays) {
    if (leaveDays <= 3) return Colors.green;
    if (leaveDays <= 5) return Colors.orange;
    return Colors.red;
  }

  void _showAddWorkerDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController positionController = TextEditingController();
    final TextEditingController workstationController = TextEditingController();
    final TextEditingController salaryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Worker'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: workstationController,
                decoration: const InputDecoration(
                  labelText: 'Workstation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.factory),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(
                  labelText: 'Base Salary',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
                SnackBar(
                  content: Text('Worker ${nameController.text} added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPayrollDialog(BuildContext context) {
    double totalSalary = WorkerData.workers.fold(0.0, (sum, w) => sum + w.baseSalary);
    double averageSalary = totalSalary / WorkerData.workers.length;
    int fullAttendance = WorkerData.workers.where((w) => w.totalLeaveDays <= 3).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payroll Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text('Total Workers'),
                trailing: Text('${WorkerData.workers.length}'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green),
                title: const Text('Total Payroll'),
                trailing: Text('${(totalSalary / 1000000).toStringAsFixed(1)}M MMK'),
              ),
              ListTile(
                leading: const Icon(Icons.trending_up, color: Colors.orange),
                title: const Text('Average Salary'),
                trailing: Text('${(averageSalary / 1000).toStringAsFixed(0)}K MMK'),
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: const Text('Full Attendance Bonus'),
                trailing: Text('${fullAttendance * 50000} MMK'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportOptions(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Payroll'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ReportService.generatePdfReport();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PDF report generated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Export as Excel'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await ReportService.generateExcelReport();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Excel report generated'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                subtitle: const Text('Generate PDF report with all worker details'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ReportService.generatePdfReport();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PDF report generated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generating PDF: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as Excel'),
                subtitle: const Text('Generate Excel spreadsheet with all data'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ReportService.generateExcelReport();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Excel report generated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generating Excel: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('Email Report'),
                subtitle: const Text('Share report via email'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ReportService.shareReport();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report ready to share'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error sharing report: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.summarize, color: Colors.purple),
                title: const Text('View Summary'),
                subtitle: const Text('Display summary statistics'),
                onTap: () {
                  Navigator.pop(context);
                  _showSummaryDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSummaryDialog(BuildContext context) {
    String summary = ReportService.generateSummaryText();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Summary'),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(8),
            child: Text(
              summary,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Summary copied to clipboard'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}

class BossLeaveRecordsPage extends StatelessWidget {
  BossLeaveRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leave Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending Approvals: 5',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              final worker = WorkerData.workers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: worker.totalLeaveDays <= 3 ? Colors.green.shade100 : 
                                   (worker.totalLeaveDays <= 5 ? Colors.orange.shade100 : Colors.red.shade100),
                    child: Text(
                      worker.name[0],
                      style: TextStyle(
                        color: worker.totalLeaveDays <= 3 ? Colors.green : 
                               (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                      ),
                    ),
                  ),
                  title: Text(worker.name),
                  subtitle: Text('${worker.position} - ${worker.workstation}'),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: worker.totalLeaveDays <= 3 ? Colors.green.withOpacity(0.1) :
                             (worker.totalLeaveDays <= 5 ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${worker.totalLeaveDays} days',
                      style: TextStyle(
                        color: worker.totalLeaveDays <= 3 ? Colors.green :
                               (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildLeaveDetail('Total Present:', '${worker.totalPresentDays} days'),
                          _buildLeaveDetail('Total Leave:', '${worker.totalLeaveDays} days'),
                          _buildLeaveDetail('Bonus Status:', 
                              worker.totalLeaveDays <= 3 ? 'Full Attendance (50,000 MMK)' :
                              (worker.totalLeaveDays <= 5 ? 'Good Attendance (20,000 MMK)' : 'No Bonus'),
                              color: worker.totalLeaveDays <= 3 ? Colors.green :
                                     (worker.totalLeaveDays <= 5 ? Colors.orange : Colors.red)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(foregroundColor: Colors.green),
                                child: const Text('Approve'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Reject'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveDetail(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}