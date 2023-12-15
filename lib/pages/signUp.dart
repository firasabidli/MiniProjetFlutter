import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
@override
  State<SignupPage> createState() => _SignupPageState(); }
class _SignupPageState extends State<SignupPage> {

  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Future signUp() async {
   if (passworConfirmed()){
     await FirebaseAuth.instance.createUserWithEmailAndPassword
       (email:_emailController.text.trim(),password:_passwordController.text.trim());
     Navigator.of(context).popAndPushNamed('/');
   }
  }
  bool passworConfirmed(){
    if(_passwordController.text.trim() == _confirmPasswordController.text.trim()){
      return true;
    }
    else{
      return false;
    }
  }
  void openSignInPage() {
    Navigator.of(context).popAndPushNamed('signinPage');
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
                  'SIGN UP',
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 40, fontWeight: FontWeight.bold),

                ),
                //subtitle
                Text(
                  'Welcome ! Here you can Sign Up',
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
                // confirm password
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border:InputBorder.none,
                          hintText: 'Confirm Password',
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
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Sign Up',
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
                    Text('already a memeber? ',
                      style: GoogleFonts.robotoCondensed(
                        fontWeight: FontWeight.bold,
                      ),),
                    GestureDetector(
                      onTap: openSignInPage,
                      child: Text('Sign In Here',
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
