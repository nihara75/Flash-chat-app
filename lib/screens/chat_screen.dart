import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final con = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String messagetext;
  User u;
  bool isme = false;

  void getuser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        print(user);
        u = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.lightBlueAccent));
                  }
                  final messages = snapshot.data.docs;
                  List<Padding> messageWid = [];
                  for (var message in messages) {
                    final mess = message.data();
                    final messageText = mess['text'];
                    final messagesender = mess['field'];

                    if (u.email == messagesender) {
                      isme = true;
                    }
                    final messagewidget = Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: isme
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$messagesender',
                            style: TextStyle(
                                color: Colors.black38, fontSize: 12.0),
                          ),
                          Material(
                            elevation: 8.0,
                            borderRadius: isme
                                ? BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0))
                                : BorderRadius.only(
                                    topRight: Radius.circular(30.0),
                                    bottomRight: Radius.circular(30.0),
                                    bottomLeft: Radius.circular(30.0)),
                            color: isme ? Colors.lightBlueAccent : Colors.white,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              child: Text('$messageText',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: isme ? Colors.white : Colors.black87,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    );
                    messageWid.add(messagewidget);
                  }

                  return Expanded(
                      child: ListView(
                    children: messageWid,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  ));
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: con,
                      onChanged: (value) {
                        //Do something with the user input.
                        messagetext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      con.clear();
                      _firestore
                          .collection('messages')
                          .add({'text': messagetext, 'field': u.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
