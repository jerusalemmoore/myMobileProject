import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'myforms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'main.dart';
import 'signup.dart';
import 'package:image_picker/image_picker.dart';

class userHome extends StatefulWidget {
  userHome({Key key}) : super(key: key);
  @override
  userHomeState createState() => userHomeState();
}

class userHomeState extends State<userHome> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String userEmail;
  String username;
  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  bool isSignedIn() {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        //print('User is currently signed out!');
        return false;
      }
    });
    return true;
  }

  Future<void> userName() async {
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      setState(() {
        userEmail = user.email;
        username = userEmail.split('@')[0];
      });
    });
  }

  Future<void> uploadImage() async {
    CollectionReference users;
  }
  @override
  void initState() {
   setState((){
     userName();
   });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // if(!isSignedIn()){
    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //
    //     // This is the theme of your application.
    //     //
    //     // Try running your application with "flutter run". You'll see the
    //     // application has a blue toolbar. Then, without quitting the app, try
    //     // changing the primarySwatch below to Colors.green and then invoke
    //     // "hot reload" (press "r" in the console where you ran "flutter run",
    //     // or simply save your changes to "hot reload" in a Flutter IDE).
    //     // Notice that the counter didn't reset back to zero; the application
    //     // is not restarted.
    //     primarySwatch: Colors.blue,
    //   ),
    //
    //   home: MyHomePage(),
    //   builder: EasyLoading.init(),
    //   routes: <String, WidgetBuilder>{
    //     '/signup': (BuildContext context) => SignupPage(),
    //     '/login' : (BuildContext context) => MyHomePage(),
    //     // '/userHome' : (BuildContext context) => UserHomePage(),
    //
    //   },
    // );

    //}

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('My HomePage'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text("$userEmail"),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                signOut();
                Navigator.pushReplacementNamed(context, "/");

                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('Other feature'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: CircleAvatar(
                  backgroundColor: Colors.brown.shade800,
                  radius: 50,
                  child: Text('AH'),
                ),
                  ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                        //style:DefaultTextStyle.of(context).style ,
                        children: [
                          TextSpan(
                            text: '$username' + '\'s ' + 'UserPage',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ]),
                  ),
                ),

              Expanded(
                  // flex:1,
                  child: Container(padding: EdgeInsets.all(15)))
            ]),
            Container(
              child:
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              inputFormatters:[
                LengthLimitingTextInputFormatter(150),
              ]
             // "Create account to begin exploring and creating",
            ),
            ),
            _image == null ? Text('No image selected') : Image.file(_image),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
