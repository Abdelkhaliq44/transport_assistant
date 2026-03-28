import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:transport_assistant/Data/register.dart';
import 'package:transport_assistant/Data/saved_pints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../Data/favorite_points.dart';
import 'acount/drwer_acount.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
List<LatLng> getPolylinePoints(Map<String, dynamic> json) {
  List points = json['data']['segment_points'];

  return points.map((point) {
    return LatLng(point['lat'], point['lng']);
  }).toList();
}
class RouteRequest {
  double? lat1;
  double? long1;
  double? lat2;
  double? long2;
  String? document;

  Map<String, dynamic> toJson() {
    return {
      "lat1": lat1,
      "long1": long1,
      "lat2": lat2,
      "long2": long2,
      "document": document,
    };
  }
}

double lastLat = 36.021284;
double lastLng = 6.567206;

class HomePage extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  const HomePage({super.key, this.onLocaleChanged}) ;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  LatLng? startPointSelected;
  LatLng? endPointSelected;
  bool start =false;
  bool And =false;
  RouteRequest routeRequest = RouteRequest();
  int Selection = 3;
  LatLng? _selectedPoint;
  LatLng? Point;
  String? _selectedAddress;
  bool _showBottomInfo = false;
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final LatLng startPoint = LatLng(36.021369, 6.566466);
  final LatLng endPoint = LatLng(36.034488, 6.572595);
  List<LatLng> routePoints = [];
   List<Marker> _taxiMarkers = [];
   List<Marker> _busMarkers = [];
  Future sendData(RouteRequest routeRequest) async {
    final response = await http.post(
      Uri.parse("http://10.222.16.227:5000/route"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(routeRequest.toJson()),
    );
    final data = jsonDecode(response.body);
    List<LatLng> polylinePoints = getPolylinePoints(data);

    setState(() {
          routePoints = polylinePoints;
         });

    return polylinePoints;
  }
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
  Future<List<LatLng>> loadRouteFromFirebase(String routeName,String route) async {
    final doc = await FirebaseFirestore.instance
        .collection(route)
    //'routes'
        .doc(routeName)
        .get();

    if (!doc.exists) return [];

    final List data = doc['points'];

    return data
        .map((e) => LatLng(e['lat'], e['lng']))
        .toList();
  }
  Future<void> changeSelection( int newSelection) async {
    setState(() {
      Selection = newSelection;
      routePoints.clear();
      loopRoutePoints.clear();
    });

    switch (Selection) {
      case 1:
        await loadTaxiRoute();
        buildTaxiMarkers();
        if (_taxiMarker.isNotEmpty) {
          _mapController.move(_taxiMarker.first, 18);
        }
        routeRequest.document = "taxi";

        break;

      case 3:
        await loadBusRoute();
        buildBusMarkers();
        if (_busMarker.isNotEmpty) {
          _mapController.move(_busMarker.first, 18);
        }
        routeRequest.document = "bus";
        break;
    }
  }

  Future<void> loadTaxiRoute() async {
    final points = await loadRouteFromFirebase('taxi','routes');
    final markers = await loadRouteFromFirebase('taxi','markers');
    setState(() {
      routePoints = points;
      _taxiMarker= markers;
    });
  }
  Future<void> loadBusRoute() async {
    final points = await loadRouteFromFirebase('bus','routes');
    final marker = await loadRouteFromFirebase('bus','markers');

    setState(() {
      loopRoutePoints = points;
      _busMarker= marker;
    });

  }

  List<LatLng> loopRoutePoints = [];
  List<LatLng> _taxiMarker = [];
  List<LatLng> _busMarker = [];

  // Future<void> saveRouteToFirebase(
  //     String type,
  //     List<LatLng> points,
  //     ) async {
  //   final data = points
  //       .map((p) => {
  //     'lat': p.latitude,
  //     'lng': p.longitude,
  //   })
  //       .toList();
  //
  //   await FirebaseFirestore.instance
  //       .collection('markers')
  //       .doc(type)
  //       .set({'points': data});
  // }

  Future<void> buildTaxiMarkers() async {
    _taxiMarkers.clear();



    for (int i = 0; i < _taxiMarker.length; i++) {
      _taxiMarkers.add(
        Marker(
          point: _taxiMarker[i],
          width: 40,
          height: 40,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.local_taxi,
              color: Colors.greenAccent,
              size: 30,
            ),
          ),
        ),
      );
    }
    // await saveRouteToFirebase('taxi', taxiStops);
  }
  Future<void> buildBusMarkers() async {
    setState(() {
      _busMarkers.clear();
      for (int i = 0; i < _busMarker.length; i++) {
        _busMarkers.add(
          Marker(
            point: _busMarker[i],
            width: 40,
            height: 40,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(
                Icons.directions_bus,
                color: Colors.greenAccent,
                size: 30,
              ),
            ),
          ),
        );
      }
    });
  }

  // await saveRouteToFirebase('bus', busStops);
  // void fetchLoopRoute() async {
  // هاذي ليستا لموها يدويا  تع النقاط المتوقة لل   خط نقل
  //   final loopWaypoints = [
  //     LatLng(36.021657, 6.563483),
  //     LatLng(36.021427, 6.566844),
  //     LatLng(36.021902, 6.567370),
  //     LatLng(36.02312, 6.57233),
  //     LatLng(36.040394, 6.574727),
  //     LatLng(36.043942, 6.567464),
  //     LatLng(36.042003, 6.567560),
  //     LatLng(36.041860, 6.563918),
  //     LatLng(36.040229, 6.563816),
  //     LatLng(36.039713, 6.565136),
  //     LatLng(36.039179, 6.565999),
  //     LatLng(36.038351, 6.566638),
  //     LatLng(36.037596, 6.567078),
  //     LatLng(36.035904, 6.568000),
  //     LatLng(36.034655, 6.570457),
  //     LatLng(36.034488, 6.572595),
  //     LatLng(36.033969, 6.573247),
  //     LatLng(36.021076, 6.567990),
  //     LatLng(36.021369, 6.566466),
  //     LatLng(36.021792, 6.562475),
  //     LatLng(36.021657, 6.563483),
  //   ];
  //
  //   // تحويل النقاط إلى نص الـ OSRM
  //   final coords = loopWaypoints.map((p) => "${p.longitude},${p.latitude}").join(";");
  //
  //   final url = "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";
  //
  //   final res = await http.get(Uri.parse(url));
  //   final data = json.decode(res.body);
  //   final routeCoords = data['routes'][0]['geometry']['coordinates'];
  //
  //   setState(() {
  //     loopRoutePoints = routeCoords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  //   });
  //   await saveRouteToFirebase('bus', loopRoutePoints);
  // }
  //
  // void fetchRouteWithWaypoints() async {
  //   // نقاط الطريق (Waypoints)
  //   final waypoints = [
  //     LatLng(36.021369, 6.566466), // البداية
  //     LatLng(36.021076, 6.567990), // نقطة وسطى
  //     LatLng(36.034488, 6.572595), // النهاية
  //   ];
  //
  //   // إنشاء سلسلة الإحداثيات بالشكل المطلوب من OSRM (lon,lat;lon,lat;...)
  //   final coords = waypoints.map((p) => "${p.longitude},${p.latitude}").join(";");
  //
  //   final url = "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";
  //
  //   final res = await http.get(Uri.parse(url));
  //   final data = json.decode(res.body);
  //   final routeCoords = data['routes'][0]['geometry']['coordinates'];
  //
  //   setState(() {
  //     routePoints = routeCoords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  //   });
  //   await saveRouteToFirebase('taxi', routePoints);
  //
  // }

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

  void _handleMapTapOSM(LatLng point) async {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address =
            "${place.name ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";

        setState(() {
          _selectedPoint = point;
          _selectedAddress = address;
          _showBottomInfo = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء جلب العنوان")),
      );
    }
  }
  void moveCameraTo(double lat, double lng, String name) {
    final target = LatLng(lat, lng);
    _mapController.move(target, 18);

    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            point: target,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });
    });
  }


  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut()async {

    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom -1,
    );
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
    _mapController.move(
      myPosition,
      17,
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
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(lastLat, lastLng),
                initialZoom: 18,

                onTap: (tapPosition, point) {
                  _handleMapTapOSM(point);
                  setState(() {
                    if (start) {
                      startPointSelected = point;
                      routeRequest.lat1 = point.latitude;
                      routeRequest.long1 = point.longitude;
                    } else if (And) {
                      endPointSelected = point;
                      routeRequest.lat2 = point.latitude;
                      routeRequest.long2 = point.longitude;
                    }
                  });
                },

                onPositionChanged: (position, hasGesture) {
                  if (position.center != null) {
                    lastLat = position.center!.latitude;
                    lastLng = position.center!.longitude;
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.transport_assistant',
                ),

                MarkerLayer(markers: _markers),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (loopRoutePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: loopRoutePoints,
                        color: Colors.red, // اختر لون مختلف عن المسار الأول
                        strokeWidth: 4,
                      ),
                    ],
                  ),

                if (Selection == 1)
                  MarkerLayer(markers: _taxiMarkers),

                if (Selection == 3)
                  MarkerLayer(markers: _busMarkers),
              ],
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
                            Row(
                              children: [
                                Text('Start point'),
                                SizedBox(width: 8,),
                                Checkbox(
                                  value: start,
                                  onChanged: (value) {
                                    setState(() {
                                      start = value!;
                                      if(start) And =false;
                                    });
                                  },
                                ),
                                Text('end point'),
                                SizedBox(width: 8,),
                                Checkbox(
                                  value: And,
                                  onChanged: (value) {
                                    setState(() {
                                      And = value!;
                                      if(And) start =false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            ElevatedButton(
                                onPressed: () async{
                                  await sendData(routeRequest);
                                },
                                child: Text('get line')
                            ),

                          ]
                      ),
                    ),
                  );

                },
              ),
            // Positioned(
            //   left: 10,
            //     bottom: 300,
            //     child:
            // ),
            // Positioned(
            //   left: 10,
            //     bottom: 250,
            //     child:
            //
            // ),
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
                onSelectionChanged: (newSelection) async {
                  await changeSelection(newSelection.first);
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
                          List<Location> locations = await locationFromAddress(value);
                          if (locations.isNotEmpty) {
                            final loc = locations.first;
                            _toggleregistorpoint(loc.longitude, loc.latitude, value);

                            _mapController.move(
                              LatLng(loc.latitude, loc.longitude),
                              14,
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


