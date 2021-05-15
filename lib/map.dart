import 'dart:async';
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
  User currentUser = FirebaseAuth.instance.currentUser;
  Location location = Location();
  //Future<Position> currentPos = geolocator.getCurrentPos

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void getUser() {
    if(currentUser == null){
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    else{
      CollectionReference coll = firestore.collection('users').doc(currentUser.email).collection('photos');
      Future<DocumentSnapshot> snap = coll.get().then((querySnapshot){
        querySnapshot.docs.forEach((value){
          print(value.data());
          return value.data();
        });
        return;
      });
    }
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(

      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  Future<Position> _determinePosition() async{
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
  // void _onMapCreated(GoogleMapController _cntlr) async
  // {
  //   print("hello");
  //   _controller = _cntlr;
  //   location.onLocationChanged.listen((l) {
  //     _controller.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 100),
  //       ),
  //     );
  //   });
  //   // await _determinePosition().then((value) => setState(() {
  //   //   pos = value;
  //   // }));
  // }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:
      // FutureBuilder(
      //   future: _determinePosition(),
      //   builder:(context, AsyncSnapshot<Position> snapshot){
      //     if(snapshot.connectionState == ConnectionState.done){
        GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller){
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,

                ),


    //       if(snapshot.hasError){
    //         return Text("Error");
    //       }
    //       return CircularProgressIndicator();
    // }
      // )GoogleMap(
      //   mapType: MapType.normal,
      //   initialCameraPosition: await _determinePosition,
      //   onMapCreated: _onMapCreated
     floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,

        //floatingActionButtonLocation:

        child: Icon(Icons.notifications_on_outlined),
      ),
    );
  }

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
 }