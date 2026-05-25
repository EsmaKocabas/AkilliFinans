import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'design_preset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'services/session_service.dart';
import 'core/constants/app_messages.dart';
import 'core/utils/app_alerts.dart';

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
  bool isLoadingATMs = false;
  bool isLoadingNearbyATMs = false;
  bool hasShownGeofenceAlert = false;
  double? nearestDistance;

  List<Map<String, dynamic>> atmPoints = [];
  List<Map<String, dynamic>> nearbyATMs = [];

  int _kValue = 3;
  bool _isOptimizing = false;
  List<Map<String, dynamic>> _optimizedCenters = [];
  String _selectedFilter = 'ATM';

  Future<void> _fetchCandidates() async {
    if (!mounted) return;
    setState(() {
      isLoadingATMs = true;
      errorMessage = null;
    });
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/map/atms');
      final response = await http.get(url, headers: session.headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body['data'];

        final mapped = list.map((item) {
          final id = item['candidate_id'] as int? ?? 1;
          final tags = <String>['ATM'];
          if (id % 3 == 0) tags.add('24 Saat');
          if (id % 4 == 0) tags.add('Şube');
          if (id % 5 == 0) tags.add('Yatırım Merkezi');
          return {
            "name": item['location_name'] ?? 'Aday ATM',
            "lat": (item['latitude'] as num).toDouble(),
            "lng": (item['longitude'] as num).toDouble(),
            "tags": tags,
          };
        }).toList();

        if (mounted) {
          setState(() {
            atmPoints = mapped;
            isLoadingATMs = false;
          });
        }
          
        await _updateMapMarkers(_getFilteredCandidates());
        
         }else {
            if (mounted) {
          setState(() {
            errorMessage = AppMessages.atmLoadError;
            isLoadingATMs = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = AppMessages.atmLoadError;
          isLoadingATMs = false;
        });
      }  
      AppAlerts.showSnackbar(context, AppMessages.atmLoadError);
      
      
    }

  }

  Future<void> _fetchNearbyATMs(double lat, double lng) async {
    if (!mounted) return;
    setState(() {
      isLoadingNearbyATMs = true;
    });
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/map/nearby?lat=$lat&lng=$lng');
      final response = await http.get(url, headers: session.headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> list = body['data'];

        if (!mounted) return;
        setState(() {
          nearbyATMs = list.map((item) {
            final id = item['candidate_id'] as int? ?? 1;
            final tags = <String>['ATM'];
            if (id % 3 == 0) tags.add('24 Saat');
            if (id % 4 == 0) tags.add('Şube');
            if (id % 5 == 0) tags.add('Yatırım Merkezi');
            return {
              "name": item['location_name'] ?? 'Bilinmeyen ATM',
              "lat": (item['latitude'] as num).toDouble(),
              "lng": (item['longitude'] as num).toDouble(),
              "distance": (item['distance'] as num).toDouble(),
              "tags": tags,
            };
          }).toList();
        });
        _checkNearbyATMAlert();
      } else {
        if (mounted) {
          AppAlerts.showSnackbar(context, AppMessages.atmLoadError);
        }
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showSnackbar(context, AppMessages.atmLoadError);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNearbyATMs = false;
        });
      }
    }
  }

  void _checkNearbyATMAlert() {
  if (hasShownGeofenceAlert || currentPosition == null) return;

  for (final atm in atmPoints) {
    final distance = geo.Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      atm["lat"],
      atm["lng"],
    );
      if (nearestDistance == null || distance < nearestDistance!) {
        nearestDistance = distance;
      }
    if (distance < 1000) {
      hasShownGeofenceAlert = true;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Yakındaki ATM'),
          content: Text(
            '${atm["name"]} konumuna yaklaştınız.\nYaklaşık mesafe: ${distance.toStringAsFixed(0)} m',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
      break;
    }
  }
  }

  Future<void> _updateMapMarkers(List<Map<String, dynamic>> points, {bool isOptimized = false}) async {
    try {
    if (mapboxMap == null || pointAnnotationManager == null) return;
    
    await pointAnnotationManager!.deleteAll();

    final ByteData bytes = await rootBundle.load('assets/icons/atm_marker.png');
    final Uint8List imageData = bytes.buffer.asUint8List();

    for (final pt in points) {
      await pointAnnotationManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              pt["lng"],
              pt["lat"],
            ),
          ),
          image: imageData,
          iconSize: isOptimized ? 0.28 : 0.2,
        ),
      );
    }
    } catch (e) {
      AppAlerts.showSnackbar(context, AppMessages.atmLoadError);
    }
  }

  Future<void> _runOptimization() async {
    setState(() {
      _isOptimizing = true;
      errorMessage = null;
    });

    if (!mounted) return;
    final session = context.read<AppSession>();
    try {
      final url = Uri.parse('${AppSession.baseUrl}/api/map/optimize');
      final response = await http.post(
        url,
        headers: session.headers,
        body: jsonEncode({
          'kumeSayisi': _kValue,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          final List<dynamic> list = body['data'];
          final List<Map<String, dynamic>> mapped = list.map((item) {
            final coord = item['koordinat'];
            return {
              "name": item['atm_id'] ?? 'Yeni ATM',
              "lat": (coord['lat'] as num).toDouble(),
              "lng": (coord['lng'] as num).toDouble(),
              "cost": (item['maliyet'] as num).toDouble(),
            };
          }).toList();

          if (mounted) {
            setState(() {
              _optimizedCenters = mapped;
              _isOptimizing = false;
            });

            await _updateMapMarkers(
              mapped.map((e) => {"lat": e["lat"], "lng": e["lng"]}).toList(),
              isOptimized: true,
            );

            if (mapped.isNotEmpty && mapboxMap != null) {
              mapboxMap!.flyTo(
                CameraOptions(
                  center: Point(
                    coordinates: Position(
                      mapped[0]["lng"],
                      mapped[0]["lat"],
                    ),
                  ),
                  zoom: 12.0,
                ),
                MapAnimationOptions(duration: 1000),
              );
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('K-Means tabanlı en verimli ATM lokasyonları hesaplandı!')),
            );
          }
        } else {
          setState(() {
            _isOptimizing = false;
            errorMessage = body['message'] ?? 'Optimizasyon başarısız.';
          });
        }
      } else {
        setState(() {
          _isOptimizing = false;
          errorMessage = 'Sunucu optimizasyon hatası (Kod: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isOptimizing = false;
        errorMessage = 'Bağlantı hatası: $e';
      });
    }
  }

  Future<void> _resetOptimization() async {
    setState(() {
      _optimizedCenters = [];
    });
    await _fetchCandidates();
  }

  List<Map<String, dynamic>> _getFilteredCandidates() {
    return atmPoints.where((pt) {
      final List<String> tags = List<String>.from(pt["tags"] ?? ['ATM']);
      return tags.contains(_selectedFilter);
    }).toList();
  }

  void _onFilterChanged(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
      _optimizedCenters = [];
    });
    _updateMapMarkers(_getFilteredCandidates());
  }

  void _showATMBottomSheet(Map<String, dynamic> atm) {

    final distance = atm["distance"] as double?;
    final walkingMinutes = distance != null
    ? (distance / 80).ceil()
    : null;

    showModalBottomSheet(
      context: context,
      shape : const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                atm['name'] ?? 'ATM Noktası',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
              ),
          
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Color(0xFF616161), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    atm["distance"] != null
                        ? "Mesafe: ${atm["distance"].toStringAsFixed(0)} m"
                        : 'Konum bilgisi mevcut',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.access_time),
                  SizedBox(width: 8),
                  Text('24 saat açık'),
                ],
              ),
              const SizedBox(height: 16),
              if (walkingMinutes != null) ...[
              const SizedBox(height: 12),
               Row(
                children: [
                  const Icon(Icons.directions_walk_outlined),
                  const SizedBox(width: 8),
                  Text("Yaklaşık $walkingMinutes dk yürüme mesafesi"),
             ],
            ),
          ],
            ],
          ),
        );
      },
    );
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
      if (mounted) {
        setState(() {
          currentPosition = position;
          isLoadingLocation = false;
        });
      }
      await _fetchNearbyATMs(position.latitude, position.longitude);
      _checkNearbyATMAlert();
      
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
          zoom: 13.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      setState(() {
        errorMessage = AppMessages.locationError;
        isLoadingLocation = false;
      });
    }
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
            const Text('ATM ve şube konumları.', style: TextStyle(color: Color(0xFF616161))),
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
                        coordinates: Position(
                          27.143345291811872,
                          38.35026165294819,
                        ),
                      ),
                      zoom: 11.0,
                    ),
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapCreated: (MapboxMap map) async {
                      try { 
                      mapboxMap = map;
                      pointAnnotationManager =
                          await map.annotations.createPointAnnotationManager();

                      await _fetchCandidates();
                      await getUserLocation();
                      } catch (e) {
                        AppAlerts.showSnackbar(context, AppMessages.mapLoadError);
                      }
                    },
                  ),
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
                              CameraOptions(zoom: zoom.zoom + 1),
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
                              CameraOptions(zoom: zoom.zoom - 1),
                              MapAnimationOptions(duration: 500),
                            );
                          },
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (isLoadingATMs) 
              const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('ATM verileri yükleniyor...', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
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
            const SizedBox(height: 12),
            _Card(
              title: 'ATM Optimizasyonu (K-Means)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Python veri analitiği servisini kullanarak bölgedeki işlem hacmine göre en ideal yeni ATM yerlerini bulun.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Küme Sayısı (k): $_kValue', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _kValue.toDouble(),
                          min: 2,
                          max: 10,
                          divisions: 8,
                          label: _kValue.toString(),
                          activeColor: Colors.black,
                          onChanged: (val) {
                            setState(() {
                              _kValue = val.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isOptimizing ? null : _runOptimization,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: _isOptimizing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.psychology_outlined),
                          label: const Text('Optimizasyonu Çalıştır'),
                        ),
                      ),
                      if (_optimizedCenters.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetOptimization,
                          icon: const Icon(Icons.refresh_outlined),
                          tooltip: 'Sıfırla',
                        )
                      ]
                    ],
                  ),
                  if (_optimizedCenters.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Belirlenen Lokasyonlar:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._optimizedCenters.map((center) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(center["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Koordinat: ${center["lat"]}, ${center["lng"]}'),
                        ],
                      ),
                    )),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              title: 'Harita Filtreleri',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChip(
                    label: 'ATM',
                    isSelected: _selectedFilter == 'ATM',
                    onTap: () => _onFilterChanged('ATM'),
                  ),
                  _FilterChip(
                    label: 'Şube',
                    isSelected: _selectedFilter == 'Şube',
                    onTap: () => _onFilterChanged('Şube'),
                  ),
                  _FilterChip(
                    label: '24 Saat',
                    isSelected: _selectedFilter == '24 Saat',
                    onTap: () => _onFilterChanged('24 Saat'),
                  ),
                  _FilterChip(
                    label: 'Yatırım Merkezi',
                    isSelected: _selectedFilter == 'Yatırım Merkezi',
                    onTap: () => _onFilterChanged('Yatırım Merkezi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Card(
              title: 'Yakındaki ATM Noktaları',
              child: errorMessage != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Konum alınamadığı için yakın noktalar gösterilemiyor.',
                          style: TextStyle(color: Color(0xFFD32F2F)),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: getUserLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Konumu Tekrar Dene'),
                        ),
                      ],
                    )
                  : isLoadingLocation || isLoadingNearbyATMs
                      ? const Row(
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Yakındaki ATM noktaları yükleniyor...', style: TextStyle(color: Colors.black87)),
                          ],
                        )
                      : nearbyATMs.isEmpty
                          ? const Text('Yakında ATM bulunamadı.')
                          : Builder(
                              builder: (context) {
                                final filteredNearby = nearbyATMs.where((atm) {
                                  final List<String> tags = List<String>.from(atm["tags"] ?? ['ATM']);
                                  return tags.contains(_selectedFilter);
                                }).toList();

                                if (filteredNearby.isEmpty) {
                                  return const Text('Yakında bu kriterlere uygun ATM bulunamadı.');
                                }

                                return Column(
                                  children: filteredNearby.map((atm) {
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
                                        _showATMBottomSheet(atm);
                                      },
                                    );
                                  }).toList(),
                                );
                              },
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
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black12,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
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
