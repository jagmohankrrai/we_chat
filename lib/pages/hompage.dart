import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat/pages/searchpage.dart';
import '../model/FirebaseHelper.dart';
import '../model/chastmodel.dart';
import '../model/users.dart';
import 'chatroom.dart';
import 'login.dart';
class Hompage extends StatefulWidget {
  final users user;
  final User firebaseUser;

  const Hompage({super.key, required this.user, required this.firebaseUser});


  @override
  _Hompage createState() => _Hompage();
}

class _Hompage extends State<Hompage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Chat App"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) {
                      return Login();
                    }
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.user.uid}", isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.active) {
                print(1);
                if(snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                  print(chatRoomSnapshot.docs.length);
                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      print(chatRoomSnapshot.docs.length);
                      chastmodel chatRoomModel = chastmodel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String, dynamic>);(3);
                      Map<String, dynamic> participants = chatRoomModel.prticipents!;

                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.user.uid);

                      print(3);
                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelById(participantKeys[0]),
                        builder: (context, userData) {
                          if(userData.connectionState == ConnectionState.done) {
                            if(userData.data != null) {
                              users targetUser = userData.data as users;

                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                        chatroom: chatRoomModel,
                                        firebaseUser: widget.firebaseUser,
                                        userModel: widget.user,
                                        targetUser: targetUser,
                                      );
                                    }),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(targetUser.dp.toString()),
                                ),
                                title: Text(targetUser.full_name.toString()),
                                subtitle: (chatRoomModel.lastmsg.toString() != "") ? Text(chatRoomModel.lastmsg.toString()) : Text("Say hi to your new friend!", style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),),
                              );
                            }
                            else {
                              return Container();
                            }
                          }
                          else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                }
                else if(snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              }
              else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(userModel: widget.user, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}