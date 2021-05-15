import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'myforms.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // as firebase_storage;
import 'package:flutter/services.dart';
import 'main.dart';
import 'signup.dart';
import 'map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class userHome extends StatefulWidget {
  userHome({Key key}) : super(key: key);
  @override
  userHomeState createState() => userHomeState();
}

class userHomeState extends State<userHome> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  String userEmail;
  String username;
  int _selectedIndex = 0;
  final picker = ImagePicker();
  final aboutController = TextEditingController();
  String aboutText;
  File _image;
  int num = 0;
  ListResult photoList;
  ValueKey<String> keys;
  Position pos;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    CollectionReference userPhotos = FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('photos');

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await uploadImageToFirebase();
      photoList =
          await FirebaseStorage.instance.ref().child(userEmail).listAll();

      String fileName = basename(_image.path);
      print('$userEmail');
      print('$fileName');
      String path;

      print('$path');
      String downloadURL =
          await storage.ref().child(userEmail).child(fileName).getDownloadURL();
      await _determinePosition().then((value) => setState(() {
            pos = value;
          }));

      userPhotos.add({
        'url': downloadURL,
        'date': Timestamp.now(),
        'description': "photo description",
        'location': '$pos'
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadImageToFirebase() async {
    String filename = basename(_image.path);
    Reference ref = storage.ref().child(userEmail).child(filename);
    UploadTask uploadTask = ref.putFile(_image);
    uploadTask.then((res) {
      res.ref.getDownloadURL();
    });
    try {
      await uploadTask;
      print('Upload complete.');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }

      //await listExample();

    }
  }

  Future<void> listExample() async {
    photoList = await FirebaseStorage.instance.ref().child(userEmail).listAll();

    photoList.items.forEach((Reference ref) {
      Image.network('$ref');
    });

    photoList.prefixes.forEach((ref) {
      print('Found directory: $ref');
    });
  }

  void signOut(context) {
    FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    });
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
  Future<bool> isSignedIn() async {
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
      if (user == null) {
        //Navigator.popUntil(context,ModalRoute.withName('/') );
      }
      setState(() {
        userEmail = user.email;
        username = userEmail.split('@')[0];
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(userEmail)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        Map<String, dynamic> data = documentSnapshot.data();
        aboutController.text = data['about'];
      });
    });
  }

  Future<void> updateFirebase(aboutValController) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users
        .doc(userEmail)
        .update({'about': aboutValController.text})
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  @override
  void initState() {
    userName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // userName();
    //userName(context);
    // FirebaseAuth.instance.authStateChanges().listen((User user){
    //   if(user == null){
    //     Navigator.popUntil(context, ModalRoute.withName('/') );
    //   }
    //   });
    CollectionReference users = FirebaseFirestore.instance.collection('users');

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
                signOut(context);
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
            Flexible(
              flex: 1,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            ),
            Flexible(
                flex: 10,
                child: Column(children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: FutureBuilder<DocumentSnapshot>(
                        future: users.doc(userEmail).get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Text("Error");
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic> data = snapshot.data.data();

                            return Focus(
                                child: TextField(
                                  onTap: () {
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);
                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }
                                  },

                                  //autofocus: true,
                                  controller: aboutController,
                                  maxLength: 150,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 3,
                                  expands: false,
                                  decoration: InputDecoration(
                                    //border: InputBorder.none,
                                    counter: Offstage(),
                                  ),
                                ),
                                onFocusChange: (hasFocus) {
                                  if (!hasFocus) {
                                    updateFirebase(aboutController);
                                  }
                                });
                            return Text("${data['about']}");
                          } else {
                            print(snapshot);
                            return Text("loading");
                          }
                        }),
                  ),
                  Flexible(
                      flex: 10,
                      child: StreamBuilder<QuerySnapshot>(
                          stream: users
                              .doc(userEmail)
                              .collection('photos')
                              .orderBy('date', descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('error');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("loading");
                            }
                            return ListView(
                                children: snapshot.data.docs
                                    .map((DocumentSnapshot document) {
                              return Dismissible(
                                  onDismissed: (direction) {
                                    users
                                        .doc(userEmail)
                                        .collection('photos')
                                        .doc(document.id)
                                        .delete();
                                  },
                                  key: ValueKey<String>(document.id),
                                  child: Card(
                                      shape: Border.all(width: 5),
                                      elevation: 20,
                                      child: Column(children: <Widget>[
                                        Container(
                                            child: Image.network(
                                                document.data()['url'])),
                                      ])));
                            }).toList());
                          }))
                  //_image == null ? Text('No posts') : Image.file(_image),
                  //_image == null ? Text('no posts') :
                  //Text('$photoList'),
                ]))
          ],
        ),
      ),

      floatingActionButton: SpeedDial(
        marginBottom: 20,
        // animatedIcon: AnimatedIcons.menu_close,
        // animatedIconTheme: IconThemeData(size: 22.0),
        /// This is ignored if animatedIcon is non null

        // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),
        /// The label of the main button.
        // label: Text("Open Speed Dial"),
        /// The active label of the main button, Defaults to label if not specified.
        // activeLabel: Text("Close Speed Dial"),
        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
        /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements

        visible: true,
        /// If true user is forced to close dial manually
        /// by tapping main button and overlay is not rendered.
        closeManually: false,
        /// If true overlay will render no matter what.

        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 8.0,
        child: Icon(Icons.add),
        shape: CircleBorder(),
        // orientation: SpeedDialOrientation.Up,
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(Icons.image),
            backgroundColor: Colors.blue,
            label: 'Upload Image',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: getImage,

          ),
          SpeedDialChild(
            child: Icon(Icons.map),
            backgroundColor: Colors.blue,
            label: 'Map',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>MapSample()),
    )),



        ],
      ),
    );

      // This trailing comma makes auto-formatting nicer for build methods.

  }
}
