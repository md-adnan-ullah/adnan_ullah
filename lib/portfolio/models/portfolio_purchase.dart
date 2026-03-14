class PortfolioPurchase {
  final String id;
  final String appId;
  final String email;
  final String? userId;
  final String paymentMethod; // e.g. 'bkash'
  final String transactionId;
  final int amountBdt;
  final DateTime purchasedAt;
  final String? downloadUrl;
  final DateTime? downloadExpiresAt;
  final String? deviceId;

  const PortfolioPurchase({
    required this.id,
    required this.appId,
    required this.email,
    this.userId,
    required this.paymentMethod,
    required this.transactionId,
    required this.amountBdt,
    required this.purchasedAt,
    this.downloadUrl,
    this.downloadExpiresAt,
    this.deviceId,
  });

  bool get canDownload =>
      downloadUrl != null &&
      (downloadExpiresAt == null || downloadExpiresAt!.isAfter(DateTime.now()));

  factory PortfolioPurchase.fromMap(String id, Map<String, dynamic> map) {
    return PortfolioPurchase(
      id: id,
      appId: map['appId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      userId: map['userId'] as String?,
      paymentMethod: map['paymentMethod'] as String? ?? 'bkash',
      transactionId: map['transactionId'] as String? ?? '',
      amountBdt: (map['amountBdt'] as num?)?.toInt() ?? 0,
      purchasedAt: map['purchasedAt'] != null
          ? DateTime.tryParse(map['purchasedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      downloadUrl: map['downloadUrl'] as String?,
      downloadExpiresAt: map['downloadExpiresAt'] != null
          ? DateTime.tryParse(map['downloadExpiresAt'].toString())
          : null,
      deviceId: map['deviceId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appId': appId,
      'email': email,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'amountBdt': amountBdt,
      'purchasedAt': purchasedAt.toIso8601String(),
      'downloadUrl': downloadUrl,
      'downloadExpiresAt': downloadExpiresAt?.toIso8601String(),
      'deviceId': deviceId,
    };
  }
}

