import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'userHome.dart';

/*
  This form is used for creating users

  asks for user email and password to
  register
 */
class SignUpForm extends StatefulWidget {
  @override
  SignUpFormState createState() {
    return SignUpFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignUpFormState extends State<SignUpForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool _initialized = false;
  bool _error = false;
  String errorMsg = "errorMsg";
  bool successfulReg = false;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    setState(() {});
  }
  String getError(String errorMsg){
    return errorMsg;
  }
  Future<void> register(final controller1, final controller2) async {
    // CollectionReference users = FirebaseFirestore.instance.collection('users');
    // CollectionReference photos = FirebaseFirestore.instance.collection('photos');
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('/notes.txt');
      ref.child('images');
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: controller1, password: controller2);
      // DocumentReference specificUser = FirebaseFirestore.instance.collection('users').doc(controller1);

      // specificUser.get().then((doc)  {//check if user already has existing registration info
      //   if(!doc.exists){
      //     users.doc(controller1).set({
      //       'account' : controller1,
      //       'photos' : controller2
      //     });
      //
      //     // setState((){
      //     //   //successfulReg = true;
      //     // }),
      //   }
      //set user information
      setState((){
        successfulReg = true;
      });
      await FirebaseFirestore.instance.collection('users').doc(controller1).set({
        'username': controller1,
        'about' : "Default about"
      });
      //create folder to hold images
      // await FirebaseFirestore.instance.collection('users').doc(controller1).collection('photos').doc("photo template").set({
      //   'description': 'default description',
      //   'location' : 'currently unnasigned location',
      //   'content' : 'imageFile'
      // });



      //   else{
      //     print("error, email user exists");//if registration info already exists
      //   }
      // });
    } catch(e){
      print("Error, email already in use");
    }
    //on FirebaseAuthException catch (e) {
    //   if (e.code == 'weak-password') {
    //
    //     print('The password provided is too weak.');
    //   } else if (e.code == 'email-already-in-use') {
    //
    //     print('The account already exists for that email.');
    //   }
    // }  catch (e) {
    //   print(e);
    //
    // }

  }

  /*
    This form is used to log an already created user into their account
   */
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[

          TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Username *',
              ),
              controller: _emailcontroller),
          TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Password *',
              ),
              controller: _passwordcontroller),
          
          ElevatedButton(
            onPressed: () async {
              await register(_emailcontroller.text, _passwordcontroller.text);
              if(successfulReg){
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
              // Validate returns true if the form is valid, or false otherwise.
            },
            child: Text('Submit'),
          ),

          // Add TextFormFields and ElevatedButton here.
        ],

      ),
    );
  }
}

class SignInForm extends StatefulWidget {
  @override
  SignInFormState createState() {
    return SignInFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class SignInFormState extends State<SignInForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
    setState(() {});
  }

  void signIn(final controller1, final controller2) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: controller1,
          password: controller2
      );
      FirebaseAuth.instance
          .authStateChanges()
          .listen((User user) {
        if (user == null) {
          print('User is  signed out!');
        } else {
          print('User is signed in!');
          Navigator.pushNamed(context, '/userHome');
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user != null) {
        //print('User is currently signed out!');
        Navigator.pushNamed(context, '/userHome');
      }
    });

    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Username *',
              ),
              controller: _emailcontroller),
          TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Password *',
              ),
              controller: _passwordcontroller),

          RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10),
                  children: [
                TextSpan(text: "No account? Register "),
                TextSpan(
                    text: "here",
                    style: TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, '/signup');
                      })
              ]
                  // childrne
                  //   text:
                  //   "Sign up here",
                  //   style: TextStyle(color: Colors.blueAccent,
                  //   fontWeight: FontWeight.bold,
                  //   fontSize: 10),
                  //   recognizer: TapGestureRecognizer()
                  //     ..onTap = () {
                  //       Navigator.pushNamed(context, '/signup');
                  //     }
                  )),

          ElevatedButton(
            onPressed: () {
              signIn(_emailcontroller.text, _passwordcontroller.text);

              // Validate returns true if the form is valid, or false otherwise.
            },
            child: Text('Submit'),
          ),

          // Add TextFormFields and ElevatedButton here.
        ],
      ),
    );
  }
}
