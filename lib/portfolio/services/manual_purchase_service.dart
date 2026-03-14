import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/portfolio_app.dart';
import '../models/purchase_record.dart';

const String _collection = 'purchases';
const String _verifiedPrefix = 'verified_purchase_';
const String _claimPrefix = 'verified_claim_';

/// Manual bKash/bank flow: user pays, submits transaction ID, you verify in Firestore,
/// then one client can claim and download (one-user-one-APK anti-scam).
///
/// **Seller:** After confirming payment, set the purchase document's `status` to
/// `'verified'` in Firestore (and optionally `verifiedAt`: Timestamp). The first
/// device to "Check status" after that will receive a claim token; only that device
/// can download the APK (claim token is stored in browser/localStorage).
class ManualPurchaseService {
  ManualPurchaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _random = Random.secure();

  static String _generateClaimToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(32, (_) => chars[Random().nextInt(chars.length)]).join();
  }

  /// Submit a pending purchase (user entered transaction ID after paying).
  /// Creates/updates the purchase document in Firestore with [transactionId].
  /// [paymentMethod] is 'bkash' or 'bank'.
  Future<void> submitPending({
    required String transactionId,
    required PortfolioApp app,
    String? email,
    String paymentMethod = 'bkash',
  }) async {
    await _firestore.collection(_collection).doc(transactionId).set({
      'transactionId': transactionId,
      'appId': app.id,
      'appName': app.title,
      'amountBdt': app.priceBdt,
      'status': 'pending',
      'paymentMethod': paymentMethod,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check status and claim download for this purchase.
  /// Pass [storedClaimToken] if this device already claimed (so we allow re-download).
  /// Returns [PurchaseCheckResult]: only when [status] is [PurchaseCheckStatus.verified]
  /// and [claimToken] is returned can this client download (one-user-one-APK).
  Future<PurchaseCheckResult> checkStatus({
    required String transactionId,
    required String appId,
    String? storedClaimToken,
  }) async {
    final docRef = _firestore.collection(_collection).doc(transactionId);
    final doc = await docRef.get();
    if (!doc.exists) {
      return const PurchaseCheckResult(status: PurchaseCheckStatus.notFound);
    }
    final record = PurchaseRecord.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
    if (record.appId != appId) {
      return const PurchaseCheckResult(status: PurchaseCheckStatus.notFound);
    }
    switch (record.status) {
      case 'pending':
        return const PurchaseCheckResult(status: PurchaseCheckStatus.pending);
      case 'rejected':
        return const PurchaseCheckResult(status: PurchaseCheckStatus.rejected);
      case 'verified':
        break;
      default:
        return const PurchaseCheckResult(status: PurchaseCheckStatus.notFound);
    }

    // Verified: enforce one claim per purchase.
    if (record.claimToken != null && record.claimToken!.isNotEmpty) {
      if (storedClaimToken == record.claimToken) {
        return PurchaseCheckResult(
          status: PurchaseCheckStatus.verified,
          claimToken: record.claimToken,
        );
      }
      return const PurchaseCheckResult(status: PurchaseCheckStatus.claimedByOther);
    }

    // First claim: set claimToken in Firestore (transaction so only one client wins).
    final newToken = _generateClaimToken();
    await _firestore.runTransaction((tx) async {
      final fresh = await tx.get(docRef);
      final data = fresh.data();
      if (data == null || (data['claimToken'] as String?) != null) return;
      tx.update(docRef, {'claimToken': newToken});
    });

    // Re-read: if our token is stored, we won; otherwise another client claimed.
    final again = await docRef.get();
    final againRecord = PurchaseRecord.fromFirestore(
      again as DocumentSnapshot<Map<String, dynamic>>,
    );
    if (againRecord.claimToken == newToken) {
      return PurchaseCheckResult(status: PurchaseCheckStatus.verified, claimToken: newToken);
    }
    return const PurchaseCheckResult(status: PurchaseCheckStatus.claimedByOther);
  }

  /// Mark this app as unlocked locally and store [claimToken] (web-safe: SharedPreferences/localStorage).
  /// Only this client can download; sharing transaction ID won't allow others to get the APK.
  Future<void> saveVerifiedLocally({
    required String appId,
    required String transactionId,
    required String? claimToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_verifiedPrefix$appId', transactionId);
    if (claimToken != null) {
      await prefs.setString('$_claimPrefix$appId', claimToken);
    }
  }

  /// Stored claim token for [appId] (this device/browser). Used when re-checking status.
  Future<String?> getStoredClaimToken(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_claimPrefix$appId');
  }

  /// Whether the user has a verified purchase for this app (from local cache).
  Future<bool> isAppUnlocked(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_verifiedPrefix$appId');
  }

  /// Clear local unlock and claim token (e.g. for testing).
  Future<void> clearLocalUnlock(String appId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_verifiedPrefix$appId');
    await prefs.remove('$_claimPrefix$appId');
  }
}
