import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'AttendancePage.dart';
import 'admin_OT.dart';
import 'employee_data.dart';
import 'homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenu extends StatefulWidget {
  final String adminId;

  const AdminMenu({Key? key, required this.adminId}) : super(key: key);

  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  late String firebaseUsername = "";
  String? adminName = "";
  String currentTime = "";
  String currentDate = "";

  @override
  void initState() {
    super.initState();
    currentTime = DateFormat('hh:mm a').format(DateTime.now().toLocal());
    currentDate = DateFormat('MMM d, yyyy').format(DateTime.now().toLocal());
    _fetchAdminName();
  }

  Future<void> _fetchAdminName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('systems')
          .doc('admins')
          .collection('admins')
          .doc(widget.adminId)
          .get();

      if (snapshot.exists) {
        setState(() {
          firebaseUsername = snapshot['name'] ?? 'ไม่มีชื่อ'; // ดึงชื่อผู้ใช้งาน
        });
        print("Firebase username fetched: $firebaseUsername");
      } else {
        print("No admin data found.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EDE8),
      appBar: AppBar(
        title: const Text('ผู้ดูแลระบบ'),
        backgroundColor: const Color(0xFFEAD8C9),
        leading: IconButton(  // เพิ่มปุ่มล็อกเอาต์ที่มุมซ้ายบน
          icon: Icon(Icons.logout_rounded),
          color: Colors.black,
          onPressed: () {
            // เมื่อกดปุ่มล็อกเอาต์ จะกลับไปหน้า homepage
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // หน้า homepage
                  (Route<dynamic> route) => false, //
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Button for Attendance Schedule
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendancePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D1B2), // Light brown color for button
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ตารางการเข้า-ออกพนักงาน', // Attendance schedule
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Icon(Icons.access_time, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button for Overtime History
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOT()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB59479), // Darker brown color for button
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ประวัติการทำโอทีพนักงาน', // Overtime history
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Icon(Icons.edit, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button for Employee Data Summary
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeData()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D1B2), // Light brown color for button
                padding: const EdgeInsets.symmetric(vertical: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'สรุปผลข้อมูลพนักงาน', // Employee data summary
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    Icon(Icons.person, color: Colors.black),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Date Display
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8A614A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Time Display
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentTime,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8A614A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Firebase Username Display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'ชื่อผู้ใช้งาน: $firebaseUsername',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A614A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


