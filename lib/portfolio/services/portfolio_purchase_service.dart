import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/bkash_payment_result.dart';
import '../models/portfolio_app.dart';
import '../models/portfolio_purchase.dart';
import 'package:bkash/bkash.dart';

/// Handles the business logic around purchasing apps.
///
/// Uses bKash payment gateway (sandbox by default). For production,
/// provide [BkashCredentials] when creating [Bkash] (e.g. from env).
class PortfolioPurchaseService {
  const PortfolioPurchaseService();

  static Bkash? _bkash;
  static Bkash get _gateway => _bkash ??= Bkash(logResponse: true);

  /// Simple bKash pay: open WebView → user pays → return result.
  Future<BkashPaymentResult> pay({
    required BuildContext context,
    required PortfolioApp app,
  }) async {
    try {
      final invoice = 'inv_${app.id}_${DateTime.now().millisecondsSinceEpoch}';
      final res = await _gateway.pay(
        context: context,
        amount: app.priceBdt.toDouble(),
        merchantInvoiceNumber: invoice,
      );
      return BkashPaymentResult.success(
        trxId: res.trxId,
        paymentId: res.paymentId,
        customerMsisdn: res.customerMsisdn,
      );
    } on BkashFailure catch (e) {
      final msg = e.message;
      final actual = e.error?.toString() ?? '';
      final display = _pickMessage(msg, actual);
      if (kDebugMode) {
        debugPrint('BkashFailure: message=$msg, error=$actual');
      }
      return BkashPaymentResult.failure(display);
    } catch (e, st) {
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      if (kDebugMode) {
        debugPrint('Bkash error: $e');
        debugPrint(st.toString());
      }
      return BkashPaymentResult.failure(msg);
    }
  }

  static String _pickMessage(String message, String errorDetail) {
    if (message != 'Something went wrong' && message.isNotEmpty) {
      return errorDetail.isEmpty ? message : '$message — $errorDetail';
    }
    if (errorDetail.isNotEmpty) return errorDetail;
    return 'Something went wrong. Sandbox: use Android/iOS; get credentials from bKash if needed.';
  }

  /// Creates a local purchase record once payment is verified.
  ///
  /// In production, this would mirror the document stored in Firestore
  /// by your backend after verifying the bKash transaction.
  PortfolioPurchase createLocalPurchaseRecord({
    required PortfolioApp app,
    required String email,
    required String transactionId,
    String? userId,
    String paymentMethod = 'bkash',
    String? downloadUrl,
  }) {
    final now = DateTime.now();
    return PortfolioPurchase(
      id: 'local-$transactionId',
      appId: app.id,
      email: email,
      userId: userId,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      amountBdt: app.priceBdt,
      purchasedAt: now,
      downloadUrl: downloadUrl,
      downloadExpiresAt: now.add(const Duration(days: 7)),
      deviceId: null,
    );
  }
}
