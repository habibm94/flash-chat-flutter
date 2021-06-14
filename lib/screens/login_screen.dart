import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'loginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool progressSpin = false;
  String email;
  String password;
  String errorText;
  bool obscuredText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: progressSpin,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'flash_logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  decoration: kInputTextFieldDecoration.copyWith(
                      hintText: 'Enter your email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  obscureText: obscuredText,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: kInputTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Password',
                    errorText: errorText,
                    suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            obscuredText
                                ? obscuredText = false
                                : obscuredText = true;
                          });
                        },
                        icon: Icon(Icons.remove_red_eye_outlined)),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                RoundedButton(
                    title: 'Log In',
                    buttonColor: Colors.blueAccent,
                    onPressed: () async {
                      setState(() {
                        progressSpin = true;
                      });
                      try {
                        final registeredUSer =
                            await _auth.signInWithEmailAndPassword(
                                email: email, password: password);

                        if (registeredUSer != null) {
                          Navigator.pushNamed(context, ChatScreen.id);
                          print(registeredUSer.credential);
                          setState(() {
                            progressSpin = false;
                          });
                        }
                        //

                      } catch (e) {
                        print(e);
                        setState(() {
                          errorText = 'Invalid email or Password';
                          progressSpin = false;
                        });
                      }
                      ;
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
