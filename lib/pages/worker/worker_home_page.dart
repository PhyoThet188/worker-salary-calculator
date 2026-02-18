import 'package:flutter/material.dart';
import 'salary_calculation_page.dart';
import 'salary_record_page.dart';
import 'leave_records_page.dart';
import 'profile_page.dart';
import 'about_page.dart';
import 'settings_page.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../models/worker.dart';

class WorkerHomePage extends StatefulWidget {
  final Worker worker;

  const WorkerHomePage({super.key, required this.worker});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    SalaryCalculationPage(worker: widget.worker),
    SalaryRecordPage(worker: widget.worker),  // Now passing worker
    LeaveRecordsPage(worker: widget.worker),  // Now passing worker
    ProfilePage(worker: widget.worker),
    const AboutPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 3;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.worker.name[0],
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
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
        items: const [
          BottomNavItem(icon: Icons.calculate, label: 'Calculate'),
          BottomNavItem(icon: Icons.history, label: 'Records'),
          BottomNavItem(icon: Icons.calendar_today, label: 'Leave'),
          BottomNavItem(icon: Icons.person, label: 'Profile'),
          BottomNavItem(icon: Icons.info, label: 'About'),
          BottomNavItem(icon: Icons.settings, label: 'Settings'),
        ],
      ),
    );
  }
}