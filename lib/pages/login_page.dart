import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Future signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword
      (email:_emailController.text.trim(),password:_passwordController.text.trim());
    Navigator.of(context).popAndPushNamed('/');
  }
  void openSignUpPage() {
    Navigator.of(context).popAndPushNamed('signupPage');
  }
  @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body:SafeArea(
        child:Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
        children: [
            //image
              Image.asset('images/signIn.png',height: 150,),
              SizedBox(height: 20,),

            //title
              Text(
                  'SIGN IN',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 40, fontWeight: FontWeight.bold),

              ),
            //subtitle
            Text(
              'Welcome back! Nice to see you again',
              style: GoogleFonts.robotoCondensed(
                  fontSize: 18,),

            ),
            SizedBox(height: 50,),
            //email
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
               child: Container(
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border:InputBorder.none,
                    hintText: 'Email',
                  ),
                ),
              ),
            ),
            ),

            //password
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border:InputBorder.none,
                      hintText: 'Password',
                    ),
                  ),
                ),
              ),
            ),
            //sign in button
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: GestureDetector(
                onTap: signIn,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:Colors.blueAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text('Sign In',
                  style: GoogleFonts.robotoCondensed(
                    color:Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:18,
                  ),)),
                ),
              ),
            ),
            SizedBox(height: 25,),
            // text: sign up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Not yet a memeber? ',
                  style: GoogleFonts.robotoCondensed(
                    fontWeight: FontWeight.bold,
                  ),),
                GestureDetector(
                  onTap: openSignUpPage,
                  child: Text('Sign up Now',
                    style: GoogleFonts.robotoCondensed(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ],
            ),
        ],
      ),
          ),
    ),
      ),

    );
    }
  }

