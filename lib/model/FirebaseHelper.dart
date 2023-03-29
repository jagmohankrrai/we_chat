
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:we_chat/model/users.dart';

class FirebaseHelper {

  static Future<users?> getUserModelById(String uid) async {
    users? userModel;

    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if(docSnap.data() != null) {
      userModel = users.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }

}