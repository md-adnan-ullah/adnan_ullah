import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document model for the `purchases` collection.
/// Created from the app when the user submits a purchase (transaction ID).
/// One document per transaction; one claim per document so only one user can download the APK.
class PurchaseRecord {
  final String transactionId;
  final String appId;
  final String appName;
  final int amountBdt;
  final String status; // 'pending' | 'verified' | 'rejected'
  final String paymentMethod; // 'bkash' | 'bank'
  final String? email;
  final DateTime? createdAt;
  final DateTime? verifiedAt;
  /// Set when the first client claims this purchase after verification.
  /// Only that client (with this token in local storage) can download the APK.
  final String? claimToken;

  const PurchaseRecord({
    required this.transactionId,
    required this.appId,
    required this.appName,
    required this.amountBdt,
    required this.status,
    required this.paymentMethod,
    this.email,
    this.createdAt,
    this.verifiedAt,
    this.claimToken,
  });

  factory PurchaseRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PurchaseRecord(
      transactionId: data['transactionId'] as String? ?? doc.id,
      appId: data['appId'] as String? ?? '',
      appName: data['appName'] as String? ?? '',
      amountBdt: (data['amountBdt'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'pending',
      paymentMethod: data['paymentMethod'] as String? ?? 'bkash',
      email: data['email'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
      claimToken: data['claimToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'appId': appId,
      'appName': appName,
      'amountBdt': amountBdt,
      'status': status,
      'paymentMethod': paymentMethod,
      if (email != null) 'email': email,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (verifiedAt != null) 'verifiedAt': Timestamp.fromDate(verifiedAt!),
      if (claimToken != null) 'claimToken': claimToken,
    };
  }

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isClaimed => claimToken != null && claimToken!.isNotEmpty;
}

/// Result of checking purchase status. Used for one-user-one-APK: only the
/// client that receives [claimToken] can download; others get [claimedByOther].
enum PurchaseCheckStatus {
  notFound,
  pending,
  rejected,
  verified,
  claimedByOther,
}

class PurchaseCheckResult {
  final PurchaseCheckStatus status;
  final String? claimToken;

  const PurchaseCheckResult({required this.status, this.claimToken});

  bool get canDownload => status == PurchaseCheckStatus.verified && claimToken != null;
}
