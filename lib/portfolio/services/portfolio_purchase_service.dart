import '../models/portfolio_app.dart';
import '../models/portfolio_purchase.dart';

/// Handles the business logic around purchasing apps.
///
/// This is intentionally backend‑agnostic for now so it works
/// without Firebase. When you are ready, you can:
///   - Integrate bKash payment API or hosted checkout
///   - Verify payment in a Cloud Function / backend
///   - Store purchases in Firestore
///   - Generate secure, time‑limited download URLs
class PortfolioPurchaseService {
  const PortfolioPurchaseService();

  /// Entry point for starting a bKash payment.
  ///
  /// Returns a redirect URL or null if not implemented yet.
  Future<String?> initiateBkashPayment({
    required PortfolioApp app,
    required String customerEmail,
    required String customerPhone,
  }) async {
    // TODO: Implement real bKash integration.
    // For now, return null so the UI can show
    // "Contact me to purchase" or describe your manual flow.
    return null;
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

