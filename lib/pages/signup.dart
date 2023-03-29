import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:we_chat/model/users.dart';
import 'package:we_chat/pages/completeprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/uihelp.dart';
class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  _signup createState() => _signup();
}

class _signup extends State<signup> {
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  TextEditingController cpasswordcontroller = new TextEditingController();

  void checkValues() {
    String email = emailcontroller.text.trim();
    String pass= passwordcontroller.text.trim();
    String cPass = cpasswordcontroller.text.trim();

    if(email == "" || pass == "" || cPass == "") {
      UIHelper.showAlertDialog(context, "Incomplete Data", "Please fill all the fields");
    }
    else if(pass != cPass) {
      UIHelper.showAlertDialog(context, "Password Mismatch", "The passwords you entered do not match!");
    }
    else {
      Signup(email, pass);
    }
  }
  void Signup( String email,String pass) async{
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Creating new account..");

    try{
      credential=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);

    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UIHelper.showAlertDialog(context, "An error occured", ex.message.toString());
    }
    if(credential!=null)
      {
        String uid=credential.user!.uid;
        users newuser=users(uid:uid, full_name:"", email:email, dp:"");
        await FirebaseFirestore.instance.collection("users").doc(uid).set(newuser.toMap()).then((value) {
          print("new user created");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return profile(user: newuser, firebaseUser: credential!.user!);
            }),
          );
        });
      }
    else
      {
        print("Null");
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Chat  App",style: GoogleFonts.poppins(fontStyle: FontStyle.italic,fontSize: 30), ),
                  SizedBox(width: 30,),
                  TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      labelText :"E-mail",
                    ),
                  ),
                  SizedBox(width: 10,),
                  TextField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText :"Password",

                    ),
                  ),
                  TextField(
                    controller: cpasswordcontroller,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText :"Confirm Password",

                    ),
                  ),
                  SizedBox(height: 30,),
                  CupertinoButton(color:Color(0xff2C3E50),child: Text("Sign Up",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16),), onPressed: (){
                    checkValues();
                  },)
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have a Account",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16), ),
            CupertinoButton(child: Text("Log In",style: GoogleFonts.lato(fontStyle: FontStyle.italic,fontSize: 16),), onPressed: (){

              Navigator.pop(context);
            },)

          ],
        ),
      ),
    );
  }
}
