import 'worker.dart';

class WorkerData {
  static List<Worker> generateWorkers() {
    List<Worker> workers = [];
    
    List<String> myanmarNames = [
      'Aung Kyaw', 'Thiri Aung', 'Zaw Min', 'Hla Hla', 'Kyaw Kyaw',
      'Su Su', 'Myo Myint', 'Nandar', 'Ye Win', 'May Thu',
      'Thet Naing', 'Khin Khin', 'Win Zaw', 'Ei Mon', 'Soe Min',
      'Phyu Phyu', 'Aye Aye', 'Tun Tun', 'Moe Moe', 'Zin Mar',
      'Kaung Kaung', 'Thandar', 'Kyaw Swar', 'Yin Yin', 'Htet Htet',
      'Wai Yan', 'Thuzar', 'Aung Aung', 'Sandar', 'Min Min',
      'Lwin Lwin', 'Khaing Khaing', 'Myat Noe', 'Sithu', 'Thiri',
      'Yamin', 'Zaw Zaw', 'Hnin Hnin', 'Aung Min', 'Su Mon',
      'Kyaw Thu', 'May May', 'Thein Tun', 'Ei Ei', 'Soe Soe',
      'Min Thu', 'Yee Yee', 'Wint War', 'Nay Chi', 'Thura'
    ];

    List<String> workstations = [
      'Assembly Line A', 'Assembly Line B', 'Packaging', 'Quality Control',
      'Maintenance', 'Warehouse A', 'Warehouse B', 'Shipping', 'Receiving',
      'Metal Workshop', 'Wood Workshop', 'Electronics', 'Textile Section',
      'Painting Unit', 'Cleaning Unit', 'Security', 'Cafeteria', 'Admin Support',
      'Logistics', 'Inventory', 'Tool Room', 'Machine Shop', 'Testing Lab',
      'Research Unit', 'Training Center', 'Dispatch', 'Loading Dock',
      'Cold Storage', 'Dry Storage', 'Chemical Handling'
    ];

    List<String> positions = [
      'Operator', 'Technician', 'Supervisor', 'Assistant', 'Clerk',
      'Guard', 'Cleaner', 'Packer', 'Driver', 'Mechanic',
      'Electrician', 'Welder', 'Painter', 'Inspector', 'Store Keeper'
    ];

    List<String> addresses = [
      'No.123, Hlaing Township, Yangon',
      'No.456, Kamayut Township, Yangon',
      'No.789, Mayangone Township, Yangon',
      'No.234, Bahan Township, Yangon',
      'No.567, Dagon Township, Yangon',
      'No.890, Sanchaung Township, Yangon',
      'No.345, Ahlone Township, Yangon',
      'No.678, Lanmadaw Township, Yangon',
      'No.901, Latha Township, Yangon',
      'No.123, Pazundaung Township, Yangon',
    ];

    for (int i = 0; i < 3000; i++) {  // Start from 0
      int nameIndex = i % myanmarNames.length;
      String baseName = myanmarNames[nameIndex];
      
      // Generate name with number
      String name = '$baseName ${(i ~/ 50) + 1}';
      
      // Fix username generation - use the base name without spaces
      String baseNameWithoutSpaces = baseName.toLowerCase().replaceAll(' ', '');
      String username = baseNameWithoutSpaces + (i + 1).toString();  // i+1 for user number
      
      String workstation = workstations[i % workstations.length];
      String position = positions[i % positions.length];
      
      double baseSalary = 450000 + ((i + 1) * 1500) % 600000;
      double dailyRate = baseSalary / 26;
      String password = 'worker${(i + 1).toString().padLeft(4, '0')}';  // i+1 for password

      workers.add(Worker(
        id: 'W${(i + 1).toString().padLeft(4, '0')}',  // i+1 for ID
        name: name,
        workstation: workstation,
        baseSalary: baseSalary,
        dailyRate: dailyRate,
        position: position,
        phone: '09${(100000000 + i + 1) % 1000000000}',
        joinDate: '202${i % 4}-${(i % 12) + 1}-${(i % 28) + 1}',
        username: username,
        password: password,
        email: '$username@company.com',
        address: addresses[i % addresses.length],
        emergencyContact: '09${(200000000 + i + 1) % 1000000000}',
        totalLeaveDays: (i + 1) % 10,
        totalPresentDays: 26 - ((i + 1) % 10),
      ));
    }

    return workers;
  }

  static List<Worker> workers = generateWorkers();

  static Worker? login(String username, String password, String userType) {
    print('=' * 50);
    print('Login attempt - Username: "$username", Password: "$password", Type: $userType');
    
    if (userType == 'boss') {
      if (username == 'boss' && password == 'boss123') {
        print('Boss login successful');
        return null;
      }
      print('Boss login failed');
      return null;
    } else {
      try {
        // Print first 10 workers for debugging
        print('\nFirst 10 workers in database:');
        for (int i = 0; i < 10; i++) {
          print('  Worker ${i+1}: Username="${workers[i].username}", Password="${workers[i].password}", Name="${workers[i].name}"');
        }
        
        print('\nSearching for username: "$username"');
        
        Worker? foundWorker;
        for (var worker in workers) {
          if (worker.username == username) {
            print('Found username match: ${worker.username}');
            if (worker.password == password) {
              print('Password match successful!');
              foundWorker = worker;
              break;
            } else {
              print('Password mismatch. Expected: ${worker.password}, Got: $password');
            }
          }
        }
        
        if (foundWorker != null) {
          print('Login successful for: ${foundWorker.name}');
          return foundWorker;
        } else {
          print('No matching username found');
          return null;
        }
      } catch (e) {
        print('Login error: $e');
        return null;
      }
    }
  }

  static Map<String, dynamic> getDashboardStats() {
    int totalWorkers = workers.length;
    int totalPresent = workers.fold(0, (sum, w) => sum + w.totalPresentDays) ~/ 30;
    int totalLeave = workers.fold(0, (sum, w) => sum + w.totalLeaveDays);
    double totalSalary = workers.fold(0, (sum, w) => sum + w.baseSalary);
    int fullAttendance = workers.where((w) => w.totalLeaveDays <= 3).length;
    int goodAttendance = workers.where((w) => w.totalLeaveDays > 3 && w.totalLeaveDays <= 5).length;
    
    return {
      'totalWorkers': totalWorkers,
      'totalPresent': totalPresent,
      'totalLeave': totalLeave,
      'totalSalary': totalSalary,
      'fullAttendance': fullAttendance,
      'goodAttendance': goodAttendance,
      'noBonus': totalWorkers - fullAttendance - goodAttendance,
    };
  }

  static List<Worker> getWorkersByWorkstation(String workstation) {
    return workers.where((w) => w.workstation == workstation).toList();
  }
}