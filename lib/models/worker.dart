class Worker {
  final String id;
  final String name;
  final String workstation;
  final double baseSalary;
  final double dailyRate;
  final String position;
  final String phone;
  final String joinDate;
  final String username;
  final String password;
  final String email;
  final String address;
  final String emergencyContact;
  int totalLeaveDays;
  int totalPresentDays;

  Worker({
    required this.id,
    required this.name,
    required this.workstation,
    required this.baseSalary,
    required this.dailyRate,
    required this.position,
    required this.phone,
    required this.joinDate,
    required this.username,
    required this.password,
    required this.email,
    required this.address,
    required this.emergencyContact,
    this.totalLeaveDays = 0,
    this.totalPresentDays = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workstation': workstation,
      'baseSalary': baseSalary,
      'dailyRate': dailyRate,
      'position': position,
      'phone': phone,
      'joinDate': joinDate,
      'username': username,
      'password': password,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'totalLeaveDays': totalLeaveDays,
      'totalPresentDays': totalPresentDays,
    };
  }

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'],
      name: json['name'],
      workstation: json['workstation'],
      baseSalary: json['baseSalary'],
      dailyRate: json['dailyRate'],
      position: json['position'],
      phone: json['phone'],
      joinDate: json['joinDate'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      totalLeaveDays: json['totalLeaveDays'] ?? 0,
      totalPresentDays: json['totalPresentDays'] ?? 0,
    );
  }
}