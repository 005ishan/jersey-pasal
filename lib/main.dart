import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/app/theme/JerseyApp.dart';
import 'package:jerseypasal/core/services/hive/hive_service.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  //shared preference ko object
  //shared pref = async
  //provider = sync

  //Shared prefs
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: JerseyApp(),
    ),
  );
}
