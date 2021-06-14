import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
CollectionReference userMessages =
    FirebaseFirestore.instance.collection("massages");
final _auth = FirebaseAuth.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;
  final messageTextController = TextEditingController();

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  // Future<void> getMessages() async {
  //   final messages = await users.get();
  //   await print(messages.docs.asMap());
  // }
  // void messageStream() async {
  //   await for (var snapshot in userMessages.snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
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
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _fireStore.collection('massages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                      messageTextController.clear();
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

class MessageBubble extends StatelessWidget {
  final String text;
  final String userName;
  final bool isMe;
  MessageBubble({this.text, this.userName, this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text('$userName',
                style: TextStyle(
                  fontSize: 10.0,
                )),
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '$text',
                  style: TextStyle(
                      fontSize: 15.0,
                      color: isMe ? Colors.white70 : Colors.black),
                ),
              ),
              elevation: 10.0,
              color: isMe ? Colors.blueAccent : Colors.white54,
              shape: RoundedRectangleBorder(
                borderRadius: isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(
                          10.0,
                        ),
                        bottomRight: Radius.circular(
                          10.0,
                        ),
                        bottomLeft: Radius.circular(
                          10.0,
                        ),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(
                          10.0,
                        ),
                        bottomRight: Radius.circular(
                          10.0,
                        ),
                        bottomLeft: Radius.circular(
                          10.0,
                        ),
                      ),
              ),
            ),
          ]),
    );
  }
}

class MessageStream extends StatelessWidget {
  bool isItMe;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: userMessages.snapshots(), //adding the stream source
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          final textMessages = snapshot.data.docs;
          List<MessageBubble> messageBubbles = [];

          for (var message in textMessages) {
            final messageText = message.get('text');
            final messageSender = message.get('sender');
            final currentUser = loggedInUser.email;
            messageSender == currentUser ? isItMe = true : isItMe = false;
            final messageBubble = MessageBubble(
              text: messageText,
              userName: messageSender,
              isMe: isItMe,
            );
            messageBubbles.add(messageBubble);
            // messageBubbles.remove(0);
          }
          return Expanded(
            child: ListView(
              //reverse: true,
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }
}
