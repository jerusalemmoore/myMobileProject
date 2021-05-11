import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'myforms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';// as firebase_storage;
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
 FirebaseStorage storage =
    FirebaseStorage.instance;
  String userEmail;
  String username;
  final picker = ImagePicker();
  final aboutController = TextEditingController();
  String aboutText;
  File _image;
  int num = 0;



  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    CollectionReference userPhotos = FirebaseFirestore.instance.collection('users').doc(userEmail).collection('photos');
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('$_image');
        String fileName = basename(_image.path);
        print('$fileName');
        userPhotos.add({
          'content' : "content",
          'description': "photo description",
          'location' : 'photo location'
        });

      } else {
        print('No image selected.');
      }
    });
    await uploadImageToFirebase();
  }
  Future <void> uploadImageToFirebase() async{
    String filename = basename(_image.path);
    Reference ref = storage.ref().child(userEmail).child(filename);
    UploadTask uploadTask = ref.putFile(_image);
    uploadTask.then((res){
      res.ref.getDownloadURL();
    });

  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    //Navigator.pop(context);
  }
  // Future<void> uploadExample() async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   String filePath = '${appDocDir.absolute}/file-to-upload.png';
  //   await uploadFile("_image");
  // }
  // Future<void> uploadFile(String filePath) async {
  //   File file = File(filePath);
  //
  //   try {
  //     await firebase_storage.FirebaseStorage.instance
  //         .ref('uploads/file-to-upload.png')
  //         .putFile(file);
  //   } on FirebaseException catch (e) {
  //     // e.g, e.code == 'canceled'
  //   }
  // }
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
      FirebaseFirestore.instance.collection('users').doc(userEmail)
            .get()
            .then((DocumentSnapshot documentSnapshot){
         Map<String, dynamic> data = documentSnapshot.data();
         aboutController.text = data['about'];
        });

      });
    });
  }
  Future<void> updateFirebase(aboutValController){
    CollectionReference users = FirebaseFirestore.instance.collection('users');


      return users
          .doc(userEmail)
          .update({'about': aboutValController.text})
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));

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
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        //print('User is currently signed out!');
        Navigator.pop(context);
      }
    });

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
                //Navigator.pushReplacementNamed(context, "/");//should be changed to pop

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
            FutureBuilder<DocumentSnapshot>(
              future: users.doc(userEmail).get(),
              builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  Map<String, dynamic> data = snapshot.data.data();

                  return Focus(
                      child: TextField(

                        onTap: (){
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if(!currentFocus.hasPrimaryFocus){
                            currentFocus.unfocus();
                          }
                        },

                        //autofocus: true,
                        controller: aboutController,
                        maxLength: 150,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        expands: false,
                        decoration: InputDecoration(
                          //border: InputBorder.none,
                          counter:Offstage(),
                        ),
                      ),
                      onFocusChange: (hasFocus){
                        if(!hasFocus){
                          updateFirebase(aboutController);
                        }
                      }
                  );
                  return Text("${data['about']}");
                }
                return Text("loading");
              }
            ),
            //I'm trying to get about doc reference of individual user so i can update the about attribute
            // StreamBuilder<DocumentSnapshot>(
            //   stream: firestore
            //       .collection('users')
            //       .doc(userEmail)
            //       .snapshots(),
            // ),
            SingleChildScrollView(
              child: Column(
                children: [

                      //_image == null ? Text('No posts') : Image.file(_image),
                    _image==null?Text('no posts') : Text('$_image'),



                ]
              )
                // TextField(
                //
                //   onTap: (){
                //     FocusScopeNode currentFocus = FocusScope.of(context);
                //     if(!currentFocus.hasPrimaryFocus){
                //       currentFocus.unfocus();
                //     }
                //   },
                //   autofocus: true,
                //   controller: aboutController,
                //   maxLength: 150,
                //   keyboardType: TextInputType.multiline,
                //   maxLines: null,
                //   onChanged:(value) {
                //     setState(() {
                //       aboutText = value;
                //       updateFirebase(value);
                //     });
                //   },
                //
                //   decoration: InputDecoration(
                //     //border: InputBorder.none,
                //     counter:Offstage(),
                // ),
                //   )
                  ),




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
