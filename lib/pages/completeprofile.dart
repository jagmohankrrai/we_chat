import 'dart:developer';
import 'dart:io';
import 'package:we_chat/model/users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'hompage.dart';

class profile extends StatefulWidget {
   final users user;
   final User firebaseUser;

  const profile({super.key, required this.user, required this.firebaseUser});


  @override
  _profile createState() => _profile();
}

class _profile extends State<profile> {
   File? imagefile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if(pickedFile != null) {
      cropImage(pickedFile);
    }
  }
   void cropImage(XFile file) async {
     CroppedFile? croppedImage = await ImageCropper().cropImage(
       sourcePath: file.path,
       aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
       compressQuality: 20,
     );
     if (croppedImage != null) {
       setState(() {
         imagefile = File(croppedImage.path);
       });
     } else {
       print("null");
     }
   }

  void showPhotoOptions() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
              },
              leading: Icon(Icons.photo_album),
              title: Text("Select from Gallery"),
            ),

            ListTile(
              onTap: () {
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera_alt),
              title: Text("Take a photo"),
            ),

          ],
        ),
      );
    });
  }
  void checkValues() {
    String fullname = fullNameController.text.trim();

    if(fullname == "" || imagefile == null) {
      print("Please fill all the fields");
    }
    else {
      log("Uploading data..");
      uploadData();
    }
  }
   void uploadData() async {
     UploadTask uploadTask = FirebaseStorage.instance.ref("dp").child(widget.user!.uid.toString()).putFile(imagefile!);

     TaskSnapshot snapshot = await uploadTask;
     String? imageUrl = await snapshot.ref.getDownloadURL();
     String? fullname = fullNameController.text.trim();

     widget.user?.full_name = fullname;
     widget.user?.dp = imageUrl;

     await FirebaseFirestore.instance.collection("users").doc(widget.user?.uid).set(widget.user!.toMap()).then((value) {
       log("Data uploaded!");
       Navigator.popUntil(context, (route) => route.isFirst);
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) {
           return Hompage(user: widget.user, firebaseUser: widget.firebaseUser);
         }),
       );
     });
   }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text("Complete Profile"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: 40
          ),
          child: ListView(
            children: [

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: (imagefile != null) ? FileImage(imagefile!) : null,
                  child: (imagefile == null) ? Icon(Icons.person, size: 60,) : null,
                ),
              ),

              SizedBox(height: 20,),

              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                ),
              ),

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  checkValues();
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Submit"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
