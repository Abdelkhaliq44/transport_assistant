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
import 'package:transport_assistant/lines_etusa/line_metro.dart';
import 'package:transport_assistant/lines_etusa/line_tram.dart';
import 'package:transport_assistant/lines_etusa/sahetchohada_chevally_NL58.dart';
import 'package:transport_assistant/lines_etusa/staoueli_sahetchouhada_NL12.dart';
import 'package:transport_assistant/lines_etusa/tren.dart';
import 'package:transport_assistant/marker/L36_station.dart';
import 'package:transport_assistant/marker/metro.dart';
import 'package:transport_assistant/marker/stastion_L89.dart';
import 'package:transport_assistant/marker/station_NL12.dart';
import 'package:transport_assistant/marker/station_NL58.dart';
import 'package:transport_assistant/marker/station_NL608.dart';
import 'package:transport_assistant/marker/tram.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:transport_assistant/marker/tran.dart';
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
class LineSelectionRequest {
  double? lat1, long1, lat2, long2;
  String cost;
  String time;
  String comfort;

  LineSelectionRequest({
    this.lat1, this.long1, this.lat2, this.long2,
    this.cost = "low",
    this.time = "medium",
    this.comfort = "low",
  });

  Map<String, dynamic> toJson() => {
    "lat1": lat1,
    "long1": long1,
    "lat2": lat2,
    "long2": long2,
    "Cost": cost,
    "time": time,
    "Comfort": comfort,
  };
}

class LineResult {
  final String lineName;
  final double score;
  LineResult({required this.lineName, required this.score});

  factory LineResult.fromJson(Map<String, dynamic> json) {
    return LineResult(
      lineName: json['line_name'],
      score: (json['score'] as num).toDouble(),
    );
  }
}
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
  List<LatLng> Metro = [];
  List<LatLng> Tram = [];
  List<LatLng> Teleferik = [];
  List<Marker> taxiMarkers = [];
  List<Marker> busMarkers = [];
  List<Marker> tramMarkers = [];
  List<Marker> metroMarkers = [];
  List<Marker> L58Markers = [];
  List<Marker> L608Markers = [];
  List<Marker> L36Markers = [];
  List<Marker> L89Markers = [];
  List<Marker> L12Markers = [];
  List<Marker> tranMarkers = [];
  List<Marker> teleferikMarkers = [];
  List<Marker> visibleMarkers = [];
   List<Marker> _Markers = [];
  List<Places.AutocompletePrediction> predictions = [];
  List<LineResult> suggestedLines = [];
  bool _showLineSelector = false;
  String selectedCost = "low";
  String selectedTime = "medium";
  String selectedComfort = "low";
  LineSelectionRequest lineSelectionRequest = LineSelectionRequest();
  Future<void> selectLines() async {
    lineSelectionRequest.lat1 = routeRequest.lat1;
    lineSelectionRequest.long1 = routeRequest.long1;
    lineSelectionRequest.lat2 = routeRequest.lat2;
    lineSelectionRequest.long2 = routeRequest.long2;
    lineSelectionRequest.cost = selectedCost;
    lineSelectionRequest.time = selectedTime;
    lineSelectionRequest.comfort = selectedComfort;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.69:5001/select-lines"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(lineSelectionRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['data']['routes'] as List;

        setState(() {
          suggestedLines = routes
              .map((e) => LineResult.fromJson(e))
              .toList();
          _showLineSelector = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في جلب الخطوط: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في الاتصال: $e")),
      );
    }
  }
  Future<void> testGoogleTraffic() async {

    const apiKey = "AIzaSyA2hpiRDBaCg7L1l4Qbvy9wglGRJjs2KpU";

    final response = await http.post(
      Uri.parse(
        "https://routes.googleapis.com/directions/v2:computeRoutes",
      ),

      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,

        // البيانات المطلوبة
        "X-Goog-FieldMask":
        "routes.duration,routes.staticDuration,routes.distanceMeters"
      },

      body: jsonEncode({

        // نقطة البداية
        "origin": {
          "location": {
            "latLng": {
              "latitude": 36.215837,
              "longitude": 2.879518
            }
          }
        },

        // نقطة النهاية
        "destination": {
          "location": {
            "latLng": {
              "latitude": 36.218053,
              "longitude": 2.880538
            }
          }
        },

        "travelMode": "DRIVE",

        // تفعيل الترافيك
        "routingPreference": "TRAFFIC_AWARE"
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final route = data['routes'][0];

      // الوقت الحقيقي مع الازدحام
      final duration =
      int.parse(
        route['duration']
            .replaceAll("s", ""),
      );

      // الوقت بدون ازدحام
      final staticDuration =
      int.parse(
        route['staticDuration']
            .replaceAll("s", ""),
      );

      // فرق الازدحام
      final trafficDelay =
          duration - staticDuration;

      print("🚗 REAL TIME: $duration sec");
      print("🛣 NORMAL TIME: $staticDuration sec");
      print("🚦 DELAY: $trafficDelay sec");

      // تحليل الازدحام
      if (trafficDelay < 60) {

        print("🟢 لا يوجد ازدحام");

      } else if (trafficDelay < 300) {

        print("🟡 يوجد ازدحام متوسط");

      } else {

        print("🔴 يوجد ازدحام قوي");

      }

    } else {

      print("❌ ERROR");
      print(response.body);

    }
  }


  Future sendData(RouteRequest routeRequest) async {
    final response = await http.post(
      Uri.parse("http://192.168.1.69:5000/route"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(routeRequest.toJson()),
    );
    final data = jsonDecode(response.body);
    List<LatLng> polylinePoints = getPolylinePoints(data);
    List<LatLng> markerPoints = getmarkerlinePoints(data);
    setState(() {
          routePoints = polylinePoints;
         });
    await buildMarkers('bus',markerPoints);
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
    testGoogleTraffic();


  }
  // final firestore = FirebaseFirestore.instance;
  // Future<void> movePoints() async {
  //   // 1. جلب البيانات من المصدر
  //   final sourceDoc = await firestore
  //       .collection('markers')
  //       .doc('taxi')
  //       .get();
  //
  //   final points = sourceDoc.data()?['points'];
  //
  //   // 2. نقلها إلى routes
  //   await firestore
  //       .collection('routes')
  //       .doc('taxi')
  //       .set({
  //     'marker': points,
  //   }, SetOptions(merge: true));
  // }
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
  Future<List<LatLng>> loadRouteFromFirebase(String routeName,String choice,String route) async {
    final doc = await FirebaseFirestore.instance
        .collection(route)
    //'routes'
        .doc(routeName)
        .get();

    if (!doc.exists) return [];

    final List data = doc[choice];
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

  Widget getIcon(String type) {
    print('typeee $type');
    switch (type) {
      case "taxi":
        return Icon(Icons.local_taxi,color: Colors.greenAccent,);
      case "bus":
        return Icon(Icons.directions_bus,color: Colors.blueAccent,);
      case "tram":
        return Icon(Icons.tram,color: Colors.deepPurple,);
      case "metro":
        return Icon(Icons.directions_subway,color: Colors.deepOrangeAccent,);
      case "teleferik":
        return FaIcon(FontAwesomeIcons.cableCar,color: Colors.pink,);
      case "tran":
        return FaIcon(FontAwesomeIcons.train,color: Colors.pink,);
      case "L12":
        return Icon(Icons.label_important,color: Colors.deepOrangeAccent,);
      case "L36":
        return Icon(Icons.offline_bolt,color: Colors.lightGreenAccent,);
      case "L58":
        return Icon(Icons.adb_outlined,color: Colors.white12,);
      case "L608":
        return Icon(Icons.move_down,color: Colors.deepOrangeAccent,);
      case "L89":
        return Icon(Icons.tsunami,color: Colors.lightGreenAccent,);

      default:
        return Icon(Icons.help);
    }
  }
  Future<void> loadAllRoutes() async {
    final l36 = await loadRouteFromFirebase('L36','points','routes');
    final l58 = await loadRouteFromFirebase('L58','points','routes');
     final l89 = await loadRouteFromFirebase('L89A','points','routes');
     final l608 = await loadRouteFromFirebase('L608A','points','routes');
     final l12 = await loadRouteFromFirebase('L12','points','routes');
    final tram = await loadRouteFromFirebase('tram','points','routes');
     final metro = await loadRouteFromFirebase('metro','points','routes');
    final teleferik = await loadRouteFromFirebase('teleferik','points','routes');
    final tram_m = await loadRouteFromFirebase('tram','marker','routes');
    final L12_m = await loadRouteFromFirebase('L12','marker','routes');
    final L58_m = await loadRouteFromFirebase('L58','marker','routes');
    final L608_m = await loadRouteFromFirebase('L608A','marker','routes');
    final L89_m = await loadRouteFromFirebase('L89A','marker','routes');
    final L36_m = await loadRouteFromFirebase('L36','marker','routes');
    final metro_m = await loadRouteFromFirebase('metro','marker','routes');
    await buildMarkers('teleferik', teleferik);
     await buildMarkers('tram', tram_m);
     await buildMarkers('metro', metro_m);
    await buildMarkers('tran', Tran_station);
    await buildMarkers('L12', L12_m);
    await buildMarkers('L608', L608_m);
    await buildMarkers('L58', L58_m);
    await buildMarkers('L36', L36_m);
    await buildMarkers('L89', L89_m);
    // await saveRouteToFirebase('L12','marker',L12_station);
    // await saveRouteToFirebase('L58','marker',L58_station);
    // await saveRouteToFirebase('L608A','marker',L608_station);
    //await saveRouteToFirebase('metro','points',metro_line);
    setState(() {
      L36 = l36;
       L58 = l58;
      L89 = l89;
       L608 = l608;
       L12 = l12;
      Tram=tram;
       Metro =metro;
      Teleferik = teleferik;
    });

  }
  Future<void> loadRoute(
      String type,
      ) async {
    final points = await loadRouteFromFirebase(type,'points','routes');
    // final points = line1;
    final markers = await loadRouteFromFirebase(type,'marker','routes');

    setState(() {
      routePoints = points;
    });
    //_mapController.move(routePoints.first, 15);
    await buildMarkers(type,markers);
    _mapController.move(markers.first, 18);

  }
  // Future<void> loadBusRoute() async {
  //   final points = await loadRouteFromFirebase('bus','points','routes');
  //   final marker = await loadRouteFromFirebase('bus','marker','routes');
  //
  //   setState(() {
  //     loopRoutePoints = points;
  //     _busMarker= marker;
  //   });
  //
  // }



  Future<void> saveRouteToFirebase(
      String type,
      String choice,
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
          .set({choice: data},SetOptions(merge: true),);//up points to  marker

      print("✅ Saved successfully: $type");
    } catch (e) {
      print("❌ Firebase error: $e");
    }
  }
  Future<void> buildMarkers(String type,List<LatLng> _Markerl) async {
    List<Marker> temp = [];

    for (int i = 0; i < _Markerl.length; i++) {
      temp.add(
        Marker(
          point: _Markerl[i],
          width: 40,
          height: 40,
          child: CircleAvatar(
            backgroundColor:  Colors.black45,
            child:getIcon(type),
          ),
        ),
      );
    }

    setState(() {
      if (type == "taxi") {taxiMarkers = temp;busMarkers.clear();}
      if (type == "bus") {busMarkers = temp;taxiMarkers.clear();}
      if (type == "tram") tramMarkers = temp;
      if (type == "metro") metroMarkers = temp;
      if (type == "teleferik") teleferikMarkers = temp;
      if (type == "tran") tranMarkers = temp;
      if (type == "L12") L12Markers = temp;
      if (type == "L58") L58Markers = temp;
      if (type == "L608") L608Markers = temp;
      if (type == "L36") L36Markers = temp;
      if (type == "L89") L89Markers = temp;

      //visibleMarkers.clear();
     // visibleMarkers = temp; // 👈 هذا المهم
    });
  }
  // await saveRouteToFirebase('bus','points', busStops);
  void fetchLoopRoute() async {
  // هاذي ليستا لموها يدويا  تع النقاط المتوقة لل   خط نقل
    final loopWaypoints = L12A;

    // تحويل النقاط إلى نص الـ OSRM7
    final coords = loopWaypoints.map((p) => "${p.longitude},${p.latitude}").join(";");

    final url = "https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);
    final routeCoords = data['routes'][0]['geometry']['coordinates'];

    setState(() {
      routePoints = routeCoords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    });
    _mapController.move(routePoints.first, 15);
   //await saveRouteToFirebase('L12','points',routePoints);
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
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: tran_line,
                      color: Colors.redAccent,
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
                        color: Colors.deepPurple,
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
                if (Tram.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: Tram,
                      color: Colors.green,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                if (Metro.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: Metro,
                      color: Colors.black,
                      strokeWidth: 4,
                    ),
                  ],
                ),
                if (Teleferik.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: Teleferik,
                        color: Colors.black,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(markers: metroMarkers),
                MarkerLayer(markers:taxiMarkers ),
                MarkerLayer(markers: busMarkers),
                MarkerLayer(markers: tramMarkers),
                MarkerLayer(markers: teleferikMarkers),
                MarkerLayer(markers: tranMarkers),
                MarkerLayer(markers: L12Markers),
                MarkerLayer(markers: L58Markers),
                MarkerLayer(markers: L608Markers),
                MarkerLayer(markers: L36Markers),
                MarkerLayer(markers: L89Markers),
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
                            // --- Preferences ---
                            const SizedBox(height: 12),
                            Text("تفضيلات الرحلة", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),

// Cost
                            Row(children: [
                              const Text("التكلفة:  "),
                              DropdownButton<String>(
                                value: selectedCost,
                                items: ["low","medium","high"]
                                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedCost = v!),
                              ),
                            ]),

// Time
                            Row(children: [
                              const Text("الوقت:    "),
                              DropdownButton<String>(
                                value: selectedTime,
                                items: ["low","medium","high"]
                                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedTime = v!),
                              ),
                            ]),

// Comfort
                            Row(children: [
                              const Text("الراحة:   "),
                              DropdownButton<String>(
                                value: selectedComfort,
                                items: ["low","medium","high"]
                                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                    .toList(),
                                onChanged: (v) => setState(() => selectedComfort = v!),
                              ),
                            ]),

                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.route),
                              label: const Text("اقترح أفضل خط"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                              onPressed: () async {
                                await selectLines();
                              },
                            ),
                            
                            if (_showLineSelector && suggestedLines.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Text("الخطوط المقترحة:", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              ...suggestedLines.map((line) => Card(
                                child: ListTile(
                                  leading: getIcon(line.lineName),
                                  title: Text(line.lineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  trailing: Chip(
                                    label: Text("${line.score.toInt()} نقطة"),
                                    backgroundColor: Colors.blue.shade100,
                                  ),
                                  onTap: () async {
                                    // عند الضغط يحمل مسار الخط على الخريطة
                                    routeRequest.document = line.lineName;
                                    await sendData(routeRequest);
                                  },
                                ),
                              )).toList(),
                            ],
                            SizedBox(height: 109,)

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
                 // visibleMarkers.clear();
                  await changeSelection(newSelection.first);

                },   // ✅ بدون ;
              ),
            ),
          ],
      ),
    );
  }
}
   