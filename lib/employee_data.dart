import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeData extends StatefulWidget {
  @override
  _EmployeeDataState createState() => _EmployeeDataState();
}

class _EmployeeDataState extends State<EmployeeData> {
  final TextEditingController _employeeIdController = TextEditingController();
  String? _employeeId;
  Map<String, dynamic> _summary = {
    'totalDays': 0,
    'totalOT': 0,
    'absent': 0,
    'late': 0,
    'normal': 0,
    'leave': 0,
  };

  // List of months in Thai
  final List<String> _months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  String? _selectedMonth;

  @override
  void dispose() {
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _searchEmployeeData() async {
    String employeeId = _employeeIdController.text.trim();

    if (employeeId.isNotEmpty && _selectedMonth != null) {
      try {
        // ค้นหาข้อมูลพนักงาน
        DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
            .collection('systems')
            .doc('employees')
            .collection('employees')
            .doc(employeeId)
            .get();

        if (employeeSnapshot.exists) {
          // ดึงข้อมูลรวมจากเอกสารพนักงาน
          var data = employeeSnapshot.data() as Map<String, dynamic>;

          // ดึงข้อมูลจาก subcollection attendance_records
          QuerySnapshot attendanceSnapshot = await FirebaseFirestore.instance
              .collection('systems')
              .doc('employees')
              .collection('employees')
              .doc(employeeId)
              .collection('attendance_records')
              .get();

          List<Map<String, dynamic>> attendanceRecords = [];
          for (var doc in attendanceSnapshot.docs) {
            Map<String, dynamic> recordData = doc.data() as Map<String, dynamic>;
            attendanceRecords.add(recordData);
          }

          // คำนวณข้อมูลสรุปตามเดือนที่เลือก
          int monthIndex = _months.indexOf(_selectedMonth!) + 1; // +1 for month index (1-12)
          int totalDays = 0;
          int totalOT = 0;
          int absent = 0;
          int late = 0;
          int normal = 0;
          int leave = 0;

          for (var record in attendanceRecords) {
            String dateString = record['date'];
            DateTime date = DateTime.parse(dateString);

            if (date.month == monthIndex) {
              totalDays++;

              // ดึงค่า OT และแปลงเป็นตัวเลข
              String? otString = record['ot_records'] as String?;
              int otHours = (otString != null) ? int.tryParse(otString.split(' ')[0]) ?? 0 : 0; // ป้องกันค่า null
              totalOT += otHours; // บันทึกจำนวนโอที

              // ใช้ฟิลด์ work_status สำหรับการนับ
              String? status = record['work_status'] as String?;
              if (status != null) {
                switch (status) {
                  case 'ขาด':
                    absent++;
                    break;
                  case 'สาย':
                    late++;
                    break;
                  case 'ปกติ':
                    normal++;
                    break;
                  case 'ลา':
                    leave++;
                    break;
                }
              }
            }
          }

          setState(() {
            _employeeId = employeeId;
            _summary = {
              'totalDays': totalDays,
              'totalOT': totalOT,
              'absent': absent,
              'late': late,
              'normal': normal,
              'leave': leave,
            };
          });

          // ตรวจสอบว่ามีการทำงานในเดือนนั้นหรือไม่
          if (totalDays == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ไม่มีการทำงานในเดือน $_selectedMonth')),
            );
          }
        } else {
          // หากไม่พบเอกสารพนักงาน
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่พบข้อมูลพนักงาน')),
          );
        }
      } catch (e) {
        // จัดการข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    } else {
      // แสดงข้อความหากยังไม่ได้เลือกเดือนหรือไม่กรอก ID พนักงาน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกรหัสพนักงานและเลือกเดือน')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Make the whole body scrollable
        child: Column(
          children: [
            // Custom AppBar using a Container
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              width: double.infinity,
              color: const Color(0xFFEAD8C9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'สรุปผลข้อมูลพนักงาน',
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

            // Input area for employee ID
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _employeeIdController,
                      decoration: InputDecoration(
                        hintText: 'กรอกรหัสพนักงาน',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0), // Rounded corners
                          borderSide: BorderSide(
                            color: Colors.brown, // Brown border
                            width: 2.0, // Border thickness
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, // Brown button background
                    ),
                    onPressed: _searchEmployeeData,
                    child: Text(
                      'ค้นหา',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ],
              ),
            ),

            // Dropdown for month selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<String>(
                value: _selectedMonth,
                hint: Text('เลือกเดือน'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMonth = newValue;
                  });
                },
                items: _months.map<DropdownMenuItem<String>>((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // Display employee data in a box
            if (_employeeId != null && _summary.isNotEmpty) ...[
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Set width to 90% of the screen width
                padding: const EdgeInsets.all(16.0), // Padding around the box
                decoration: BoxDecoration(
                  color: Color(0xFFEAD8C9), // Background color of the box
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.brown, // Brown border
                    width: 2.0,
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Horizontal margin
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลพนักงาน',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('รหัสพนักงาน: $_employeeId'),
                    Text('จำนวนวันทำงาน: ${_summary['totalDays']}'),
                    Text('จำนวนโอที: ${_summary['totalOT']} ชั่วโมง'),
                    Text('จำนวนวันที่ขาด: ${_summary['absent']} วัน'),
                    Text('จำนวนวันที่สาย: ${_summary['late']} วัน'),
                    Text('จำนวนวันที่ปกติ: ${_summary['normal']} วัน'),
                    Text('จำนวนวันที่ลา: ${_summary['leave']} วัน'),
                  ],
                ),
              ),
            ] else if (_employeeId != null) ...[
              Text('ไม่พบข้อมูลสำหรับรหัสพนักงาน $_employeeId'),
            ],
            SizedBox(height: 20), // Add some spacing

            // Back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // Background color of the "Back" button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners for the button
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  // Check if navigation can pop
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
