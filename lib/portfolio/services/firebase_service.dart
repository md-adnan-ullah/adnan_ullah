import 'package:firebase_core/firebase_core.dart';

/// Central Firebase initialization for the portfolio app.
///
/// This keeps your `main.dart` clean and makes it easy to switch
/// to `DefaultFirebaseOptions.currentPlatform` once you run
/// `flutterfire configure`.
class PortfolioFirebaseService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      // When you generate firebase_options.dart with FlutterFire CLI,
      // replace this with:
      //
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      await Firebase.initializeApp();
    } catch (_) {
      // Allow the app to run even if Firebase isn't configured yet.
    }
    _initialized = true;
  }
}

