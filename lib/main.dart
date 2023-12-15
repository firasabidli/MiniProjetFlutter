import 'package:flutter/material.dart';
import 'package:project/pages/auth.dart';
import 'package:project/pages/home_page.dart';
import 'package:project/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/pages/signUp.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyDk3s7RdbN5uWDVeo9aXFeSBnY6NrPqzV0',
      authDomain: 'project-ba7d6.firebaseapp.com',
      projectId: 'project-ba7d6',
      storageBucket: 'project-ba7d6.appspot.com',
      messagingSenderId: '821273593438',
      appId: '1:821273593438:android:c6db50bf5de8a53e08d6cf',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      // home: const Auth(),
      routes: {
        '/':(context) => const Auth(),
        'homePage': (context) => const HomePage(),
        'signupPage':(context) => const SignupPage(),
        'signinPage':(context) => const LoginPage(),
      },
    );
  }
}

