import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // นำเข้าแพ็กเกจ intl

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminOT(),
    );
  }
}

class AdminOT extends StatefulWidget {
  @override
  _AdminOTState createState() => _AdminOTState();
}

class _AdminOTState extends State<AdminOT> {
  final TextEditingController _employeeIdController = TextEditingController();
  String? _employeeId;
  List<Map<String, dynamic>> _otRecords = [];

  @override
  void dispose() {
    _employeeIdController.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr); // แปลงจาก String เป็น DateTime
    return DateFormat('dd-MM-yyyy').format(date); // แปลงเป็นวัน-เดือน-ปี
  }

  // ฟังก์ชันค้นหาข้อมูลโอที
  Future<void> _searchOvertimeRecords() async {
    String employeeId = _employeeIdController.text.trim();

    if (employeeId.isNotEmpty) {
      try {
        // ค้นหาข้อมูลในคอลเลกชัน attendance_records
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('systems')
            .doc('employees')
            .collection('employees')
            .doc(employeeId)
            .collection('attendance_records')
            .get();

        // ดึงเฉพาะวันที่มี ot_records
        List<Map<String, dynamic>> otData = [];
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('ot_records')) {
            otData.add({
              'date': _formatDate(doc.id), // ใช้ id ของเอกสารเป็นวันที่และแปลงเป็นวัน-เดือน-ปี
              'ot_records': data['ot_records'],
            });
          }
        }

        if (otData.isNotEmpty) {
          setState(() {
            _otRecords = otData;
            _employeeId = employeeId;
          });
        } else {
          _showSnackBar('ไม่พบข้อมูลโอที');
        }
      } catch (e) {
        _showSnackBar('เกิดข้อผิดพลาด: $e');
      }
    } else {
      _showSnackBar('กรุณากรอกรหัสพนักงาน');
    }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือน
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ส่วนบนสุดของหน้าจอ
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            width: double.infinity,
            color: const Color(0xFFEAD8C9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ประวัติการทำโอทีพนักงาน',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

          // ฟิลด์กรอกรหัสพนักงาน
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField (
                    controller: _employeeIdController,
                    decoration: InputDecoration(
                      labelText: 'กรอกรหัสพนักงาน',
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

                // ปุ่มค้นหา
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown
                  ),
                  onPressed: _searchOvertimeRecords,
                  child: Text(
                    'ค้นหา',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // แสดงข้อมูลการทำโอที
          Expanded(
            child: Container(
              color: Colors.white,
              child: _otRecords.isEmpty
                  ? Center(child: Text('ไม่มีข้อมูลการทำโอที'))
                  : ListView.builder(
                itemCount: _otRecords.length,
                itemBuilder: (context, index) {
                  var record = _otRecords[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('วันที่: ${record['date']}'), // แสดงวันที่ที่ถูกแปลงเป็น วัน-เดือน-ปี
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ประวัติการทำโอที: ${record['ot_records']} ชั่วโมง'), // แสดง ot_records เป็นชั่วโมง
                        ],
                      ),
                    ),
                  );
                },
              ),
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
    );
  }
}
