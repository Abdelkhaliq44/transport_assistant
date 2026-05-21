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
//import 'package:transport_assistant/lines_etusa/tren.dart';
import 'package:transport_assistant/marker/L36_station.dart';
import 'package:transport_assistant/marker/metro.dart';
import 'package:transport_assistant/marker/stastion_L89.dart';
import 'package:transport_assistant/marker/station_NL12.dart';
import 'package:transport_assistant/marker/station_NL58.dart';
import 'package:transport_assistant/marker/station_NL608.dart';
import 'package:transport_assistant/marker/tram.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:transport_assistant/marker/tran.dart';
import 'package:transport_assistant/ui_pages/opshns_content/saved_points.dart';
import 'dart:async';
import '../Data/favorite_points.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transport_assistant/UI/favorites_point.dart';
import 'package:transport_assistant/UI/historique.dart';
import 'package:transport_assistant/UI/saved_point.dart';
import 'opshns_content/favorite_points.dart';
import 'opshns_content/register.dart';

// ── helpers ──────────────────────────────────────────────────────────────────
List<LatLng> getPolylinePoints(Map<String, dynamic> json) {
  List points = json['data']['full_route'];
  return points.map((point) => LatLng(point['lat'], point['lng'])).toList();
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
  double? lat1, long1, lat2, long2;
  String? document;
  Map<String, dynamic> toJson() => {
    "lat1": lat1,
    "long1": long1,
    "lat2": lat2,
    "long2": long2,
    "document": document,
  };
}
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

double lastLat = 36.7845876;
double lastLng = 3.0572862;

class LineSelectionRequest {
  double? lat1, long1, lat2, long2;
  String cost, time, comfort;
  LineSelectionRequest({
    this.lat1,
    this.long1,
    this.lat2,
    this.long2,
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
  factory LineResult.fromJson(Map<String, dynamic> json) =>
      LineResult(lineName: json['line_name'], score: (json['score'] as num).toDouble());
}

// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  final Function(Locale)? onLocaleChanged;
  const HomePage({super.key, this.onLocaleChanged});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Future<void> loadLineByName(String lineName) async {
    routeRequest.document = lineName;
    await loadRoute(lineName);
    if (trainPoints.isNotEmpty) {
      _mapController.move(trainPoints.first, 14);
    }
  }
// Agent response data
  List<LatLng> agentRoutePoints = [];
  List<Marker> agentMarkers = [];
  final TextEditingController _searchController = TextEditingController();
  List<Places.AutocompletePrediction> _searchPredictions = [];
  List<Places.AutocompletePrediction> _startPredictions = [];
  List<Places.AutocompletePrediction> _endPredictions = [];

  get places => Places.FlutterGooglePlacesSdk("AIzaSyDZVdJ8p-DXct1HPgvKcj_5GBDMWi5hVd8");
  LatLng? _pendingPickerPoint;
  String? _pendingPickerAddress;

  bool _showSearch = false;
  bool _showGetLine = false;
  bool _showMapPicker = false;
  bool _showLocationCard = false;
  bool _showRouteCard = false;
  bool _isSaved = false;
  bool _isFavorite = false;

  String? _pickerTarget;

  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  int _selectedTransport = 0;
  final List<FaIconData> _transportIcons = [
    FontAwesomeIcons.taxi,
    FontAwesomeIcons.bus,
    FontAwesomeIcons.trainSubway,
    FontAwesomeIcons.trainTram,
    FontAwesomeIcons.train,
    FontAwesomeIcons.cableCar,
  ];

  LatLng? startPointSelected;
  LatLng? endPointSelected;
  String? _activeField;

  RouteRequest routeRequest = RouteRequest();
  LatLng? _selectedPoint;
  String? _selectedAddress;

  final MapController _mapController = MapController();

  List<LatLng> trainPoints = [];
  List<LatLng> L36 = [];
  List<LatLng> L58 = [];
  List<LatLng> L89 = [];
  List<LatLng> L608 = [];
  List<LatLng> L12 = [];
  List<LatLng> Metro = [];
  List<LatLng> Tram = [];
  List<LatLng> Teleferik = [];
  List<LatLng> taxi = [];

  List<Marker> taxiMarkers = [];
  List<Marker> busMarkers = [];
  List<Marker> tramMarkers = [];
  List<Marker> metroMarkers = [];
  List<Marker> L58Markers = [];
  List<Marker> L608Markers = [];
  List<Marker> L36Markers = [];
  List<Marker> L89Markers = [];
  List<Marker> L12Markers = [];
  List<Marker> trainMarkers= [];
  List<Marker> teleferikMarkers = [];
  List<Marker> _Markers = [];

  List<Places.AutocompletePrediction> predictions = [];
  List<LineResult> suggestedLines = [];
  bool _showLineSelector = false;
  String selectedCost = "low";
  String selectedTime = "medium";
  String selectedComfort = "low";
  LineSelectionRequest lineSelectionRequest = LineSelectionRequest();
  String? _selectedLineName;
  String? imgpathe;

  bool get start => _activeField == 'start';
  bool get And => _activeField == 'end';

  Future<void> _selectStartPlaceNoMove(Places.AutocompletePrediction prediction) async {
    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [Places.PlaceField.Location, Places.PlaceField.Name],
      );
      final loc = detail.place?.latLng;
      if (loc != null) {
        final target = LatLng(loc.lat, loc.lng);
        setState(() {
          startPointSelected = target;
          routeRequest.lat1 = loc.lat;
          routeRequest.long1 = loc.lng;
          _startController.text = prediction.fullText ?? prediction.primaryText ?? '';
          _startPredictions = [];
          _activeField = null;
        });

        // ── إرسال للـ agent إذا تم تحديد كلا النقطتين ──
        if (routeRequest.lat2 != null && routeRequest.long2 != null) {
          await sendData(routeRequest);
        }
      }
    } catch (e) {
      _snack('error_select_start'.tr());
    }
  }

  Future<void> _selectEndPlaceNoMove(Places.AutocompletePrediction prediction) async {
    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [Places.PlaceField.Location, Places.PlaceField.Name],
      );
      final loc = detail.place?.latLng;
      if (loc != null) {
        final target = LatLng(loc.lat, loc.lng);
        setState(() {
          endPointSelected = target;
          routeRequest.lat2 = loc.lat;
          routeRequest.long2 = loc.lng;
          _endController.text = prediction.fullText ?? prediction.primaryText ?? '';
          _endPredictions = [];
          _activeField = null;
        });

        // ── إرسال للـ agent إذا تم تحديد كلا النقطتين ──
        if (routeRequest.lat1 != null && routeRequest.long1 != null) {
          await sendData(routeRequest);
        }
      }
    } catch (e) {
      _snack('error_select_end'.tr());
    }
  }

  // ── Search helpers ──────────────────────────────────────────────────────────
  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchPredictions = []);
      return;
    }
    try {
      final result = await places.findAutocompletePredictions(query);
      setState(() => _searchPredictions = result.predictions);
    } catch (e) {
      print("Search error: $e");
    }
  }

  Future<void> _searchStartPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _startPredictions = []);
      return;
    }
    try {
      final result = await places.findAutocompletePredictions(
        query,
        // ── تقييد البحث على الجزائر العاصمة ──
        locationBias: Places.LatLngBounds(
          southwest: Places.LatLng(lat: 36.60, lng: 2.90),
          northeast: Places.LatLng(lat: 36.90, lng: 3.30),
        ),
        countries: ['DZ'],
      );
      setState(() => _startPredictions = result.predictions);
    } catch (e) {
      print("Start search error: $e");
    }
  }

  Future<void> _searchEndPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _endPredictions = []);
      return;
    }
    try {
      final result = await places.findAutocompletePredictions(
        query,
        // ── تقييد البحث على الجزائر العاصمة ──
        locationBias: Places.LatLngBounds(
          southwest: Places.LatLng(lat: 36.60, lng: 2.90),
          northeast: Places.LatLng(lat: 36.90, lng: 3.30),
        ),
        countries: ['DZ'],
      );
      setState(() => _endPredictions = result.predictions);
    } catch (e) {
      print("End search error: $e");
    }
  }
  String _getTransportType(String? lineName) {
    if (lineName == null) return 'bus';
    switch (lineName) {
      case 'taxi':                          return 'taxi';
      case 'tram':                          return 'tram';
      case 'metro':                         return 'metro';
      case 'teleferik':                     return 'teleferik';
      case 'train':                          return 'train';
      case 'L12':
      case 'L36':
      case 'L58':
      case 'L608A':
      case 'L89A':                          return 'bus';
      default:                              return 'bus';
    }
  }
  Future<void> _selectStartPlace(Places.AutocompletePrediction prediction) async {
    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [Places.PlaceField.Location, Places.PlaceField.Name],
      );
      final loc = detail.place?.latLng;
      if (loc != null) {
        final target = LatLng(loc.lat, loc.lng);
        _mapController.move(target, 17);
        setState(() {
          startPointSelected = target;
          routeRequest.lat1 = loc.lat;
          routeRequest.long1 = loc.lng;
          _startController.text = prediction.fullText ?? prediction.primaryText ?? '';
          _startPredictions = [];
          _activeField = null;
        });
      }
    } catch (e) {
      _snack('error_navigate_start'.tr());
    }
  }

  Future<void> _selectEndPlace(Places.AutocompletePrediction prediction) async {
    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [Places.PlaceField.Location, Places.PlaceField.Name],
      );
      final loc = detail.place?.latLng;
      if (loc != null) {
        final target = LatLng(loc.lat, loc.lng);
        _mapController.move(target, 17);
        setState(() {
          endPointSelected = target;
          routeRequest.lat2 = loc.lat;
          routeRequest.long2 = loc.lng;
          _endController.text = prediction.fullText ?? prediction.primaryText ?? '';
          _endPredictions = [];
          _activeField = null;
        });
      }
    } catch (e) {
      _snack('error_navigate_end'.tr());
    }
  }

  Future<void> _goToSearchedPlace(Places.AutocompletePrediction prediction) async {
    try {
      final detail = await places.fetchPlace(
        prediction.placeId,
        fields: [Places.PlaceField.Location, Places.PlaceField.Name],
      );
      final loc = detail.place?.latLng;
      if (loc != null) {
        final target = LatLng(loc.lat, loc.lng);
        _mapController.move(target, 17);
        setState(() {
          _Markers
            ..clear()
            ..add(Marker(
              point: target,
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ));
          _searchController.text = prediction.fullText ?? prediction.primaryText ?? '';
          _searchPredictions = [];
          _showSearch = false;
        });
      }
    } catch (e) {
      _snack('error_navigate_place'.tr());
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _checkPermission();
    loadUserImage();
    Future.microtask(() async {
      //await loadAllRoutes();
    });
    testGoogleTraffic();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // ── API calls ───────────────────────────────────────────────────────────────
  Future<void> selectLines() async {
    print("🟠 selectLines بدأت");
    lineSelectionRequest
      ..lat1 = routeRequest.lat1
      ..long1 = routeRequest.long1
      ..lat2 = routeRequest.lat2
      ..long2 = routeRequest.long2
      ..cost = selectedCost
      ..time = selectedTime
      ..comfort = selectedComfort;
    print("📦 البيانات المرسلة للـ agent:");
    print(jsonEncode(lineSelectionRequest.toJson()));
    try {
      final response = await http.post(
        Uri.parse("https://agent-tr-2.onrender.com/select-lines"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(lineSelectionRequest.toJson()),
      );
      print("📩 status: ${response.statusCode}");
      print("📩 response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['data']['routes'] as List;
        setState(() {
          suggestedLines = routes.map((e) => LineResult.fromJson(e)).toList();
          _showLineSelector = true;
        });
      } else {
        _snack('error_fetch_lines'.tr(args: [response.statusCode.toString()]));
      }
    } catch (e) {
      _snack('error_connection'.tr(args: [e.toString()]));
    }
  }

  Future<void> testGoogleTraffic() async {
    const apiKey = "AIzaSyA2hpiRDBaCg7L1l4Qbvy9wglGRJjs2KpU";
    try {
      final response = await http.post(
        Uri.parse("https://routes.googleapis.com/directions/v2:computeRoutes"),
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,
          "X-Goog-FieldMask": "routes.duration,routes.staticDuration,routes.distanceMeters",
        },
        body: jsonEncode({
          "origin": {
            "location": {
              "latLng": {"latitude": 36.215837, "longitude": 2.879518}
            }
          },
          "destination": {
            "location": {
              "latLng": {"latitude": 36.218053, "longitude": 2.880538}
            }
          },
          "travelMode": "DRIVE",
          "routingPreference": "TRAFFIC_AWARE",
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['routes'][0];
        final dur = int.parse(route['duration'].replaceAll("s", ""));
        final stat = int.parse(route['staticDuration'].replaceAll("s", ""));
        final delay = dur - stat;
        print(delay < 60
            ? "🟢 لا يوجد ازدحام"
            : delay < 300
            ? "🟡 ازدحام متوسط"
            : "🔴 ازدحام قوي");
      }
    } catch (_) {}
  }

  Future<void> sendData(RouteRequest req) async {
    final response = await http.post(
      Uri.parse("https://agent-tr-2.onrender.com/route"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(req.toJson()),
    );
    final data = jsonDecode(response.body);

    final List points = data['data']['full_route'];
    final polyline = points
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();

    final boardingLat = (data['data']['boarding_station']['latitude']  as num).toDouble();
    final boardingLng = (data['data']['boarding_station']['longitude'] as num).toDouble();
    final dropoffLat  = (data['data']['dropoff_station']['latitude']   as num).toDouble();
    final dropoffLng  = (data['data']['dropoff_station']['longitude']  as num).toDouble();

    // ✅ حوّل اسم الخط إلى نوع وسيلة النقل
    final transportType = _getTransportType(req.document);
    final markerColor   = _getMarkerColor(transportType);
    final markerIcon    = getIcon(transportType);

    setState(() {
      trainPoints = [];
      L36 = []; L58 = []; L89 = []; L608 = [];
      L12 = []; Tram = []; Metro = []; Teleferik = []; taxi = [];
      L36Markers = []; L58Markers = []; L89Markers = [];
      L608Markers = []; L12Markers = []; tramMarkers = [];
      metroMarkers = []; teleferikMarkers = [];
      taxiMarkers = []; busMarkers = []; trainMarkers = [];
      _Markers = [];

      agentRoutePoints = polyline;
      agentMarkers = [
        _buildAgentMarker(
          LatLng(boardingLat, boardingLng),
          markerColor,
          markerIcon,
          isBoarding: true,
        ),
        _buildAgentMarker(
          LatLng(dropoffLat, dropoffLng),
          markerColor,
          markerIcon,
          isBoarding: false,
        ),
      ];
    });

    _mapController.move(LatLng(boardingLat, boardingLng), 14);
  }

// ── helper لبناء marker الـ agent ──────────────────────────────
  Marker _buildAgentMarker(
      LatLng point,
      Color color,
      Widget icon, {
        required bool isBoarding,
      }) {
    return Marker(
      point: point,
      width: 50,
      height: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isBoarding ? Colors.greenAccent : Colors.redAccent,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          // مثلث صغير في الأسفل
          CustomPaint(
            size: const Size(12, 7),
            painter: _TrianglePainter(color: color),
          ),
        ],
      ),
    );
  }
  // ── Firebase / Storage ──────────────────────────────────────────────────────
  loadUserImage() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
      final url = await ref.getDownloadURL();
      setState(() {
        imgpathe = url;
      });
    } catch (e) {
      print("Error loading user image: $e");
    }
  }

  Future<List<LatLng>> loadRouteFromFirebase(String routeName, String choice, String route) async {
    try {
      final doc = await FirebaseFirestore.instance.collection(route).doc(routeName).get();
      if (!doc.exists) return [];

      // ✅ تحقق أن الـ field موجود قبل القراءة
      final data = doc.data();
      if (data == null || !data.containsKey(choice)) return [];

      final List list = doc[choice];
      return list.map((e) => LatLng(e['lat'], e['lng'])).toList();
    } catch (e) {
      print("❌ loadRouteFromFirebase error [$routeName/$choice]: $e");
      return [];
    }
  }

  Future<void> onSelectRoute(String lineName) async {
    setState(() {
      L36 = []; L58 = []; L89 = []; L608 = [];
      L12 = []; Tram = []; Metro = []; Teleferik = []; taxi = [];
      L36Markers = []; L58Markers = []; L89Markers = [];
      L608Markers = []; L12Markers = []; tramMarkers = [];
      metroMarkers = []; teleferikMarkers = [];
      taxiMarkers = []; busMarkers = []; trainMarkers = [];
    });

    if (lineName == 'taxi') {
      await loadRoute('taxi');
      return;
    }

    final routePoints = await loadRouteFromFirebase(lineName, 'points', 'routes');
    final markerPoints = await loadRouteFromFirebase(lineName, 'marker', 'routes');

    setState(() {
      switch (lineName) {
        case 'L36':   L36 = routePoints; break;
        case 'L58':   L58 = routePoints; break;
        case 'L89A':  L89 = routePoints; break;
        case 'L608A': L608 = routePoints; break;
        case 'L12':   L12 = routePoints; break;
        case 'tram':  Tram = routePoints; break;
        case 'metro': Metro = routePoints; break;
        //case 'train': trainMarkers = routePoints; break;
        case 'teleferik': Teleferik = routePoints; break;
      }
    });

    await buildMarkers(lineName, markerPoints);

    if (markerPoints.isNotEmpty) {
      _mapController.move(markerPoints.first, 14);
    } else if (routePoints.isNotEmpty) {
      _mapController.move(routePoints.first, 14);
    }
  }

  Future<void> loadAllRoutes() async {
    final markers = await loadRouteFromFirebase("train", 'marker', 'routes');
    await loadRoute('L36');
    await loadRoute('L58');
    await loadRoute('L89A');
    await loadRoute('L608A');
    await loadRoute('L12');
    await loadRoute('tram');
    await loadRoute('metro');
    await loadRoute('teleferik');
    await loadRoute('taxi');
    await buildMarkers('train', markers);
  }

  Future<void> loadRoute(String type, {bool moveCamera = true}) async {
    final points = await loadRouteFromFirebase(type, 'points', 'routes');
    final markers = await loadRouteFromFirebase(type, 'marker', 'routes');

    setState(() {
      switch (type) {
        case 'L36':       L36 = points; break;
        case 'L58':       L58 = points; break;
        case 'L89A':      L89 = points; break;
        case 'L608A':     L608 = points; break;
        case 'L12':       L12 = points; break;
        case 'tram':      Tram = points; break;
        case 'metro':     Metro = points; break;
        case 'teleferik': Teleferik = points; break;
        case 'taxi':      taxi = points; break;
        case 'train':      trainPoints = points; break;
        default:          trainPoints = points; break;
      }
    });

    await buildMarkers(type, markers);

    if (moveCamera) {
      if (markers.isNotEmpty) {
        _mapController.move(markers.first, 14);
      } else if (points.isNotEmpty) {
        _mapController.move(points.first, 14);
      }
    }
  }
  Future<void> saveRouteToFirebase(String type, String choice, List<LatLng> points) async {
    final data = points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();
    await FirebaseFirestore.instance
        .collection('routes')
        .doc(type)
        .set({choice: data}, SetOptions(merge: true));
  }

  Future<void> buildMarkers(String type, List<LatLng> list) async {
    final temp = list
        .map((pt) => Marker(
      point: pt,
      width: 44,
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: _getMarkerColor(type),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getMarkerColor(type).withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Center(child: getIcon(type)),
      ),
    ))
        .toList();

    setState(() {
      if (type == "taxi")     { taxiMarkers = temp; busMarkers.clear(); }
      if (type == "bus")      { busMarkers = temp; taxiMarkers.clear(); }
      if (type == "tram")     tramMarkers = temp;
      if (type == "metro")    metroMarkers = temp;
      if (type == "teleferik") teleferikMarkers = temp;
      if (type == "train")     trainMarkers = temp;
      if (type == "L12")      L12Markers = temp;
      if (type == "L58")      L58Markers = temp;
      if (type == "L608A")    L608Markers = temp;
      if (type == "L36")      L36Markers = temp;
      if (type == "L89A")     L89Markers = temp;
    });
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case "taxi":      return const Color(0xFFFFC107);
      case "bus":
      case "L12":
      case "L36":
      case "L58":
      case "L608A":
      case "L89A":      return const Color(0xFF1565C0);
      case "tram":      return const Color(0xFF6A1B9A);
      case "metro":     return const Color(0xFFBF360C);
      case "teleferik": return const Color(0xFF00695C);
      case "train":      return const Color(0xFFC62828);
      default:          return const Color(0xFF37474F);
    }
  }

  Widget getIcon(String type) {
    switch (type) {
      case "taxi":      return const FaIcon(FontAwesomeIcons.taxi,        color: Colors.white, size: 20);
      case "bus":       return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      case "tram":      return const FaIcon(FontAwesomeIcons.trainTram,   color: Colors.white, size: 20);
      case "metro":     return const FaIcon(FontAwesomeIcons.train,       color: Colors.white, size: 20);
      case "teleferik": return const FaIcon(FontAwesomeIcons.cableCar,    color: Colors.white, size: 20);
      case "train":      return const FaIcon(FontAwesomeIcons.trainSubway, color: Colors.white, size: 20);
      case "L12":       return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      case "L36":       return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      case "L58":       return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      case "L608A":     return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      case "L89A":      return const FaIcon(FontAwesomeIcons.bus,         color: Colors.white, size: 20);
      default:          return const FaIcon(FontAwesomeIcons.locationDot, color: Colors.white, size: 20);
    }
  }

  // ── Map interactions ─────────────────────────────────────────────────────────
  Future<void> _onTransportSelected(int index) async {
    setState(() {
      _selectedTransport = index;
      agentRoutePoints = [];
      agentMarkers = [];
      L36 = []; L58 = []; L89 = []; L608 = [];
      L12 = []; Tram = []; Metro = []; Teleferik = []; taxi = [];
      L36Markers = []; L58Markers = []; L89Markers = [];
      L608Markers = []; L12Markers = []; tramMarkers = [];
      metroMarkers = []; teleferikMarkers = [];
      taxiMarkers = []; busMarkers = []; trainMarkers = [];
      trainPoints = [];
      _Markers = [];
    });

    switch (index) {
      case 0:
        await loadRoute('taxi');
        break;

      case 1:
        await loadRoute('L36',   moveCamera: false);
        await loadRoute('L58',   moveCamera: false);
        await loadRoute('L89A',  moveCamera: false);
        await loadRoute('L608A', moveCamera: false);
        await loadRoute('L12',   moveCamera: false);

        final firstPoints = L36.isNotEmpty ? L36
            : L58.isNotEmpty ? L58
            : L89.isNotEmpty ? L89
            : L608.isNotEmpty ? L608
            : L12.isNotEmpty ? L12
            : <LatLng>[];

        if (firstPoints.isNotEmpty) {
          double minLat = firstPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
          double maxLat = firstPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
          double minLng = firstPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
          double maxLng = firstPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

          final bounds = LatLngBounds(
            LatLng(minLat, minLng),
            LatLng(maxLat, maxLng),
          );

          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(50),
            ),
          );
        }
        break;

      case 2: // ── القطار ──
        final points = await loadRouteFromFirebase('train', 'points', 'routes');
        final markers = await loadRouteFromFirebase('train', 'marker', 'routes');
        setState(() => trainPoints = points);
        await buildMarkers('train', markers); // ← stations ثابتة
        if (markers.isNotEmpty) {
          _mapController.move(markers.first, 12);
        } else if (points.isNotEmpty) {
          _mapController.move(points.first, 12);
        }
        break;

      case 3:
        await loadRoute('tram');
        break;

      case 4:
        await loadRoute('metro');
        break;

      case 5:
        await loadRoute('teleferik');
        break;
    }
  }

  void _handleMapTap(LatLng point) async {
    if (_showSearch || _showGetLine) return;
    if (_showRouteCard) {
      setState(() => _showRouteCard = false);
      return;
    }

    setState(() {
      _Markers
        ..clear()
        ..add(Marker(
          point: point,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
        ));
      if (_activeField == 'start') {
        startPointSelected = point;
        routeRequest.lat1 = point.latitude;
        routeRequest.long1 = point.longitude;
      } else if (_activeField == 'end') {
        endPointSelected = point;
        routeRequest.lat2 = point.latitude;
        routeRequest.long2 = point.longitude;
      }
    });

    try {
      final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = "${p.name ?? ''}, ${p.locality ?? ''}, ${p.country ?? ''}";
        setState(() {
          _selectedPoint = point;
          _selectedAddress = address;

          if (_showMapPicker && _pickerTarget != null) {
            _pendingPickerPoint = point;
            _pendingPickerAddress = address;
          } else if (_activeField != null) {
            if (_activeField == 'start') {
              _startController.text = address;
            } else if (_activeField == 'end') {
              _endController.text = address;
            }
          } else {
            _showLocationCard = true;
            _isSaved = false;
            _isFavorite = false;
          }
        });
      }
    } catch (_) {
      _snack('error_fetch_address'.tr());
    }
  }

  void _toggleFavpoint(double lng, double lat, String place) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('Favpoint').doc(uid);
    final data = await docRef.get();
    final favData = Map<String, dynamic>.from(data.data() ?? {});

    if (_isFavorite) {
      favData.removeWhere((key, value) =>
      value is List && value.isNotEmpty && value[0].toString() == place);
      await docRef.set(favData);
      setState(() {
        _isFavorite = false;
        pointFav = favData.values
            .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
            .toList();
      });
      _snack('removed_from_favorites'.tr());
    } else {
      favData["point${favData.length + 1}"] = ['$place', '$lat', '$lng'];
      await docRef.set(favData);
      setState(() {
        _isFavorite = true;
        pointFav = favData.values
            .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
            .toList();
      });
      _snack('added_to_favorites'.tr());
    }
  }

  void _toggleSavepoint(double lng, double lat, String place) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('Savepoint').doc(uid);
    final data = await docRef.get();
    final favData = Map<String, dynamic>.from(data.data() ?? {});

    if (_isSaved) {
      favData.removeWhere((key, value) =>
      value is List && value.isNotEmpty && value[0].toString() == place);
      await docRef.set(favData);
      setState(() {
        _isSaved = false;
        pointSaved = favData.values
            .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
            .toList();
      });
      _snack('removed_from_saved'.tr());
    } else {
      favData["point${favData.length + 1}"] = ['$place', '$lat', '$lng'];
      await docRef.set(favData);
      setState(() {
        _isSaved = true;
        pointSaved = favData.values
            .map((e) => (e as List<dynamic>).map((v) => v.toString()).toList())
            .toList();
      });
      _snack('added_to_saved'.tr());
    }
  }

  void _goToMyLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        _snack('location_permission_denied'.tr());
        return;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      _snack('location_permission_denied_forever'.tr());
      return;
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final myLocation = LatLng(pos.latitude, pos.longitude);
    _mapController.move(myLocation, 17);
    setState(() {
      _Markers
        ..clear()
        ..add(
          Marker(
            point: myLocation,
            width: 60,
            height: 60,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }

  Future<void> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) await Geolocator.requestPermission();
  }

  void _zoomIn() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
  void _zoomOut() =>
      _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);

  void moveCameraTo(double lat, double lng, String name) {
    final target = LatLng(lat, lng);
    _mapController.move(target, 18);
    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _Markers
          ..clear()
          ..add(Marker(
            point: target,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ));
      });
    });
  }

  Future<void> changeSelection(int newSelection) async {
    const typeMap = {1: 'taxi', 2: 'tram', 3: 'bus'};
    const iconIndexMap = {1: 0, 2: 3, 3: 1};
    final type = typeMap[newSelection];
    if (type == null) return;
    setState(() {
      _selectedTransport = iconIndexMap[newSelection] ?? 0;
    });
    await loadRoute(type);
    routeRequest.document = type;
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ── Route Card logic ─────────────────────────────────────────────────────────
  void _showRouteAlert() async {
    final startText = _startController.text.trim();
    final endText = _endController.text.trim();

    if (startText.isEmpty || endText.isEmpty) {
      _snack('error_select_start_end'.tr());
      return;
    }

    await selectLines();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: _buildGetLineAlert(
          startText,
          endText,
          onTraceLine: () {
            Navigator.pop(ctx);
            setState(() {
              _showGetLine = false;
              _showRouteCard = true;
            });
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── 1. Map ──────────────────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(lastLat, lastLng),
                initialZoom: 18,
                onTap: (_, point) => _handleMapTap(point),
                onPositionChanged: (position, _) {
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
                if (trainPoints.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: trainPoints, color: Colors.blue, strokeWidth: 4)
                  ]),
                if (trainPoints.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: trainPoints, color: Colors.redAccent, strokeWidth: 4)
                  ]),
                if (L89.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: L89, color: Colors.red, strokeWidth: 4)
                  ]),
                if (L36.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: L36, color: Colors.brown, strokeWidth: 4)
                  ]),
                if (L608.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: L608, color: Colors.blue, strokeWidth: 4)
                  ]),
                if (L12.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: L12, color: Colors.deepPurple, strokeWidth: 4)
                  ]),
                if (L58.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: L58, color: Colors.blue, strokeWidth: 4)
                  ]),
                if (Tram.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: Tram, color: Colors.green, strokeWidth: 4)
                  ]),
                if (Metro.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: Metro, color: Colors.black, strokeWidth: 4)
                  ]),
                if (Teleferik.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: Teleferik, color: Colors.black, strokeWidth: 4)
                  ]),
                if (taxi.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(points: taxi, color: Colors.pink, strokeWidth: 4)
                  ]),
                MarkerLayer(markers: metroMarkers),
                MarkerLayer(markers: taxiMarkers),
                MarkerLayer(markers: busMarkers),
                MarkerLayer(markers: tramMarkers),
                MarkerLayer(markers: teleferikMarkers),
                MarkerLayer(markers: trainMarkers),
                MarkerLayer(markers: L12Markers),
                MarkerLayer(markers: L58Markers),
                MarkerLayer(markers: L608Markers),
                MarkerLayer(markers: L36Markers),
                MarkerLayer(markers: L89Markers),
                // ── Agent route & markers (يُرسم فوق كل شيء) ──────────────
                if (agentRoutePoints.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: agentRoutePoints,
                      color: const Color(0xFF4A9EFF),
                      strokeWidth: 5,
                      borderColor: Colors.white.withOpacity(0.4),
                      borderStrokeWidth: 1.5,
                    ),
                  ]),
                MarkerLayer(markers: agentMarkers),
              ],
            ),
          ),

          // ── 2. UI Overlay ───────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: _buildActivePanel(),
                ),
                Expanded(child: Stack(children: []))
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _transportIcons.length,
                    (i) => _buildTransportButton(i),
              ).reversed.toList(),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _mapFab("loc",     Icons.my_location, _goToMyLocation),
                const SizedBox(height: 8),
                _mapFab("zoom_in",  Icons.add,    _zoomIn),
                const SizedBox(height: 8),
                _mapFab("zoom_out", Icons.remove, _zoomOut),
              ],
            ),
          ),

          // ── 3. Location Card ────────────────────────────────────────────────
          if (_showLocationCard && _selectedAddress != null)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _buildLocationCard(),
            ),

          // ── 4. Route Card ───────────────────────────────────────────────────
          if (_showRouteCard)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _buildRouteCard(),
            ),

          // ── 5. Map Picker Overlay ───────────────────────────────────────────
          if (_showMapPicker)
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _showMapPicker = false;
                            _showGetLine = true;
                            _pickerTarget = null;
                            _pendingPickerPoint = null;
                            _pendingPickerAddress = null;
                          }),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E3E4B).withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: _pendingPickerAddress != null
                            ? Container(
                          key: ValueKey(_pendingPickerAddress),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2B3A),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF4A9EFF), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A9EFF).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A9EFF).withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on,
                                    color: Color(0xFF4A9EFF), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _pickerTarget == 'start'
                                          ? 'picker_start_label'.tr()
                                          : 'picker_end_label'.tr(),
                                      style: const TextStyle(
                                        color: Color(0xFF4A9EFF),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _pendingPickerAddress!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          key: const ValueKey('hint'),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E3E4B).withOpacity(0.88),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.touch_app, color: Colors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _pickerTarget == 'start'
                                    ? 'picker_tap_start'.tr()
                                    : 'picker_tap_end'.tr(),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(70, 0, 70, 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _pendingPickerAddress == null
                              ? null
                              : () {
                            setState(() {
                              if (_pickerTarget == 'start') {
                                _startController.text = _pendingPickerAddress!;
                                routeRequest.lat1 = _pendingPickerPoint!.latitude;
                                routeRequest.long1 = _pendingPickerPoint!.longitude;
                              } else {
                                _endController.text = _pendingPickerAddress!;
                                routeRequest.lat2 = _pendingPickerPoint!.latitude;
                                routeRequest.long2 = _pendingPickerPoint!.longitude;
                              }
                              _showMapPicker = false;
                              _showGetLine = true;
                              _pickerTarget = null;
                              _pendingPickerPoint = null;
                              _pendingPickerAddress = null;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pendingPickerAddress == null
                                ? const Color(0xFF2E3E4B)
                                : const Color(0xFF4A9EFF),
                            disabledBackgroundColor: const Color(0xFF2E3E4B),
                            elevation: _pendingPickerAddress == null ? 0 : 6,
                            shadowColor: const Color(0xFF4A9EFF).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color: _pendingPickerAddress == null
                                    ? const Color(0xFF3A4F65)
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _pendingPickerAddress == null
                                    ? Icons.touch_app_outlined
                                    : Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _pendingPickerAddress == null
                                    ? 'picker_btn_choose'.tr()
                                    : 'picker_btn_confirm'.tr(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    );
  }

  // ── Panel router ─────────────────────────────────────────────────────────────
  Widget _buildActivePanel() {
    if (_showMapPicker)  return const SizedBox.shrink();
    if (_showRouteCard)  return _buildTopBar();
    if (_showGetLine)    return _buildGetLinePanel();
    if (_showSearch)     return _buildSearchPanel();
    return _buildTopBar();
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/67460f18808338f4f4b8dd938dff42beca7021c8.png',
            width: 40, height: 40,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _showSearch = true;
                _showLocationCard = false;
              }),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'search_hint'.tr(),
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(Icons.search, color: Colors.grey.shade700, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Panel ─────────────────────────────────────────────────────────────
  Widget _buildSearchPanel() {
    return _panelContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3E4B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBECFDF), width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'search_destination_hint'.tr(),
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => _searchPlaces(v),
                          onSubmitted: (v) {
                            if (_searchPredictions.isNotEmpty) {
                              _goToSearchedPlace(_searchPredictions.first);
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_searchPredictions.isNotEmpty) {
                            _goToSearchedPlace(_searchPredictions.first);
                          } else if (_searchController.text.trim().isNotEmpty) {
                            _searchPlaces(_searchController.text.trim());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _closeButton(onTap: () {
                _searchController.clear();
                setState(() {
                  _showSearch = false;
                  _searchPredictions = [];
                });
              }),
            ],
          ),

          if (_searchPredictions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2B3A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3A4F65)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: _searchPredictions.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
                itemBuilder: (_, i) {
                  final pred = _searchPredictions[i];
                  return InkWell(
                    onTap: () => _goToSearchedPlace(pred),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Color(0xFF4A9EFF), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pred.primaryText ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                if ((pred.secondaryText ?? '').isNotEmpty)
                                  Text(pred.secondaryText ?? '',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white30, size: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 14),

          Row(
            children: [
              _optionButton(
                icon: Icons.bookmark_border,
                label: 'saved_places'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavedPoints(
                      onGoToMap: (lat, lng, name) => moveCameraTo(lat, lng, name),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _optionButton(
                icon: Icons.history,
                label: 'history_places'.tr(),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Register())),
              ),
              const SizedBox(width: 10),
              _optionButton(
                icon: Icons.favorite_border,
                label: 'favorite_places'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => fav_point(
                      onGoToMap: (lat, lng, name) => moveCameraTo(lat, lng, name),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _primaryButton(
            icon: Icons.sync_alt,
            label: 'choose_start_end'.tr(),
            onPressed: () => setState(() {
              _showSearch = false;
              _showGetLine = true;
            }),
          ),
        ],
      ),
    );
  }

  // ── Get Line Panel ───────────────────────────────────────────────────────────
  Widget _buildGetLinePanel() {
    return _panelContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  _dot(filled: false),
                  Container(
                    width: 1.5, height: 34,
                    color: Colors.white38,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                  _dot(filled: true),
                  const SizedBox(height: 10),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _activeTextField(
                            controller: _startController,
                            hint: 'current_position'.tr(),
                            isActive: _activeField == 'start',
                            fieldType: 'start',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _mapPickerButton('start'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _activeTextField(
                            controller: _endController,
                            hint: 'choose_destination'.tr(),
                            isActive: _activeField == 'end',
                            fieldType: 'end',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _mapPickerButton('end'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Trip preferences
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2B3A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3A4F65), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'trip_preferences'.tr(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _prefChip('pref_cost'.tr(),    selectedCost,    (v) => setState(() => selectedCost = v))),
                    const SizedBox(width: 6),
                    Expanded(child: _prefChip('pref_time'.tr(),    selectedTime,    (v) => setState(() => selectedTime = v))),
                    const SizedBox(width: 6),
                    Expanded(child: _prefChip('pref_comfort'.tr(), selectedComfort, (v) => setState(() => selectedComfort = v))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Get Line button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () async {
                final startText = _startController.text.trim();
                final endText = _endController.text.trim();

                if (startText.isEmpty || endText.isEmpty) {
                  _snack('error_select_start_end'.tr());
                  return;
                }

                await selectLines();

                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (ctx) => SafeArea(
                    child: _buildGetLineAlert(
                      startText,
                      endText,
                      onTraceLine: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _showGetLine = false;
                          _showRouteCard = true;
                        });
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBECFDF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
              ),
              child: Text(
                'get_line'.tr(),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3E4B)),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Back button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showGetLine = false;
                  _showSearch = true;
                });
              },
              style: TextButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3A4F65), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    'back'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetLineAlert(
      String startText,
      String endText, {
        required VoidCallback onTraceLine,
      }) {
    // ← أضف هذا المتغير في الـ State الخاص بك:
    // String? _selectedLineName;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2B3A),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (suggestedLines.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'suggested_lines'.tr(),
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: suggestedLines.length,
                    itemBuilder: (_, i) {
                      final line = suggestedLines[i];
                      final isSelected = _selectedLineName == line.lineName; // ← تحقق من الاختيار

                      return GestureDetector(
                        onTap: () {
                          // ← فقط اختر الخط، لا تغلق ولا ترسل
                          setState(() => _selectedLineName = line.lineName);
                          setModalState(() {}); // ← حدّث واجهة الـ modal
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            // ← لون مختلف للخط المختار
                            color: isSelected
                                ? const Color(0xFF1A3A5C)
                                : const Color(0xFF2E3E4B),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              // ← border مميز للمختار
                              color: isSelected
                                  ? const Color(0xFF4A9EFF)
                                  : const Color(0xFF3A4F65),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: _getMarkerColor(line.lineName),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(child: getIcon(line.lineName)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  line.lineName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              // ← أيقونة تأكيد الاختيار
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.check_circle,
                                      color: Color(0xFF4A9EFF), size: 20),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'score_points'.tr(args: [line.score.toInt().toString()]),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3E4B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF3A4F65)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white54, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'press_get_line_first'.tr(),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Trace Line button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  // ← يُفعَّل فقط إذا تم اختيار خط
                  onPressed: _selectedLineName == null
                      ? null
                      : () async {
                    final selectedName = _selectedLineName!;
                    Navigator.pop(context);

                    // امسح بيانات agent القديمة أولاً
                    setState(() {
                      agentRoutePoints = [];
                      agentMarkers     = [];
                    });

                    // أرسل للـ agent واحفظ النتيجة
                    routeRequest.document = selectedName;
                    await sendData(routeRequest);

                    setState(() => _showGetLine = false);
                    onTraceLine();
                  },
                  style: ElevatedButton.styleFrom(
                    // ← لون رمادي إذا لم يتم الاختيار
                    backgroundColor: _selectedLineName == null
                        ? Colors.grey.shade700
                        : const Color(0xFF4A9EFF),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  icon: const Icon(Icons.route, color: Colors.white, size: 20),
                  label: Text(
                    'trace_line'.tr(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () {
                    setState(() => _selectedLineName = null); // ← reset عند الإلغاء
                    Navigator.pop(context);
                  },
                  child: Text(
                    'cancel'.tr(),
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  // ── Route Card ───────────────────────────────────────────────────────────────
  Widget _buildRouteCard() {
    final startText = _startController.text.trim();
    final endText = _endController.text.trim();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20, 14, 20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Start point row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  startText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _bsIconBtn(Icons.save_outlined, const Color(0xFF3A4F65), onTap: () {
                if (startPointSelected != null) {
                  _toggleSavepoint(startPointSelected!.longitude,
                      startPointSelected!.latitude, startText);
                }
              }),
              const SizedBox(width: 6),
              _bsIconBtn(Icons.favorite_border, const Color(0xFF3A4F65), onTap: () {
                if (startPointSelected != null) {
                  _toggleFavpoint(startPointSelected!.longitude,
                      startPointSelected!.latitude, startText);
                }
              }),
              const SizedBox(width: 6),
              _bsIconBtn(Icons.close, const Color(0xFF3A4F65), onTap: () => setState(() {
                _showRouteCard = false;
                _showGetLine = true;
              })),
            ],
          ),

          // Dotted connector
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(4, (_) => Container(
                width: 1.5, height: 5,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(1)),
              )),
            ),
          ),

          // End point row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  endText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Location Card ────────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1C2B3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20, 14, 20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: Color(0xFF4A9EFF), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedAddress ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _bsIconBtn(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                _isFavorite
                    ? Colors.pinkAccent.withOpacity(0.3)
                    : const Color(0xFF3A4F65),
                onTap: () {
                  if (_selectedPoint != null && _selectedAddress != null) {
                    _toggleFavpoint(_selectedPoint!.longitude,
                        _selectedPoint!.latitude, _selectedAddress!);
                  }
                },
              ),
              const SizedBox(width: 6),
              _bsIconBtn(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                _isSaved
                    ? Colors.tealAccent.withOpacity(0.3)
                    : const Color(0xFF3A4F65),
                onTap: () {
                  if (_selectedPoint != null && _selectedAddress != null) {
                    _toggleSavepoint(_selectedPoint!.longitude,
                        _selectedPoint!.latitude, _selectedAddress!);
                  }
                },
              ),
              const SizedBox(width: 6),
              _bsIconBtn(Icons.close, const Color(0xFF3A4F65), onTap: () => setState(() {
                _showLocationCard = false;
                _isSaved = false;
                _isFavorite = false;
              })),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared small widgets ─────────────────────────────────────────────────────
  Widget _prefChip(String label, String value, void Function(String) onChange) {
    const options = ["low", "medium", "high"];
    return GestureDetector(
      onTap: () {
        final idx = options.indexOf(value);
        final next = options[(idx + 1) % options.length];
        onChange(next);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3E4B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4A9EFF).withOpacity(0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 3),
            Text(
              // translate the value level
              value == "low"
                  ? 'pref_low'.tr()
                  : value == "medium"
                  ? 'pref_medium'.tr()
                  : 'pref_high'.tr(),
              style: TextStyle(
                color: value == "high"
                    ? Colors.redAccent
                    : value == "medium"
                    ? Colors.orangeAccent
                    : Colors.greenAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _geocodeManualInput(String address, String fieldType) async {
    if (address.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress(address);

      // ── Print النتائج ──
      print("🔍 Geocoding '$address':");
      for (var loc in locations) {
        print("   → lat: ${loc.latitude}, lng: ${loc.longitude}");
      }

      if (locations.isNotEmpty) {
        final loc = locations.first;
        print("✅ اخترنا: lat=${loc.latitude}, lng=${loc.longitude}");
        // ... باقي الكود
      }
    } catch (e) {
      print("❌ Geocoding error: $e");
      _snack('تعذر تحديد المكان، اختره من القائمة');
    }
  }
  Widget _activeTextField({
    required TextEditingController controller,
    required String hint,
    required bool isActive,
    required String fieldType,
  }) {
    final predList = fieldType == 'start' ? _startPredictions : _endPredictions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2E3E4B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? const Color(0xFF4A9EFF) : const Color(0xFFBECFDF),
              width: isActive ? 2.0 : 1.0,
            ),
            boxShadow: isActive
                ? [BoxShadow(
              color: const Color(0xFF4A9EFF).withOpacity(0.2),
              blurRadius: 8, spreadRadius: 1,
            )]
                : [],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: false,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onTap: () => setState(() => _activeField = fieldType),
                  onChanged: (v) {
                    if (fieldType == 'start') {
                      _searchStartPlaces(v);
                    } else {
                      _searchEndPlaces(v);
                    }
                  },
                  onSubmitted: (v) async {
                    final predList = fieldType == 'start' ? _startPredictions : _endPredictions;
                    if (predList.isNotEmpty) {
                      if (fieldType == 'start') {
                        await _selectStartPlaceNoMove(predList.first);
                      } else {
                        await _selectEndPlaceNoMove(predList.first);
                      }
                    } else {
                      // ← لا تستخدم geocoding، اطلب من المستخدم الاختيار من القائمة
                      _snack('اختر المكان من القائمة المقترحة');
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: isActive
                    ? const Icon(Icons.radio_button_checked,
                    color: Color(0xFF4A9EFF), size: 18)
                    : Icon(Icons.search, color: Colors.grey.shade400, size: 20),
              ),
            ],
          ),
        ),
        if (isActive && predList.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2B3A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3A4F65)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: predList.length,
              separatorBuilder: (_, __) =>
              const Divider(color: Colors.white12, height: 1),
              itemBuilder: (_, i) {
                final pred = predList[i];
                return InkWell(
                  onTap: () {
                    if (fieldType == 'start') {
                      _selectStartPlaceNoMove(pred);
                    } else {
                      _selectEndPlaceNoMove(pred);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          fieldType == 'start'
                              ? Icons.trip_origin
                              : Icons.location_on_outlined,
                          color: fieldType == 'start'
                              ? Colors.greenAccent
                              : const Color(0xFF4A9EFF),
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pred.primaryText ?? '',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              if ((pred.secondaryText ?? '').isNotEmpty)
                                Text(pred.secondaryText ?? '',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white30, size: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _mapPickerButton(String target) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A4F65)),
      ),
      child: IconButton(
        onPressed: () => setState(() {
          _pickerTarget = target;
          _activeField = target;
          _showMapPicker = true;
          _showGetLine = false;
        }),
        icon: const Icon(Icons.map_outlined, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _dot({required bool filled}) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        color: filled ? Colors.white : Colors.transparent,
      ),
      child: filled
          ? Center(
        child: Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(
              color: Color(0xFF2A3A4E), shape: BoxShape.circle),
        ),
      )
          : null,
    );
  }

  Widget _bsIconBtn(IconData icon, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }

  Widget _buildTransportButton(int index) {
    final selected = index == _selectedTransport;
    return GestureDetector(
      onTap: () => _onTransportSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF1E2A3A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: FaIcon(
            _transportIcons[index],
            color: selected ? const Color(0xFF1E2A3A) : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  FloatingActionButton _mapFab(String tag, IconData icon, VoidCallback onPressed) =>
      FloatingActionButton(
        heroTag: tag,
        mini: true,
        backgroundColor: const Color(0xFF2E3E4B),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white),
      );

  Widget _panelContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = MediaQuery.of(context).size.height * 0.78;
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: const Color(0xFF2E3E4B).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: child,
          ),
        );
      },
    );
  }

  Widget _closeButton({required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(color: Colors.grey.shade600, shape: BoxShape.circle),
      child: const Icon(Icons.close, color: Colors.white, size: 16),
    ),
  );

  Widget _optionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFBECFDF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBECFDF), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.3)),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 11),
              ],
            ),
          ),
        ),
      );

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBECFDF),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFF3A4F65), width: 1)),
          ),
          icon: Icon(icon, size: 18, color: const Color(0xFF2E3E4B)),
          label: Text(label,
              style: const TextStyle(
                  color: Color(0xFF2E3E4B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      );

  Widget _alertActionBtn({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E3E4B),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _cardIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isClose = false,
    bool isActive = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: isClose
                ? const Color(0xFFE57373).withOpacity(0.85)
                : isActive
                ? Colors.white
                : const Color(0xFF2E3E4B),
            shape: BoxShape.circle,
            border: isClose
                ? null
                : Border.all(
                color: isActive ? Colors.white : const Color(0xFF3A4F65),
                width: 1),
          ),
          child: Icon(icon,
              color: isClose
                  ? Colors.white
                  : isActive
                  ? const Color(0xFF1C2B3A)
                  : Colors.white,
              size: 17),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// Bottom Sheet helper class
// ═════════════════════════════════════════════════════════════════════════════
class _OriginalBottomSheet extends StatefulWidget {
  final String? selectedAddress;
  final LatLng? selectedPoint;
  final RouteRequest routeRequest;
  final Widget Function(String) getIcon;
  final void Function(String) onLineTap;
  final VoidCallback onGetLine, onFav, onSave;

  const _OriginalBottomSheet({
    required this.selectedAddress,
    required this.selectedPoint,
    required this.routeRequest,
    required this.getIcon,
    required this.onLineTap,
    required this.onGetLine,
    required this.onFav,
    required this.onSave,
  });

  @override
  State<_OriginalBottomSheet> createState() => _OriginalBottomSheetState();
}

class _OriginalBottomSheetState extends State<_OriginalBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C2B3A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 38, height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.selectedAddress != null)
                Text('📍 ${widget.selectedAddress}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                _iconBtn(Icons.favorite_border, Colors.redAccent, widget.onFav),
                const SizedBox(width: 8),
                _iconBtn(Icons.save_rounded, Colors.greenAccent, widget.onSave),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: widget.onGetLine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBECFDF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23)),
                  ),
                  child: Text('get_line'.tr(),
                      style: const TextStyle(
                          color: Color(0xFF2E3E4B),
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      IconButton(icon: Icon(icon, color: color, size: 24), onPressed: onTap);
}