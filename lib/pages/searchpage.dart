import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../model/users.dart';
import '../model/chastmodel.dart';
import 'package:we_chat/pages/chatroom.dart';
class SearchPage extends StatefulWidget {
  final users userModel;
  final User firebaseUser;

  const SearchPage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  Future<chastmodel?> getChatroomModel(users targetUser) async {
    chastmodel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).where("participants.${targetUser.uid}", isEqualTo: true).get();

    if(snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      chastmodel existingChatroom = chastmodel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    }
    else {
      // Create a new one
      chastmodel newChatroom = chastmodel(
        roomid: uuid.v1(),
        lastmsg: "",
        prticipents: {
          widget.userModel.uid.toString():true,
          targetUser.uid.toString():true,
        },
      );

      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatroom.roomid).set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New Chatroom Created!");
    }

    return chatRoom;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Column(
            children: [

              TextField(
                controller: searchController,
                decoration: InputDecoration(
                    labelText: "Email Address"
                ),
              ),

              SizedBox(height: 20,),

              CupertinoButton(
                onPressed: () {
                  setState(() {});
                },
                color: Theme.of(context).colorScheme.secondary,
                child: Text("Search"),
              ),

              SizedBox(height: 20,),

              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").where("email", isEqualTo: searchController.text).where("email", isNotEqualTo: widget.userModel.email).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.active) {
                    if(snapshot.hasData) {
                      QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                      if(dataSnapshot.docs.length > 0) {
                        Map<String, dynamic> userMap = dataSnapshot.docs[0].data() as Map<String, dynamic>;print(userMap);
                        users searchedUser = users.fromMap(userMap);
                        return ListTile(
                          onTap: () async {
                            chastmodel?  chatroomModel = await getChatroomModel(searchedUser);

                            if(chatroomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomPage(
                                      targetUser: searchedUser,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                      chatroom: chatroomModel,
                                    );
                                  }
                              ));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(searchedUser.dp.toString()),
                            backgroundColor: Colors.grey[500],
                          ),
                          title: Text(searchedUser.full_name.toString()),
                          subtitle: Text(searchedUser.email.toString()),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return Text("No results found!");
                      }
                    } else if(snapshot.hasError) {
                      return Text("An error occurred!");
                    } else {
                      return Text("No results found!");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}