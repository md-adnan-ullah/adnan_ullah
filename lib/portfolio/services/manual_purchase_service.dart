import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/portfolio_app.dart';

const String _collection = 'purchases';
const String _verifiedPrefix = 'verified_purchase_';

/// Manual bKash flow: user pays, submits transaction ID, you verify in Firestore, then they can download.
class ManualPurchaseService {
  ManualPurchaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Submit a pending purchase (user entered transaction ID after paying).
  Future<void> submitPending({
    required String transactionId,
    required PortfolioApp app,
    String? email,
  }) async {
    await _firestore.collection(_collection).doc(transactionId).set({
      'transactionId': transactionId,
      'appId': app.id,
      'appName': app.title,
      'amountBdt': app.priceBdt,
      'status': 'pending',
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check status of a purchase by transaction ID and app.
  /// Returns: 'pending' | 'verified' | null (not found).
  Future<String?> checkStatus({
    required String transactionId,
    required String appId,
  }) async {
    final doc = await _firestore.collection(_collection).doc(transactionId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null || data['appId'] != appId) return null;
    return data['status'] as String?;
  }

  /// Mark this app as unlocked locally after verification (so we show Download APK).
  Future<void> saveVerifiedLocally({
    required String appId,
    required String transactionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_verifiedPrefix$appId', transactionId);
  }

  /// Whether the user has a verified purchase for this app (from local cache).
  Future<bool> isAppUnlocked(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_verifiedPrefix$appId');
  }

  /// Clear local unlock (e.g. for testing).
  Future<void> clearLocalUnlock(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_verifiedPrefix$appId');
  }
}
