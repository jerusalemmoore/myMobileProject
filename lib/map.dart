import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  final Geolocator geolocator = Geolocator();
  //GoogleMapController _controller;
  bool isBroadcasting;
  User currentUser = FirebaseAuth.instance.currentUser;
  Location location = Location();
  Position currentPos;
  Set<Marker> _markers = HashSet<Marker>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void getUser() {
    if (currentUser == null) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      CollectionReference coll = firestore
          .collection('users')
          .doc(currentUser.email)
          .collection('photos');
      coll.get().then((querySnapshot) {
        querySnapshot.docs.forEach((value) {
          print(value.data());
          return value.data();
        });
        return;
      });
    }
  }

  Future<void> _broadcastLocation() async {
    CollectionReference markers = firestore.collection('markers');
   // var myMarker = markers.doc(currentUser.email).get();
    isBroadcasting = !isBroadcasting;
    if (isBroadcasting) {
       return markers.doc(currentUser.email).set({
        'longitude': currentPos.longitude,
        'latitude': currentPos.latitude,
        'user': currentUser.email
      });
    } else {

      return markers.doc(currentUser.email).delete();
    }
  }
  _checkIfBroadcasting() async{
    DocumentSnapshot snap = await firestore.collection('markers').doc(currentUser.email).get();
    this.setState((){
      isBroadcasting = snap.exists;
    });
  }
  @override
  void initState() {
    _determinePosition();
    _checkIfBroadcasting();
    _setMarkers();

    super.initState();
  }

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
    currentPos = await Geolocator.getCurrentPosition();
    print('have position');
    return await Geolocator.getCurrentPosition();
  }
  void _setMarkers() {
    Stream collectionStream = firestore.collection('markers').snapshots();
    firestore.collection('markers').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        //
        print(doc['user']);
        print(doc['latitude']);
        print(doc['longitude']);
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId(doc['user']),
              position: LatLng(doc['latitude'], doc['longitude'])));
        });
      });
    });
  }

  void signOut(context) {
    FirebaseAuth.instance.signOut();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Venues'),
      ),
      body: FutureBuilder(
          future: _determinePosition(),
          builder: (context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target:
                          LatLng(snapshot.data.latitude, snapshot.data.longitude),
                  zoom:100),
                  // target:LatLng(0,0)),
                  markers: _markers);
            }
            return Center(child: CircularProgressIndicator());

          }),
      floatingActionButton: FloatingActionButton(
        tooltip: "Tap this button to pin your location to the public, tap again to remove pin",
        onPressed: _broadcastLocation,
        child: Icon(Icons.notifications_on_outlined),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(height: 50.0),
        color: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
