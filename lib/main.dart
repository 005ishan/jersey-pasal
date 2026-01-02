import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/theme/JerseyApp.dart';
import 'package:jerseypasal/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();
  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: JerseyApp(),
    ),
  );
}
