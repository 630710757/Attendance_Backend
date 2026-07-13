import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'EmployeeScreen.dart'; // นำเข้าหน้า EmployeeScreen
import 'admin_menu.dart'; // นำเข้าหน้า AdminMenu

class LoginPage extends StatefulWidget {
  final String userType; // รับพารามิเตอร์ userType

  const LoginPage({Key? key, required this.userType}) : super(key: key); // ประกาศใน constructor

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String id = idController.text.trim();
    String password = passwordController.text.trim();

    print("Attempting login with ID: $id");

    try {
      DocumentSnapshot snapshot;

      // ตรวจสอบประเภทผู้ใช้
      if (widget.userType.toLowerCase() == "admin") {
        snapshot = await FirebaseFirestore.instance
            .collection('systems') // คอลเลกชัน systems
            .doc('admins') // Document ของ admins
            .collection('admins') // แก้ไขชื่อคอลเลกชันให้ถูกต้อง
            .doc(id) // ID ของผู้ดูแลระบบ
            .get();
      } else {
        snapshot = await FirebaseFirestore.instance
            .collection('systems') // คอลเลกชัน systems
            .doc('employees') // Document ของ employees
            .collection('employees') // Subcollection ของ employees
            .doc(id) // ID ของพนักงาน
            .get();
      }

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        print("Data fetched from Firestore: $data");

        if (data['password'] == password) {
          // บันทึกข้อมูลการล็อกอิน
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', id); // บันทึก userId
          await prefs.setBool('isLoggedIn', true); // บันทึกสถานะล็อกอิน

          // นำทางไปยังหน้าที่เหมาะสม
          if (widget.userType.toLowerCase() == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminMenu(adminId: id)), // นำไปยัง AdminMenu
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeScreen(employeeId: id), // ส่ง employeeId ไปด้วย
              ),
            );
          }
        } else {
          _showErrorDialog('รหัสผ่านไม่ถูกต้อง'); // ข้อความแจ้งเตือนสำหรับรหัสผ่านไม่ถูกต้อง
        }
      } else {
        _showErrorDialog('ไม่พบผู้ใช้'); // ข้อความแจ้งเตือนสำหรับไม่พบผู้ใช้
      }
    } catch (e) {
      print("Error logging in: $e");
      _showErrorDialog('เกิดข้อผิดพลาด: $e'); // ข้อความแจ้งเตือนสำหรับข้อผิดพลาด
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('การล็อกอินล้มเหลว'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    String idHintText = widget.userType.toLowerCase() == "admin"
        ? "กรุณากรอกรหัสผู้ดูแลระบบ"
        : "กรุณากรอกรหัสพนักงาน";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.4,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEAD8C9),
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/1.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    widget.userType.toLowerCase() == "admin" ? 'รหัสผู้ดูแลระบบ' : 'รหัสพนักงาน',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(
                      hintText: idHintText,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'รหัสผ่าน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'กรุณากรอกรหัสผ่าน',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFF4B3C31),
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ปุ่มย้อนกลับ
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // สีพื้นหลังของปุ่ม
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // รูปแบบมุมปุ่ม
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ไม่สามารถย้อนกลับได้'),
                      ),
                    );
                  }
                },
                child: Text(
                  'ย้อนกลับ',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
