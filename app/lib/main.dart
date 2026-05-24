import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'akilli_finans_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'services/session_service.dart';

/// App entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'];
  if (mapboxToken != null && mapboxToken.isNotEmpty) {
    mapbox.MapboxOptions.setAccessToken(mapboxToken);
  } else {
    mapbox.MapboxOptions.setAccessToken("pk.mock-token");
  }
  runApp(
    ChangeNotifierProvider<AppSession>.value(
      value: AppSession.instance,
      child: const AkilliFinansApp(),
    ),
  );
}
