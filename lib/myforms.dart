import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
  void register(final controller1, final controller2) async {
    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: controller1, password: controller2);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {

        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        setState((){
          errorMsg = "this is an error";
        });

        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
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
            onPressed: () {
              register(_emailcontroller.text, _passwordcontroller.text);
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
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: controller1, password: controller2);
      Navigator.push(context, MaterialPageRoute(builder:(context) => userHome()));

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

  }

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
              FirebaseAuth.instance
                  .authStateChanges()
                  .listen((User user) {
                if (user == null) {
                  print('User is  signed out!');
                } else {
                  print('User is signed in!');
                  Navigator.push(context, MaterialPageRoute(builder:(context) => userHome()));
                }
              });
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
