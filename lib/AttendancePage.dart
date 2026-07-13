import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _employeeId; // รหัสพนักงานที่ค้นหา

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchEmployee() {
    setState(() {
      _employeeId = _searchController.text.trim(); // ตั้งค่ารหัสพนักงานที่ค้นหา
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ส่วนบนสุดของหน้าจอ (แสดงหัวข้อและโลโก้)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            width: double.infinity,
            color: const Color(0xFFEAD8C9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ตารางการเข้า-ออกงาน',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // โลโก้
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.transparent, // กรณีต้องการพื้นหลังโปร่งใส
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/1.png',
                      width: 60, // ปรับขนาดความกว้าง
                      height: 60, // ปรับขนาดความสูง
                      fit: BoxFit.cover, // ปรับขนาดให้ครอบคลุมพื้นที่
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ฟิลด์ค้นหาสำหรับรหัสพนักงาน
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'กรอกรหัสพนักงาน',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0), // ขอบมน
                          borderSide: BorderSide(
                              color: Colors.brown, // ขอบสีน้ำตาล
                              width: 2.0, // ความหนาของขอบ
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown
                  ),
                  onPressed: _searchEmployee,
                  child: Text('ค้นหา',
                      style: TextStyle(color: Colors.white)
                  ),
                ),
              ],
            ),
          ),

          // แสดงข้อมูลการเข้าออก
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _employeeId != null
                  ? FirebaseFirestore.instance
                  .collection('systems')
                  .doc('employees')
                  .collection('employees')
                  .doc(_employeeId)
                  .collection('attendance_records')
                  .snapshots()
                  : Stream.empty(), // ถ้าไม่ค้นหาจะใช้ Stream.empty()
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('ไม่มีข้อมูลการเข้า-ออก'));
                }

                final attendanceRecords = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    var recordData = attendanceRecords[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text('พนักงาน: $_employeeId'),
                        subtitle: Text(
                          'เข้า: ${recordData['check_in_time'] ?? 'ไม่ระบุ'}, '
                              'ออก: ${recordData['check_out_time'] ?? 'ไม่ระบุ'}',
                        ),
                        trailing: Text('วันที่: ${recordData['date'] ?? 'ไม่ระบุ'}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ปุ่มย้อนกลับ
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
                style: TextStyle(fontSize: 16,color: Colors.white),

              ),
            ),
          ),
        ],
      ),
    );
  }
}
