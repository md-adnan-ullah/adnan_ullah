import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Central Firebase initialization for the portfolio app.
class PortfolioFirebaseService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }
}

