import 'package:flutter/material.dart';
import 'login.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAD8C9), // สีพื้นหลังหลัก
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/1.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ข้อความ Login
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontFamily: 'YourCustomFont', // Make sure you add the custom font to pubspec.yaml or remove this line.
              ),
            ),
            const SizedBox(height: 48), // เว้นระยะห่างระหว่างข้อความกับปุ่ม

            // ปุ่ม Admin
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(userType: 'Admin')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3B09B), // สีของปุ่ม
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16), // เว้นระยะห่างระหว่างปุ่ม

            // ปุ่ม Employee
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(userType: 'Employee')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3B09B), // สีของปุ่ม
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'Employee',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
