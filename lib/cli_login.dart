import 'dart:io';
import 'models/worker_data.dart';
import 'models/worker.dart';

class CliLogin {
  static Future<void> start() async {
    print('\n' + '=' * 50);
    print('    WORKER SALARY CALCULATOR');
    print('=' * 50);
    
    while (true) {
      print('\nSelect login type:');
      print('1. Boss');
      print('2. Worker');
      print('3. Exit');
      print('-' * 30);
      stdout.write('Enter your choice (1-3): ');
      
      String? choice = stdin.readLineSync();
      
      switch (choice) {
        case '1':
          await _bossLogin();
          break;
        case '2':
          await _workerLogin();
          break;
        case '3':
          print('\nThank you for using Worker Salary Calculator!');
          return;
        default:
          print('\n❌ Invalid choice. Please enter 1, 2, or 3.');
      }
    }
  }

  static Future<void> _bossLogin() async {
    print('\n' + '-' * 30);
    print('BOSS LOGIN');
    print('-' * 30);
    
    stdout.write('Username: ');
    String? username = stdin.readLineSync();
    
    stdout.write('Password: ');
    String? password = stdin.readLineSync();
    
    if (username == 'boss' && password == 'boss123') {
      print('\n✅ Boss login successful!');
      print('Launching Boss Dashboard...');
      await Future.delayed(const Duration(seconds: 1));
      
      // Run Flutter app with Boss dashboard
      _runFlutterApp('boss');
    } else {
      print('\n❌ Invalid boss credentials!');
      print('\nPress Enter to continue...');
      stdin.readLineSync();
    }
  }

  static Future<void> _workerLogin() async {
    print('\n' + '-' * 30);
    print('WORKER LOGIN');
    print('-' * 30);
    
    stdout.write('Username: ');
    String? username = stdin.readLineSync();
    
    stdout.write('Password: ');
    String? password = stdin.readLineSync();
    
    Worker? worker = WorkerData.login(username ?? '', password ?? '', 'worker');
    
    if (worker != null) {
      print('\n✅ Login successful!');
      print('Welcome, ${worker.name}!');
      print('Position: ${worker.position}');
      print('Workstation: ${worker.workstation}');
      print('\nLaunching Worker Dashboard...');
      await Future.delayed(const Duration(seconds: 1));
      
      // Run Flutter app with Worker dashboard
      _runFlutterApp('worker', username: username, password: password);
    } else {
      print('\n❌ Invalid username or password!');
      print('\nHint: Try aungkyaw1 / worker0001');
      print('\nPress Enter to continue...');
      stdin.readLineSync();
    }
  }

  static void _runFlutterApp(String userType, {String? username, String? password}) {
    // Clear the screen
    print('\x1B[2J\x1B[0;0H');
    
    print('\n' + '=' * 50);
    print('    STARTING FLUTTER APPLICATION');
    print('=' * 50);
    print('\n');
    
    // Build the flutter run command
    String command;
    if (userType == 'boss') {
      command = 'flutter run -d chrome --dart-define=USER_TYPE=boss';
    } else {
      command = 'flutter run -d chrome --dart-define=USER_TYPE=worker --dart-define=USERNAME=$username --dart-define=PASSWORD=$password';
    }
    
    print('Running: $command');
    print('\n' + '-' * 50);
    print('Flutter app will start in a moment...'); 
    print('Press Ctrl+C to stop the app and return to CLI');
    print('-' * 50 + '\n');
    
    // Execute the flutter run command
    Process.run(command, [], runInShell: true).then((ProcessResult results) {
      print(results.stdout);
      print(results.stderr);
    });
  }
}

// Main function to run CLI
void main() async {
  await CliLogin.start();
}