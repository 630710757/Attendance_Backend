import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class TodayScreen extends StatefulWidget {
  final String employeeId;

  const TodayScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  late String employeeId;
  String employeeName = '';
  String checkInTime = '--:--';
  String checkOutTime = '--:--';
  bool isCheckedIn = false;
  String currentDate = '';
  String workStatus = '----';
  String gpsLocation = 'ไม่ทราบตำแหน่ง';

  @override
  void initState() {
    super.initState();
    employeeId = widget.employeeId;
    currentDate = _getCurrentDate();
    _fetchEmployeeName();
    _fetchCheckInOutData(); // เรียกใช้เพื่อดึงข้อมูลเช็คอินและเช็คเอาท์เมื่อเริ่มต้น
  }
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

  String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(now);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('HH:mm');
    return formatter.format(now);
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      setState(() {
        gpsLocation =
        '${placemarks[0].locality}, ${placemarks[0].country}';
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        gpsLocation = '96/8 บริษัท อึ่งไข่ จำกัดมหาชน จ.กรุงเทพมหานคร';
      });
    }
  }

  Future<void> _saveCheckInOutData() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await FirebaseFirestore.instance
          .collection('systems') // แก้ไขเป็น 'systems'
          .doc('employees') // Document สำหรับ 'employees'
          .collection('employees') // Subcollection สำหรับ 'employees'
          .doc(employeeId) // ID ของพนักงาน (เช่น 'E129')
          .collection('attendance_records') // Subcollection สำหรับบันทึกการเข้า
          .doc(formattedDate)
          .set({
        'check_in_time': checkInTime,
        'check_out_time': checkOutTime,
        'date': formattedDate,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'gps_location': gpsLocation,
        'work_status': workStatus,
      }, SetOptions(merge: true));
      print("Check In/Out data saved successfully.");
    } catch (e) {
      print("Error saving Check In/Out data: $e");
    }
  }

  Future<void> toggleCheckInOut() async {
    if (!isCheckedIn) {
      setState(() {
        checkInTime = _getCurrentTime();
        checkOutTime = '--:--';
        isCheckedIn = true;
        workStatus = 'กำลัง...';
        gpsLocation = 'กำลังค้นหาตำแหน่ง...';
      });

      try {
        await _getLocation();
        if (_isLate(checkInTime)) {
          workStatus = 'สาย';
        } else {
          workStatus = 'ปกติ';
        }
        await _saveCheckInOutData();
      } catch (e) {
        setState(() {
          gpsLocation = 'ไม่สามารถดึงข้อมูลตำแหน่งได้';
        });
      }
    } else {
      setState(() {
        checkOutTime = _getCurrentTime();
        isCheckedIn = false;
      });
      await _saveCheckInOutData();
    }
  }

  bool _isLate(String checkInTime) {
    DateTime checkInDateTime = DateFormat('HH:mm').parse(checkInTime);
    DateTime earlyThreshold = DateFormat('HH:mm').parse('07:00'); // เวลาเช็คอินเริ่มต้น
    DateTime lateThreshold = DateFormat('HH:mm').parse('08:30'); // เวลาเช็คอินสิ้นสุด

    // ตรวจสอบว่าเช็คอินสายหรือไม่
    if (checkInDateTime.isBefore(earlyThreshold) || checkInDateTime.isAfter(lateThreshold)) {
      return true; // เช็คอินสาย
    }
    return false; // เช็คอินไม่สาย (ในช่วงเวลาปกติ)
  }

  Future<void> _fetchCheckInOutData() async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('systems') // ตรวจสอบว่าทางนี้ถูกต้อง
          .doc('employees')
          .collection('employees')
          .doc(employeeId)
          .collection('attendance_records')
          .doc(formattedDate)
          .get();

      if (snapshot.exists) {
        setState(() {
          checkInTime = snapshot['check_in_time'] ?? '--:--';
          checkOutTime = snapshot['check_out_time'] ?? '--:--';
          isCheckedIn = checkInTime != '--:--';
          workStatus = snapshot['work_status'] ?? '----';
          gpsLocation = snapshot['gps_location'] ?? 'ไม่ทราบตำแหน่ง';
        });
        print("ข้อมูลถูกดึงมาแล้ว: $checkInTime, $checkOutTime, $workStatus, $gpsLocation");
      } else {
        print("ไม่พบข้อมูลการเช็คอิน/เช็คเอาท์สำหรับวันที่ $formattedDate");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการดึงข้อมูลเช็คอิน/เช็คเอาท์: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false; // ป้องกันการย้อนกลับหน้า
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Employee Container
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: const Color(0xFFEAD8C9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'พนักงาน',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Image.asset(
                        'assets/images/KobBlur.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9BA9F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('วันที่:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(currentDate, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('รหัสพนักงาน:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(employeeId, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ชื่อพนักงาน:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(employeeName, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('เวลาเข้าทำงาน:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(checkInTime, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('เวลาออกงาน:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(checkOutTime, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('สถานะการทำงาน:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(workStatus, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ตำแหน่ง GPS:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(gpsLocation, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // SlideAction จะปรากฏเมื่อยังไม่ได้เช็คเอ้าท์
                if (!isCheckedIn && checkOutTime == '--:--') // แสดง SlideAction สำหรับเช็คอิน
                  SlideAction(
                    text: 'CHECK IN',
                    onSubmit: () {
                      toggleCheckInOut();
                    },
                    elevation: 0,
                    outerColor: Colors.red,
                    innerColor: const Color(0xFF27A11E),
                    sliderButtonIcon: const Icon(Icons.check, color: Colors.white),
                  ),
                if (isCheckedIn && checkOutTime == '--:--') // แสดง SlideAction สำหรับเช็คเอ้าท์
                  SlideAction(
                    text: 'CHECK OUT',
                    onSubmit: () {
                      toggleCheckInOut();
                    },
                    elevation: 0,
                    outerColor: Colors.red,
                    innerColor: const Color(0xFF27A11E),
                    sliderButtonIcon: const Icon(Icons.check, color: Colors.white),
                  ),
                const SizedBox(height: 30),
                // Back Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A614A), // Brown color
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'ย้อนกลับ',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}