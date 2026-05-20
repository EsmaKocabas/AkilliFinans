import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'design_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Location-focused responsive page.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.preset});

  final DesignPreset preset;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapboxMap mapboxMap;
  late PointAnnotationManager pointAnnotationManager;

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
                      await mapboxMap.annotations.createPointAnnotationManager();

                  for (final atm in atmPoints) {
                    await pointAnnotationManager.create(
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
                        final zoom =
                            await mapboxMap?.getCameraState();

                        mapboxMap?.flyTo(
                          CameraOptions(
                            zoom: zoom!.zoom + 1,
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
                        final zoom =
                            await mapboxMap?.getCameraState();

                        mapboxMap?.flyTo(
                          CameraOptions(
                            zoom: zoom!.zoom - 1,
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
              child: Column(
                children: atmPoints.asMap().entries.map((entry) {
                  final index = entry.key+1;
                  final atm = entry.value;

                  return _LocationRow(
                    title: atm["name"],
                    distance:  '${atm["lat"].toStringAsFixed(4)}, ${atm["lng"].toStringAsFixed(4)}',
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
  const _LocationRow({required this.title, required this.distance});
  final String title;
  final String distance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
