import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'design_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;

/// Location-focused responsive page.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;

  PointAnnotationManager? userLocationAnnotationManager;
  geo.Position? currentPosition;
  String? errorMessage;
  bool isLoadingLocation = false;

  final List<Map<String, dynamic>> atmPoints = [
    {
      "name": "ATM 1",
      "lat": 38.35026165294819,
      "lng": 27.143345291811872,
    },
    {
      "name": "ATM 2",
      "lat": 38.44402462482285,
      "lng": 27.196236184237893,
    },
    {
      "name": "ATM 3",
      "lat": 38.46826337148145,
      "lng": 27.12594843737379,
    },
    {
      "name": "ATM 4",
      "lat": 38.40063699135852,
      "lng": 27.206825393626733,
    },
    {
      "name": "ATM 5",
      "lat": 38.39167143857076,
      "lng": 27.11246466058835,
    },
  ];

  List<Map<String, dynamic>> nearbyATMs = [];

void calculateNearbyATMs() {
      if (currentPosition == null) return;
        final List<Map<String, dynamic>> calculatedList = atmPoints.map((atm) {
        final distance = geo.Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          atm["lat"],
          atm["lng"],
        );
        return {
          ...atm,
          "distance": distance,
        };
      }).toList();

      calculatedList.sort((a,b) {
        return a["distance"].compareTo(b["distance"]);
      });
      setState(() {
          nearbyATMs = calculatedList;
        });
    }

  Future<void> getUserLocation() async {
    try {
      setState(() {
        isLoadingLocation = true;
        errorMessage = null;
      });
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Konum servisleri devre dışı. Lütfen açın.';
          isLoadingLocation = false;
        });
        return;
      }
      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          setState(() {
            errorMessage = 'Konum izini verilmedi.';
            isLoadingLocation = false;
          });
          return;
        }
      }
      if (permission == geo.LocationPermission.deniedForever) {
        setState(() {
          errorMessage = 'Konum izinleri kalıcı olarak reddedildi.';
          isLoadingLocation = false;
        });
        return;
      }
      final position = await geo.Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
        isLoadingLocation = false;
      });
      calculateNearbyATMs();
      if (mapboxMap == null) return; 
    
        final ByteData bytes = await rootBundle.load('assets/icons/user_location.png');
        final Uint8List imageData = bytes.buffer.asUint8List();

        final map = mapboxMap!;
        userLocationAnnotationManager ??=
            await map.annotations.createPointAnnotationManager();

        await userLocationAnnotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                position.longitude,
                position.latitude,
              ),
            ),
            image: imageData,
            iconSize: 0.25,
          ),
        );

        map.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                position.longitude,
                position.latitude,
              ),
            ),
            zoom: 14.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
    } catch (e) {
      setState(() {
        errorMessage = 'Konum alınırken hata oluştu: $e';
        isLoadingLocation = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Harita', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('ATM, şube ve rota planlaması.', style: TextStyle(color: Color(0xFF616161))),
            const SizedBox(height: 16),
            Container(
              height: 270,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                children: [
              MapWidget(
                key: const ValueKey("mapWidget"),
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(27.143345291811872, 38.35026165294819),
                  ),
                  zoom: 11.0,
                ),
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },

                onMapCreated: (MapboxMap map) async {

                  final ByteData bytes = await rootBundle.load('assets/icons/atm_marker.png');
                  final Uint8List imageData = bytes.buffer.asUint8List();

                    mapboxMap = map;
                    pointAnnotationManager =
                      await map.annotations.createPointAnnotationManager();

                  for (final atm in atmPoints) {
                    await pointAnnotationManager!.create(
                      PointAnnotationOptions(
                        geometry: Point(
                          coordinates: Position(
                            atm["lng"],
                            atm["lat"],
                          ),
                        ),
                        image: imageData,
                        iconSize: 0.2,
                      ),
                    );
                  }
                  await getUserLocation();
                },
              ) ,
              Positioned(
                right: 12,
                bottom: 12,
                child: Column(
                  children: [

                    FloatingActionButton.small(
                      heroTag: "zoomIn",
                      onPressed: () async {
                        if (mapboxMap == null) return;

                        final zoom = await mapboxMap!.getCameraState();

                        mapboxMap!.flyTo(
                        CameraOptions(
                          zoom: zoom.zoom + 1,
                        ),
                        MapAnimationOptions(duration: 500),
                      );
                      },
                      child: const Icon(Icons.add),
                    ),

                    const SizedBox(height: 8),

                    FloatingActionButton.small(
                      heroTag: "zoomOut",
                      onPressed: () async {
                        if (mapboxMap == null) return;

                        final zoom = await mapboxMap!.getCameraState();

                        mapboxMap!.flyTo(
                          CameraOptions(
                            zoom: zoom.zoom - 1,
                          ),
                          MapAnimationOptions(duration: 500),
                        );
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),

              ], // Children
              ), 
            ),
        
            const SizedBox(height: 12),
            if (errorMessage != null) 
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(errorMessage!, style: const TextStyle(color: Color(0xFFD32F2F)))),
                  ],
                ),
              ),
            const _Card(
              title: 'Harita Filtreleri',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(label: 'ATM'),
                  _FilterChip(label: 'Şube'),
                  _FilterChip(label: '24 Saat'),
                  _FilterChip(label: 'Yatırım Merkezi'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              title: 'Yakındaki Noktalar',
              child: errorMessage != null ?
              Text('Konum alınamadığı için yakın noktalar gösterilemiyor.', style:TextStyle(color: Color(0xFFD32F2F)))
              : isLoadingLocation ? const Text('Konum alınıyor...') 
              : nearbyATMs.isEmpty ? const Text('Yakında ATM bulunamadı.') 
              : Column(
                children: nearbyATMs.asMap().entries.map((entry) {
                  final atm = entry.value;

                  return _LocationRow(
                    title: atm["name"],
                    distance: atm["distance"] < 1000
                        ? "${atm["distance"].toStringAsFixed(0)} m"
                        : "${(atm["distance"] / 1000).toStringAsFixed(1)} km",
                    onTap: () {
                      mapboxMap?.flyTo(
                        CameraOptions(
                          center: Point(
                            coordinates: Position(
                              atm["lng"],
                              atm["lat"],
                            ),
                          ),
                          zoom: 15.0,
                        ),
                        MapAnimationOptions(duration: 1000),
                      );
                      // Handle ATM tap event
                    },
                  );
                }).toList(),
              ),
            ),

                
             
            const SizedBox(height: 12),
            const _Card(
              title: 'Rota Önerisi',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.route_outlined),
                title: Text('En kısa rota ile 7 dk'),
                subtitle: Text('Yoğunluk düşük, yürüyerek önerilir.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: const BorderSide(color: Colors.black12),
      backgroundColor: const Color(0xFFF1F1F1),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.title, required this.distance, required this.onTap});
  final String title;
  final String distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFF1F1F1),
        child: Icon(Icons.place_outlined, color: Colors.black),
      ),
      title: Text(title),
      trailing: Text(distance, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
