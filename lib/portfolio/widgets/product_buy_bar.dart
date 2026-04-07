import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gems_responsive/gems_responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/seller_config.dart';
import '../models/portfolio_app.dart';
import '../models/purchase_record.dart';
import '../services/manual_purchase_service.dart';
import '../utils/portfolio_theme.dart';

/// Bottom bar: manual pay (bKash/bank) or download when verified. Copy is customizable per product type.
class ProductBuyBar extends StatefulWidget {
  const ProductBuyBar({
    super.key,
    required this.app,
    this.paymentHint = 'Secure APK after payment',
    this.purchasedSubtitle = 'Download the APK below',
    this.downloadButtonLabel = 'Download APK',
    this.downloadMissingConfigMessage = 'Download link not configured for this app',
    this.downloadNotSetMessage = 'Download link not set. Contact the developer.',
    this.verifyDialogIntro =
        'Enter your bKash transaction ID to check status and unlock download.',
    this.verifySuccessLine =
        'Verified! You can download the APK from the bar below.',
    this.verifyClaimedLine =
        'This purchase was already claimed by another device. Only that device can download the APK.',
    this.verifyNotFoundLine =
        'Transaction ID not found or not for this app.',
    this.manualSubmitFollowUp =
        "You can check status anytime using 'Already paid? Enter transaction ID' on this app.",
  });

  final PortfolioApp app;
  final String paymentHint;
  final String purchasedSubtitle;
  final String downloadButtonLabel;
  final String downloadMissingConfigMessage;
  final String downloadNotSetMessage;
  final String verifyDialogIntro;
  final String verifySuccessLine;
  final String verifyClaimedLine;
  final String verifyNotFoundLine;
  final String manualSubmitFollowUp;

  @override
  State<ProductBuyBar> createState() => _ProductBuyBarState();
}

class _ProductBuyBarState extends State<ProductBuyBar> {
  final ManualPurchaseService _purchaseService = ManualPurchaseService();
  bool _isUnlocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkUnlocked();
  }

  Future<void> _checkUnlocked() async {
    final unlocked = await _purchaseService.isAppUnlocked(widget.app.id);
    if (mounted) setState(() { _isUnlocked = unlocked; _loading = false; });
  }

  Future<void> _onBuyPressed(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => ManualPayDialog(
        app: widget.app,
        submittedFollowUp: widget.manualSubmitFollowUp,
        onSubmitted: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _onVerifyPressed(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => VerifyPurchaseDialog(
        app: widget.app,
        purchaseService: _purchaseService,
        introLine: widget.verifyDialogIntro,
        successLine: widget.verifySuccessLine,
        claimedLine: widget.verifyClaimedLine,
        notFoundLine: widget.verifyNotFoundLine,
        onVerified: () {
          Navigator.of(ctx).pop();
          _checkUnlocked();
        },
      ),
    );
  }

  Future<void> _onDownloadPressed(BuildContext context) async {
    final url = widget.app.apkPath;
    if (url != null && url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.downloadMissingConfigMessage)),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.downloadNotSetMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final padding = EdgeInsets.fromLTRB(isSmall ? 20 : 72, 20, isSmall ? 20 : 72, 20);

    if (_loading) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(color: PortfolioTheme.surface.withValues(alpha: 0.95)),
          child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: PortfolioTheme.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(top: BorderSide(color: PortfolioTheme.divider)),
        ),
        child: _isUnlocked
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Purchased', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: PortfolioTheme.accentPrimary, fontWeight: FontWeight.w700)),
                        Text(widget.purchasedSubtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PortfolioTheme.textMuted)),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _onDownloadPressed(context),
                    icon: const Icon(Icons.download),
                    label: Text(widget.downloadButtonLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: PortfolioTheme.accentPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '৳${widget.app.priceBdt}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: PortfolioTheme.accentPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.paymentHint,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PortfolioTheme.textMuted),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _onVerifyPressed(context),
                              icon: const Icon(Icons.receipt_long_rounded, size: 20),
                              label: const Text('Already paid? Enter transaction ID'),
                              style: TextButton.styleFrom(
                                foregroundColor: PortfolioTheme.accentPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                minimumSize: const Size(0, 44),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PortfolioTheme.bkash,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _onBuyPressed(context),
                          child: const Text('Buy now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Manual pay dialog (bKash / bank + transaction ID).
class ManualPayDialog extends StatefulWidget {
  const ManualPayDialog({
    super.key,
    required this.app,
    required this.onSubmitted,
    this.submittedFollowUp =
        "You can check status anytime using 'Already paid? Enter transaction ID' on this app.",
  });

  final PortfolioApp app;
  final VoidCallback onSubmitted;
  final String submittedFollowUp;

  @override
  State<ManualPayDialog> createState() => _ManualPayDialogState();
}

class _ManualPayDialogState extends State<ManualPayDialog> {
  final _trxController = TextEditingController();
  final _emailController = TextEditingController();
  final _purchaseService = ManualPurchaseService();
  bool _submitting = false;
  String? _error;
  bool _isBank = false;

  @override
  void dispose() {
    _trxController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _bankRow(BuildContext context, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PortfolioTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PortfolioTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              style: IconButton.styleFrom(
                backgroundColor: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
                foregroundColor: PortfolioTheme.accentPrimary,
              ),
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied'), duration: Duration(seconds: 1)));
              },
              tooltip: 'Copy account number',
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final trx = _trxController.text.trim();
    if (trx.isEmpty) {
      setState(() => _error = 'Enter your transaction ID');
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      await _purchaseService.submitPending(
        transactionId: trx,
        app: widget.app,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        paymentMethod: _isBank ? 'bank' : 'bkash',
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      if (!mounted) return;
      widget.onSubmitted();
      Navigator.of(context).pop();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submitted'),
          content: Text(
            "We'll verify your payment and unlock your download soon. ${widget.submittedFollowUp}",
          ),
          actions: [FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
    } on TimeoutException {
      if (mounted) setState(() {
        _error = 'Request timed out. Check your internet connection and try again.';
        _submitting = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Could not submit. Check your connection and try again.';
        _submitting = false;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pay with bKash or Bank'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('bKash'), icon: Icon(Icons.phone_android)),
                      ButtonSegment(value: true, label: Text('Bank'), icon: Icon(Icons.account_balance)),
                    ],
                    selected: {_isBank},
                    onSelectionChanged: (Set<bool> s) => setState(() => _isBank = s.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (!_isBank) ...[
              Text(SellerConfig.bkashInstructionTop, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(SellerConfig.bkashNumber, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: SellerConfig.bkashNumber));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Number copied'), duration: Duration(seconds: 1)));
                    },
                    tooltip: 'Copy number',
                  ),
                ],
              ),
            ] else ...[
              Text(SellerConfig.bankInstructionTop, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PortfolioTheme.accentPrimary.withValues(alpha: 0.06),
                      PortfolioTheme.accentPrimary.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PortfolioTheme.accentPrimary.withValues(alpha: 0.25), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: PortfolioTheme.accentPrimary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_rounded, size: 20, color: PortfolioTheme.accentPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Bank account',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: PortfolioTheme.accentPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _bankRow(context, 'Bank', SellerConfig.bankName),
                    _bankRow(context, 'Account name', SellerConfig.accountName),
                    _bankRow(context, 'Account number', SellerConfig.accountNumber, copyable: true),
                    _bankRow(context, 'Branch', SellerConfig.branchName),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: PortfolioTheme.accentPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PortfolioTheme.accentPrimary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Text('Amount: ', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: PortfolioTheme.textSecondary, fontWeight: FontWeight.w600)),
                  Text('৳${widget.app.priceBdt} BDT', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: PortfolioTheme.accentPrimary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(_isBank ? SellerConfig.bankInstructionBelow : SellerConfig.bkashInstructionBelow, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: _trxController,
              decoration: const InputDecoration(labelText: 'Transaction ID', hintText: 'e.g. TRX123456'),
              textCapitalization: TextCapitalization.none,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (optional)', hintText: 'For download link'),
              keyboardType: TextInputType.emailAddress,
            ),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _submitting ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submitting ? null : _submit, child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit')),
      ],
    );
  }
}

class VerifyPurchaseDialog extends StatefulWidget {
  const VerifyPurchaseDialog({
    super.key,
    required this.app,
    required this.purchaseService,
    required this.onVerified,
    this.introLine =
        'Enter your bKash transaction ID to check status and unlock download.',
    this.successLine =
        'Verified! You can download the APK from the bar below.',
    this.claimedLine =
        'This purchase was already claimed by another device. Only that device can download the APK.',
    this.notFoundLine = 'Transaction ID not found or not for this app.',
  });

  final PortfolioApp app;
  final ManualPurchaseService purchaseService;
  final VoidCallback onVerified;
  final String introLine;
  final String successLine;
  final String claimedLine;
  final String notFoundLine;

  @override
  State<VerifyPurchaseDialog> createState() => _VerifyPurchaseDialogState();
}

class _VerifyPurchaseDialogState extends State<VerifyPurchaseDialog> {
  final _trxController = TextEditingController();
  bool _checking = false;
  String? _message;
  bool _verified = false;

  @override
  void dispose() {
    _trxController.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final trx = _trxController.text.trim();
    if (trx.isEmpty) {
      setState(() => _message = 'Enter transaction ID');
      return;
    }
    setState(() { _checking = true; _message = null; _verified = false; });
    try {
      final storedToken = await widget.purchaseService.getStoredClaimToken(widget.app.id);
      final result = await widget.purchaseService.checkStatus(
        transactionId: trx,
        appId: widget.app.id,
        storedClaimToken: storedToken,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );
      if (!mounted) return;
      switch (result.status) {
        case PurchaseCheckStatus.verified:
          await widget.purchaseService.saveVerifiedLocally(
            appId: widget.app.id,
            transactionId: trx,
            claimToken: result.claimToken,
          );
          setState(() { _message = null; _verified = true; _checking = false; });
          widget.onVerified();
          break;
        case PurchaseCheckStatus.pending:
          setState(() { _message = "We're still verifying your payment. Try again later."; _checking = false; });
          break;
        case PurchaseCheckStatus.claimedByOther:
          setState(() {
            _message = widget.claimedLine;
            _checking = false;
          });
          break;
        case PurchaseCheckStatus.rejected:
          setState(() { _message = 'This payment was rejected.'; _checking = false; });
          break;
        case PurchaseCheckStatus.notFound:
          setState(() { _message = widget.notFoundLine; _checking = false; });
          break;
      }
    } on TimeoutException {
      if (mounted) setState(() {
        _message = 'Request timed out. Check your internet connection and try again.';
        _checking = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _message = 'Could not check status. Check your connection and try again.';
        _checking = false;
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Already paid?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.introLine),
            const SizedBox(height: 16),
            TextField(
              controller: _trxController,
              decoration: const InputDecoration(labelText: 'Transaction ID'),
              textCapitalization: TextCapitalization.none,
              onChanged: (_) => setState(() => _message = null),
            ),
            if (_message != null) ...[const SizedBox(height: 12), Text(_message!, style: TextStyle(color: _verified ? Colors.green : Theme.of(context).colorScheme.error))],
            if (_verified) ...[const SizedBox(height: 12), Text(widget.successLine, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500))],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        if (!_verified) FilledButton(onPressed: _checking ? null : _check, child: _checking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Check status')),
      ],
    );
  }
}
