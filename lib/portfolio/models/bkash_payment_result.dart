/// Result of initiating a bKash payment (success or failure).
class BkashPaymentResult {
  final bool success;
  final String? trxId;
  final String? paymentId;
  final String? customerMsisdn;
  final String? errorMessage;

  const BkashPaymentResult({
    required this.success,
    this.trxId,
    this.paymentId,
    this.customerMsisdn,
    this.errorMessage,
  });

  factory BkashPaymentResult.success({
    required String trxId,
    String? paymentId,
    String? customerMsisdn,
  }) =>
      BkashPaymentResult(
        success: true,
        trxId: trxId,
        paymentId: paymentId,
        customerMsisdn: customerMsisdn,
      );

  factory BkashPaymentResult.failure(String message) =>
      BkashPaymentResult(success: false, errorMessage: message);
}
