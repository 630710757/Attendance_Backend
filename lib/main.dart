import 'package:flutter/material.dart';
import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyANJGLebPhakXUzMaGiCIYmP_HtOw-UcWs",
      appId: "1:400063563536:android:a4a65e7bdfae4b62740795",
      messagingSenderId: "79474332345",
      projectId: "project-d57f9",
      authDomain: "project-d57f9.firebaseapp.com",
      storageBucket: "project-d57f9.appspot.com",
    ),
  );
  runApp(const MyApp());
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


