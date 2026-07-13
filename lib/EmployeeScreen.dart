import 'package:flutter/material.dart';
import 'today_screen.dart';
import 'homepage.dart';
import 'historyPage.dart';

class CheckInStatus {
  static bool isCheckedIn = false;

  static void reset() {
    isCheckedIn = false;
    print("Check-in status has been reset.");
  }
}

class EmployeeScreen extends StatelessWidget {
  final String employeeId;

  const EmployeeScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text('พนักงาน'),
        backgroundColor: const Color(0xFFEAD8C9),
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded),
          color: Colors.black,
          onPressed: () {
            CheckInStatus.reset();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/KobBlur.png', height: 40),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            // ปุ่มเข้างาน-ออกงาน
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodayScreen(employeeId: employeeId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'เข้างาน-ออกงาน',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // ปุ่มประวัติการทำงาน
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryScreen(employeeId: employeeId), // ส่ง employeeId ไปที่ HistoryScreen
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFFD7BFBF), // สีพื้นหลังของปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'ประวัติการทำงาน',
                  style: TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
