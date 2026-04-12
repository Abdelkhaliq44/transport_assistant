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
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as Places;
import 'package:transport_assistant/lines_etusa/L36.dart';
import 'package:transport_assistant/lines_etusa/L89.dart';
import 'package:transport_assistant/lines_etusa/dergana_harach_NL608.dart';
import 'package:transport_assistant/lines_etusa/line_tram.dart';
import 'dart:async';
import '../Data/favorite_points.dart';
import 'acount/drwer_acount.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
List<LatLng> getPolylinePoints(Map<String, dynamic> json) {
  List points = json['data']['full_route'];

  return points.map((point) {
    return LatLng(point['lat'], point['lng']);
  }).toList();
}
List<LatLng> getmarkerlinePoints(Map<String, dynamic> json) {
  final boarding = json['data']['boarding_station'];
  final dropoff = json['data']['dropoff_station'];

  return [
    LatLng(boarding['latitude'], boarding['longitude']),
    LatLng(dropoff['latitude'], dropoff['longitude']),
  ];
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
  get places => Places.FlutterGooglePlacesSdk("AIzaSyDZVdJ8p-DXct1HPgvKcj_5GBDMWi5hVd8");
  LatLng? startPointSelected;
  LatLng? endPointSelected;
  bool start =false;
  bool And =false;
  RouteRequest routeRequest = RouteRequest();
  int Selection = 1 ;
  LatLng? _selectedPoint;
  LatLng? Point;
  String? _selectedAddress;
  bool _showBottomInfo = false;
  final MapController _mapController = MapController();
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  final LatLng startPoint = LatLng(36.021369, 6.566466);
  final LatLng endPoint = LatLng(36.034488, 6.572595);
  List<LatLng> routePoints = [];
  List<LatLng> L36 = [];
  List<LatLng> L58 = [];
  List<LatLng> L89 = [];
  List<LatLng> L608 = [];
  List<LatLng> L12 = [];
  List<Marker> taxiMarkers = [];
  List<Marker> busMarkers = [];
  List<Marker> tramMarkers = [];
  List<Marker> visibleMarkers = [];
   List<Marker> _Markers = [];
  List<Places.AutocompletePrediction> predictions = [];

  Future sendData(RouteRequest routeRequest) async {
    final response = await http.post(
      Uri.parse("http://10.222.16.227:5000/route"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(routeRequest.toJson()),
    );
    final data = jsonDecode(response.body);
    List<LatLng> polylinePoints = getPolylinePoints(data);
    List<LatLng> markerPoints = getmarkerlinePoints(data);
    setState(() {
          routePoints = polylinePoints;
         _Marker= markerPoints;
         });
    await buildMarkers('bus');
    return polylinePoints;
  }
  @override
  void initState() {
    super.initState();
    _checkPermission();
    loadUserImage();
    //fetchLoopRoute();
    Future.microtask(() async {
      await loadAllRoutes();
    });
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
   print('$routeName  asd $data  ');
    return data
        .map((e) => LatLng(e['lat'], e['lng']))
        .toList();

  }


  Future<void> changeSelection( int newSelection) async {
    print("Selection: $newSelection");
    setState(() {
      Selection = newSelection;
      // routePoints.clear();
    });
    switch (Selection) {
      case 1:
        await loadRoute('taxi');
        routeRequest.document = "taxi";
        break;
      case 2:
        await loadRoute('tram');
        routeRequest.document = "tram";
        break;
      case 3:
        await loadRoute('bus');
        routeRequest.document = "bus";
        break;
    }
  }
  Future<void> loadAllRoutes() async {
    final l36 = await loadRouteFromFirebase('L36','routes');
    // final l58 = await loadRouteFromFirebase('L58','routes');
     final l89 = await loadRouteFromFirebase('L89A','routes');
    // final l608 = await loadRouteFromFirebase('L608A','routes');
    // final l12 = await loadRouteFromFirebase('L12','routes');

    setState(() {
      L36 = l36;
      // L58 = l58;
      L89 = l89;
      // L608 = l608;
      // L12 = l12;
    });
  }
  Future<void> loadRoute(
      String type,
      ) async {
    final points = await loadRouteFromFirebase(type,'routes');
    // final points = line1;
    final markers = await loadRouteFromFirebase(type,'markers');

    setState(() {
      routePoints = points;
      _Marker = markers;
    });
    //_mapController.move(routePoints.first, 15);
    await buildMarkers(type);
    if (_Marker.isNotEmpty) {
      _mapController.move(_Marker.first, 18);
    }
  }
  // Future<void> loadBusRoute() async {
  //   final points = await loadRouteFromFirebase('bus','routes');
  //   final marker = await loadRouteFromFirebase('bus','markers');
  //
  //   setState(() {
  //     loopRoutePoints = points;
  //     _busMarker= marker;
  //   });
  //
  // }


  List<LatLng> _Marker = [];


  Future<void> saveRouteToFirebase(
      String type,
      List<LatLng> points,
      ) async {
    final data = points.map((p) => {
      'lat': p.latitude,
      'lng': p.longitude,
    }).toList();
    print('aaaaaaaaaaaaaaaaaaaa');
    try {
      await FirebaseFirestore.instance
          .collection('routes')
          .doc(type)
          .set({'points': data});

      print("✅ Saved successfully: $type");
    } catch (e) {
      print("❌ Firebase error: $e");
    }
  }
  Future<void> buildMarkers(String type) async {
    List<Marker> temp = [];

    for (int i = 0; i < _Marker.length; i++) {
      temp.add(
        Marker(
          point: _Marker[i],
          width: 40,
          height: 40,
          child: CircleAvatar(
            backgroundColor:  Colors.black45,
            child: Icon(
              type == "taxi"
                  ? Icons.local_taxi
                  : type == "bus"
                  ? Icons.directions_bus
                  : Icons.train,
              color: Colors.greenAccent,
            ),
          ),
        ),
      );
    }

    setState(() {
      if (type == "taxi") taxiMarkers = temp;
      if (type == "bus") busMarkers = temp;
      if (type == "tram") tramMarkers = temp;

      visibleMarkers = temp; // 👈 هذا المهم
    });
  }
  // await saveRouteToFirebase('bus', busStops);
  void fetchLoopRoute() async {
  // هاذي ليستا لموها يدويا  تع النقاط المتوقة لل   خط نقل
    final loopWaypoints = L36A;

    // تحويل النقاط إلى نص الـ OSRM
    final coords = loopWaypoints.map((p) => "${p.longitude},${p.latitude}").join(";");

    final url = "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);
    final routeCoords = data['routes'][0]['geometry']['coordinates'];

    setState(() {
      routePoints = routeCoords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    });
    _mapController.move(routePoints.first, 15);
   //await saveRouteToFirebase('L36', routePoints);
  }

  void fetchRouteWithWaypoints() async {
    // نقاط الطريق (Waypoints)
    final waypoints = [
      LatLng(36.021369, 6.566466), // البداية
      LatLng(36.021076, 6.567990), // نقطة وسطى
      LatLng(36.034488, 6.572595), // النهاية
    ];

    // إنشاء سلسلة الإحداثيات بالشكل المطلوب من OSRM (lon,lat;lon,lat;...)
    final coords = waypoints.map((p) => "${p.longitude},${p.latitude}").join(";");

    final url = "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);
    final routeCoords = data['routes'][0]['geometry']['coordinates'];

    setState(() {
      routePoints = routeCoords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    });


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

  void _handleMapTapOSM(LatLng point) async {
    setState(() {
      _Markers.clear();
      _Markers.add(
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
        _Markers.clear();
        _Markers.add(
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
                MarkerLayer(markers: _Markers),
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
                if (L89.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: L89,
                        color: Colors.red,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (L36.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: L36,
                        color: Colors.brown,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (L608.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: L608,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (L12.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: L12,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                if (L58.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: L58,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: line1,
                      color: Colors.green,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                MarkerLayer(markers: visibleMarkers),
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
            if (_showSearch)
              Positioned(
                top: kToolbarHeight,
                left: 15,
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  constraints: BoxConstraints(maxHeight: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (value) async {
                          if (value.isEmpty) {
                            setState(() => predictions = []);
                            return;
                          }
                          final result = await places.findAutocompletePredictions(
                            value,
                            countries: ["dz"],
                          );
                          setState(() => predictions = List.from(result.predictions));
                        },
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "search_hint".tr(),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      if (predictions.isNotEmpty)
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: predictions.length,
                            itemBuilder: (context, index) {
                              final p = predictions[index];
                              return ListTile(
                                title: Text(p.fullText),
                                onTap: () async {
                                  final detail = await places.fetchPlace(
                                    p.placeId,
                                    fields: [Places.PlaceField.Location],
                                  );
                                  final lat = detail.place!.latLng!.lat;
                                  final lng = detail.place!.latLng!.lng;

                                  _mapController.move(LatLng(lat, lng), 18);

                                  setState(() {
                                    predictions = [];
                                    _showSearch = false;
                                    _searchController.clear();

                                    // ✅ أضف الـ marker
                                    //_Markers.clear();
                                    _Markers.add(
                                      Marker(
                                        point: LatLng(lat, lng),
                                        width: 60,
                                        height: 60,
                                        child: const Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 60,
                                        ),
                                      ),
                                    );
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ]
      ),
    );
  }
}