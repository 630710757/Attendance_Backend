import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  final String employeeId; // เพิ่มการรับ employeeId

  const HistoryScreen({super.key, required this.employeeId});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> workHistory = [];
  bool hasSelectedDate = false;
  bool isTodayDataLoaded = false;
  bool isLoading = false; // เพิ่มตัวแปรสำหรับติดตามสถานะการโหลด
  String employeeName = ''; // ตัวแปรเก็บชื่อพนักงาน

  @override
  void initState() {
    super.initState();
    _fetchEmployeeName(); // ดึงชื่อพนักงานเมื่อเริ่มต้น
    _fetchTodayData(); // ดึงข้อมูลสำหรับวันปัจจุบันเมื่อเริ่มต้น
  }

  // ฟังก์ชันดึงชื่อพนักงานจาก Firestore
  Future<void> _fetchEmployeeName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('systems') // ตรวจสอบว่าทางนี้ถูกต้อง
          .doc('employees')
          .collection('employees')
          .doc(widget.employeeId)
          .get();

      if (snapshot.exists) {
        setState(() {
          employeeName = snapshot['name']; // ตรวจสอบให้แน่ใจว่าชื่อฟิลด์ 'name' ถูกต้อง
        });
        print("Employee name fetched: $employeeName"); // เพิ่มการพิมพ์ค่าที่ดึงมา
      } else {
        print("No employee data found.");
      }
    } catch (e) {
      print("Error fetching employee name: $e");
    }
  }

  // ฟังก์ชันดึงข้อมูลสำหรับวันปัจจุบันจากหน้า Today
  Future<void> _fetchTodayData() async {
    setState(() {
      isLoading = true; // ตั้งค่าเป็นกำลังโหลด
    });
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('systems') // ตรวจสอบว่าทางนี้ถูกต้อง
          .doc('employees')
          .collection('employees')
          .doc(widget.employeeId)
          .collection('attendance_records')
          .doc(date)
          .get();

      if (snapshot.exists) {
        setState(() {
          workHistory.clear();
          workHistory.add(snapshot.data() as Map<String, dynamic>);
          workHistory.last['employee_name'] = employeeName; // เพิ่มชื่อพนักงาน
          isTodayDataLoaded = true;
          hasSelectedDate = true;
        });
        print("Fetched today's data successfully");
      } else {
        print("No data found for today.");
      }
    } catch (e) {
      print("Error fetching today's data: $e");
    } finally {
      setState(() {
        isLoading = false; // ตั้งค่าโหลดเสร็จแล้ว
      });
    }
  }

// ฟังก์ชันดึงข้อมูลประวัติสำหรับวันที่เลือก
  Future<void> _fetchWorkHistoryForDate(DateTime date) async {
    setState(() {
      isLoading = true; // ตั้งค่าเป็นกำลังโหลด
    });
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('systems') // ตรวจสอบว่าทางนี้ถูกต้อง
          .doc('employees')
          .collection('employees')
          .doc(widget.employeeId)
          .collection('attendance_records')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        setState(() {
          // เพิ่มข้อมูลใหม่ลงในรายการ workHistory โดยไม่ล้างข้อมูลเดิม
          workHistory.add(snapshot.data() as Map<String, dynamic>);
          workHistory.last['employee_name'] = employeeName; // เพิ่มชื่อพนักงาน
          hasSelectedDate = true;
        });
      } else {
        print("No data found for this date.");
        if (formattedDate != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          _simulateWorkHistory(date); // เรียกใช้การจำลองข้อมูลเฉพาะเมื่อไม่ใช่วันปัจจุบัน
        }
      }
    } catch (e) {
      print("Error fetching data for selected date: $e");
    } finally {
      setState(() {
        isLoading = false; // ตั้งค่าโหลดเสร็จแล้ว
      });
    }
  }



  // ฟังก์ชันจำลองประวัติการทำงาน
  void _simulateWorkHistory(DateTime date) {
    var data = {
      'employee_id': widget.employeeId, // ใช้ widget.employeeId เพื่อให้มีรหัสพนักงาน
      'employee_name': employeeName, // ใช้ชื่อพนักงานที่ดึงมาจาก Firestore
      'check_in_time': '09:00',
      'check_out_time': '17:00',
      'gps_location': '96/8 บริษัท อึ่งไข่ จำกัดมหาชน จ.กรุงเทพมหานคร',
      'work_status': 'ปกติ',
      'date': DateFormat('yyyy-MM-dd').format(date),
    };

    setState(() {
      workHistory.clear(); // เคลียร์ข้อมูลเก่าก่อนเพิ่มใหม่
      workHistory.add(data);
      hasSelectedDate = true;
    });
    _saveToFirestore(data);
  }


  // ฟังก์ชันสำหรับบันทึกข้อมูลไปยัง Firestore
  Future<void> _saveToFirestore(Map<String, dynamic> data) async {
    String date = data['date'];
    try {
      DocumentReference documentRef = FirebaseFirestore.instance
          .collection('systems') // ตรวจสอบว่าทางนี้ถูกต้อง
          .doc('employees')
          .collection('employees')
          .doc(widget.employeeId)
          .collection('attendance_records')
          .doc(date);

      // ตรวจสอบว่า Document มีอยู่หรือไม่
      DocumentSnapshot snapshot = await documentRef.get();

      if (snapshot.exists) {
        // ถ้ามี Document อยู่แล้ว ใช้ set() เพื่ออัปเดตข้อมูล
        await documentRef.set(data, SetOptions(merge: true));
      } else {
        // ถ้าไม่มี Document ให้สร้างใหม่
        await documentRef.set(data);
      }
      print("Data saved to Firestore successfully.");
    } catch (e) {
      print("Error saving data to Firestore: $e");
    }
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
                  'ประวัติการทำงาน',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/1.png'),
                ),
              ],
            ),
          ),

          // พื้นที่ว่างตรงกลาง
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                          _fetchWorkHistoryForDate(picked);
                        });
                      }
                    },
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (hasSelectedDate || isTodayDataLoaded)
                    Expanded(
                      child: ListView.builder(
                        itemCount: workHistory.length,
                        itemBuilder: (context, index) {
                          final entry = workHistory[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text('รหัสพนักงาน: ${entry['employee_id']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ชื่อพนักงาน: ${entry['employee_name'] ?? 'ไม่ระบุ'}'),
                                  Text('เวลาเข้าทำงาน: ${entry['check_in_time'] ?? 'ไม่ระบุ'}'),
                                  Text('เวลาออกงาน: ${entry['check_out_time'] ?? 'ไม่ระบุ'}'),
                                  Text('ตำแหน่ง GPS: ${entry['gps_location'] ?? 'ไม่ระบุ'}'),
                                  Text('สถานะการทำงาน: ${entry['work_status'] ?? 'ไม่ระบุ'}'),
                                ],
                              ),
                              trailing: Text('วันที่: ${entry['date']}'),
                            ),
                          );
                        },
                      ),
                    ),
                  if (hasSelectedDate && workHistory.isEmpty)
                    const Text(
                      'ไม่พบข้อมูลสำหรับวันที่นี้',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                ],
              ),
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
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}