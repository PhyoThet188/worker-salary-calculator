import 'worker.dart';

class SalaryCalculator {
  static Map<String, dynamic> calculateSalary(Worker worker, int presentDays, int leaveDays) {
    double dailyRate = worker.baseSalary / 26;
    double overtimeHours = 0;
    double overtimeRate = dailyRate / 8 * 1.5;
    
    double baseSalary = dailyRate * presentDays;
    double overtimePay = overtimeHours * overtimeRate;
    
    double bonus = 0;
    String bonusType = 'None';
    
    if (leaveDays <= 3) {
      bonus = 50000;
      bonusType = 'Full Attendance Bonus';
    } else if (leaveDays <= 5) {
      bonus = 20000;
      bonusType = 'Good Attendance Bonus';
    }
    
    double totalSalary = baseSalary + overtimePay + bonus;
    double tax = totalSalary > 1000000 ? totalSalary * 0.02 : 0;
    double netSalary = totalSalary - tax;
    
    return {
      'workerName': worker.name,
      'workerId': worker.id,
      'workstation': worker.workstation,
      'dailyRate': dailyRate,
      'presentDays': presentDays,
      'leaveDays': leaveDays,
      'baseSalary': baseSalary,
      'overtimeHours': overtimeHours,
      'overtimePay': overtimePay,
      'bonus': bonus,
      'bonusType': bonusType,
      'totalSalary': totalSalary,
      'tax': tax,
      'netSalary': netSalary,
      'calculationDate': DateTime.now().toString(),
    };
  }
  
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} MMK';
  }
}