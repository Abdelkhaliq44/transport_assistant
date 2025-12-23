import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:transport_assistant/Data/register.dart';
import 'package:transport_assistant/Data/saved_pints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';

import '../Data/favorite_points.dart';
import 'acount/drwer_acount.dart';
double lastLat = 36.0333;
double lastLng = 6.5833;
int Selection = 1;
class HomePage extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  const HomePage({super.key, this.onLocaleChanged}) ;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  LatLng? _selectedPoint;
  String? _selectedAddress;
  bool _showBottomInfo = false;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final double _zoomLevel = 14;

  @override
  void initState() {
    super.initState();
    _checkPermission();
    loadUserImage();
  }
  String? imgpathe;
  loadUserImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Reference ref = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
      String url = await ref.getDownloadURL();  // الرابط مباشرة من Storage
      setState(() {
        imgpathe = url;
      });
    } catch (e) {
      print("Error loading user image: $e");
    }
  }
  void _toggleFavpoint (double lag,double lat, String plase) async {
    List<String> fave =['$plase','$lat','$lag'];
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('Favpoint')
        .doc(uid);
    final data = await docRef.get();
    Map<String, dynamic> favData = data.data() ?? {};
    final newKey = "point${favData.length + 1}";
    favData[newKey] = fave;
    await docRef.set(favData);
    setState(() {
      pointFav = favData.values
          .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
          .toList();
    });
  }
  void _toggleSavepoint (double lag,double lat, String plase) async
  {
    List<String> fave =['$plase','$lat','$lag'];
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('Savepoint')
        .doc(uid);
    final data = await docRef.get();
    Map<String, dynamic> favData = data.data() ?? {};
    final newKey = "point${favData.length + 1}";
    favData[newKey] = fave;
    await docRef.set(favData);
    setState(() {
      pointSaved = favData.values
          .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
          .toList();
    });


  }
  void _toggleregistorpoint (double lag,double lat, String plase) async
  {
    List<String> fave =['$plase','$lat','$lag'];
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('gistorpoint')
        .doc(uid);
    final data = await docRef.get();
    Map<String, dynamic> favData = data.data() ?? {};
    final newKey = "point${favData.length + 1}";
    favData[newKey] = fave;
    await docRef.set(favData);
    setState(() {
      pointregistor = favData.values
          .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
          .toList();
    });


  }

  void _handleMapTap(LatLng tappedPoint)async{
    setState(() {
      _markers.clear();
      _markers.add(
          Marker(
            markerId:  const MarkerId('selected_point'),
            position: tappedPoint,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          )
      );
    });
    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
        tappedPoint.latitude,
        tappedPoint.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";


        setState(() {
          _selectedPoint = tappedPoint;
          _selectedAddress = address;
          _showBottomInfo = true;
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('selected_point'),
              position: tappedPoint,
              infoWindow: InfoWindow(title: place.name ?? "Unknown", snippet: address),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء جلب المعلومات من Google")),
      );
    }
  }
  void  moveCameraTo (double lat, double lng, String name)async{
    final LatLng target = LatLng(lat, lng);
    if (!_controller.isCompleted) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 300));
        return !_controller.isCompleted;
      });
    }
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 17, tilt: 45, bearing: 30),
      ),
    );
    setState(() {
      _markers.clear();
      _markers.add(
          Marker(
              markerId: MarkerId(name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              position: target,
              infoWindow: InfoWindow(title: name,)
          )
      );
    });
  }
  void _zoomIn()async {
    final zoom = await _mapController?.getZoomLevel() ?? _zoomLevel;
    final newZoom = zoom + 1;
    _mapController?.animateCamera(CameraUpdate.zoomTo(newZoom));
  }

  void _zoomOut()async {
    final zoom = await _mapController?.getZoomLevel() ?? _zoomLevel;
    final newZoom = zoom - 1;
    _mapController?.animateCamera(CameraUpdate.zoomTo(newZoom));

  }

  void _goToMyLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 🔹 تحقق من أن GPS مفعّل
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("location_service_disabled".tr())),
      );
      return;
    }

    // 🔹 تحقق من الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("location_permission_denied".tr())),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("location_permission_denied_forever".tr())),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final LatLng myPosition = LatLng(position.latitude, position.longitude);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: myPosition, zoom: 17),
      ),
    );
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  CameraPosition _currentCameraPosition = CameraPosition(
    target: LatLng(lastLat, lastLng),
    zoom: 12,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xfff4b7bff),
        centerTitle: true,
        title: Text('transport_assistant'.tr(),style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = !_showSearch; // إظهار أو إخفاء البحث
                });
              },
            ),
          ),
          DropdownButton(
            value: context.locale.languageCode,
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    Text('🇬🇧 ', style: TextStyle(fontSize: 20)),
                    Text('English'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Row(
                  children: [
                    Text('🇸🇦 ', style: TextStyle(fontSize: 20)),
                    Text('العربية'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'fr',
                child: Row(
                  children: [
                    Text('🇫🇷 ', style: TextStyle(fontSize: 20)),
                    Text('Français'),
                  ],
                ),
              ),
            ],
            underline: const SizedBox(),
            onChanged: (newValue) {
              if (newValue != null) {
                context.setLocale(Locale(newValue)); // ⬅️ هنا التغيير
              }
            },
          ),
        ],
        leading: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  Scaffold.of(context).openDrawer();
                },
                child: CircleAvatar(
                  backgroundImage: imgpathe != null
                      ? CachedNetworkImageProvider(imgpathe!)
                      : AssetImage('assets/images/acont_defalt.jpg') as ImageProvider,
                ),
              ),
            );
          }
        ),
      ),
      drawer: Drawer(
        child: DrwerAcount(
          onGoToHome: (){},
        ),
      ),
      body:  Stack(
          children: [
            GoogleMap(
               onTap: _handleMapTap,
              onMapCreated: (controller){

                _mapController = controller;
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(lastLat, lastLng),
                zoom: 12,
              ),

              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,
              onCameraMove: (position) {
                _currentCameraPosition = position;
                lastLat = position.target.latitude;
                lastLng = position.target.longitude;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.hybrid,
              markers: _markers,
            ),
            if(_showBottomInfo && _selectedAddress !=null)
    DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context,scrollController){
        return Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(right: 100.0,top: 40),
            child: ListView(
              controller:scrollController,
              children: [
                Text('📍 $_selectedAddress'),
                Row(
                  children: [

                    IconButton(
                        onPressed: (){
                          if(_selectedPoint != null && _selectedAddress != null){
                            _toggleFavpoint(_selectedPoint!.longitude,_selectedPoint!.latitude, _selectedAddress!);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:Text("تمت الإضافة إلى المفضلة!",),
                            ));

                          }
                        },
                        icon: Icon(Icons.favorite_outline_sharp,size: 20,color: Colors.redAccent,)
                    ),
                    SizedBox(width: 8,),
                    IconButton(
                        onPressed: (){
                          if(_selectedPoint != null && _selectedAddress != null){
                            _toggleSavepoint(_selectedPoint!.longitude,_selectedPoint!.latitude, _selectedAddress!);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:Text("تمت الإضافة إلى المحفوضة!",),
                            ));

                          }
                        },
                        icon: Icon(Icons.save_rounded,size: 20,color: Colors.greenAccent,)
                    ),
                    IconButton(
                        onPressed: (){
                          setState(() {
                            _showBottomInfo = false;
                          });

                        },
                        icon: Icon(Icons.clear,size: 20,color: Colors.red,)
                    ),
                  ],
                ),
            ]
            ),
          ),
        );

      },
    ),
            Positioned(
              bottom: 100,
              right: 10,
              child: FloatingActionButton(
                heroTag: "loc",
                backgroundColor: Colors.blue,
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location, color: Colors.black,size: 35,),
              ),
            ),
            Positioned(
              bottom: 300,
              right: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "zoom_in",
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: "zoom_out",
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove, color: Colors.black),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 25,
              left: 30,
              right: 30,
              child: SegmentedButton(
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                        (states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF4fa1eb);
                      }
                      return const Color(0xFF0a3990);
                    },
                  ),
                  foregroundColor: WidgetStateProperty.all<Color>(Color(0xFFa0d8f4)),
                  overlayColor: WidgetStateProperty.all<Color>(
                    const Color(0xFF00103c).withOpacity(0.2),
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.white24),
                  ),
                ),
                segments: [
                  ButtonSegment(
                    value: 1,
                    label: Text('taxi'.tr()),
                    icon: Icon(Icons.local_taxi, color: Colors.white, size: 28),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('train'.tr()),
                    icon: Icon(Icons.train, color: Colors.white, size: 28),
                  ),
                  ButtonSegment(
                    value: 3,
                    label: Text('bus'.tr()),
                    icon: Icon(Icons.directions_bus, color: Colors.white, size: 28),
                  ),
                ],
                selected: <int>{Selection},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    Selection = newSelection.first;
                  });
                  //هنا نزيدو ونبعد الختيار تاعها   بيس ول تاكسي زل واشيدير
                },
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showSearch ? kToolbarHeight : -2, // أسفل الـ AppBar مباشرة
              left: 15,
              right: 15,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showSearch ? 1 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                      onSubmitted:  (value) async {
                        if (value.isEmpty) return;

                        try {
                          // البحث عن الموقع بالاسم
                          List<Location> locations = await locationFromAddress(value);
                          if (locations.isNotEmpty) {
                            final loc = locations.first;
                            _toggleregistorpoint(loc.longitude, loc.latitude, value);

                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(loc.latitude, loc.longitude),
                                  zoom: 14,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("location_not_found".tr())),
                          );
                        }
                      },
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "search_hint".tr(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _showSearch = false;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],

                      )
                  ),
                ),
              ),
            ),

          ]

      ),
    );
  }
}
