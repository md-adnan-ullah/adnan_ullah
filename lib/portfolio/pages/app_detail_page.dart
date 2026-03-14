import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gems_responsive/gems_responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/seller_config.dart';
import '../models/portfolio_app.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/glass_card.dart';
import '../services/manual_purchase_service.dart';

class AppDetailPage extends StatelessWidget {
  final PortfolioApp app;

  const AppDetailPage({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final horizontalPadding = isSmall ? 20.0 : 72.0;

    return Scaffold(
      backgroundColor: PortfolioTheme.background,
      appBar: AppBar(
        title: Text(
          app.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PortfolioTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        backgroundColor: PortfolioTheme.background,
        elevation: 0,
        scrolledUnderElevation: 2,
        iconTheme: const IconThemeData(color: PortfolioTheme.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScreenshotsCard(app: app),
                  const SizedBox(height: 32),
                  _Header(app: app),
                  const SizedBox(height: 32),
                  _DescriptionCard(app: app),
                  const SizedBox(height: 24),
                  _FeaturesCard(app: app),
                  const SizedBox(height: 24),
                  _VersionAndPrice(app: app),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _BuyBar(app: app),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PortfolioApp app;

  const _Header({required this.app});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PortfolioTheme.accentPrimary.withValues(alpha: 0.2),
                  PortfolioTheme.accentSecondary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: PortfolioTheme.accentPrimary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.apps_rounded,
              color: PortfolioTheme.accentPrimary,
              size: 44,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.platform,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: PortfolioTheme.accentPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  app.shortDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PortfolioTheme.textSecondary,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Top card with mobile screenshot mockups. Uses dummy screens when no URLs.
class _ScreenshotsCard extends StatelessWidget {
  final PortfolioApp app;

  const _ScreenshotsCard({required this.app});

  static const List<_DummyScreen> _dummyScreens = [
    _DummyScreen(title: 'Home', icon: Icons.home_rounded, color: Color(0xFF5B2C3B)),
    _DummyScreen(title: 'List', icon: Icons.list_rounded, color: Color(0xFF4A6FA5)),
    _DummyScreen(title: 'Detail', icon: Icons.description_rounded, color: Color(0xFF2D6A4F)),
    _DummyScreen(title: 'Settings', icon: Icons.settings_rounded, color: Color(0xFF6C757D)),
  ];

  @override
  Widget build(BuildContext context) {
    final urls = app.screenshotUrls.isNotEmpty
        ? app.screenshotUrls
        : null; // use dummies when null

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: PortfolioTheme.accentPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'APP PREVIEW',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: PortfolioTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 380,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPhoneFrames(context, urls),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPhoneFrames(BuildContext context, List<String>? urls) {
    const spacing = 20.0;
    if (urls != null && urls.isNotEmpty) {
      return [
        for (int i = 0; i < urls.length; i++) ...[
          if (i > 0) const SizedBox(width: spacing),
          _PhoneFrame(
            child: Image.network(
              urls[i],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _DummyScreenContent( // ignore: unnecessary_underscores
                screen: _dummyScreens[i % _dummyScreens.length],
              ),
            ),
          ),
        ],
      ];
    }
    return [
      for (int i = 0; i < _dummyScreens.length; i++) ...[
        if (i > 0) const SizedBox(width: spacing),
        _PhoneFrame(
          child: _DummyScreenContent(screen: _dummyScreens[i]),
        ),
      ],
    ];
  }
}

class _DummyScreen {
  final String title;
  final IconData icon;
  final Color color;
  const _DummyScreen({
    required this.title,
    required this.icon,
    required this.color,
  });
}

class _DummyScreenContent extends StatelessWidget {
  final _DummyScreen screen;

  const _DummyScreenContent({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: screen.color.withValues(alpha: 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(screen.icon, size: 48, color: screen.color),
          const SizedBox(height: 12),
          Text(
            screen.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: screen.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final Widget child;

  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 180,
        height: 360,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: PortfolioTheme.accentPrimary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: child,
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final PortfolioApp app;

  const _DescriptionCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 22, color: PortfolioTheme.accentPrimary),
              const SizedBox(width: 10),
              Text(
                'About this app',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PortfolioTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            app.longDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PortfolioTheme.textSecondary,
                  height: 1.65,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesCard extends StatelessWidget {
  final PortfolioApp app;

  const _FeaturesCard({required this.app});

  @override
  Widget build(BuildContext context) {
    if (app.features.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, size: 22, color: PortfolioTheme.accentPrimary),
              const SizedBox(width: 10),
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PortfolioTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...app.features.asMap().entries.map(
            (e) {
              final index = e.key;
              final f = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? PortfolioTheme.accentPrimary.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: index.isOdd
                      ? Border.all(color: PortfolioTheme.border.withValues(alpha: 0.8))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: PortfolioTheme.accentPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PortfolioTheme.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VersionAndPrice extends StatelessWidget {
  final PortfolioApp app;

  const _VersionAndPrice({required this.app});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: PortfolioTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                'Version ${app.version}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PortfolioTheme.textMuted,
                    ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PortfolioTheme.accentPrimary.withValues(alpha: 0.35)),
            ),
            child: Text(
              '৳${app.priceBdt}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: PortfolioTheme.accentPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom bar: Buy now (bKash/Bank) or Download APK when verified.
class _BuyBar extends StatefulWidget {
  final PortfolioApp app;

  const _BuyBar({required this.app});

  @override
  State<_BuyBar> createState() => _BuyBarState();
}

class _BuyBarState extends State<_BuyBar> {
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
      builder: (ctx) => _ManualPayDialog(
        app: widget.app,
        onSubmitted: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _onVerifyPressed(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => _VerifyPurchaseDialog(
        app: widget.app,
        purchaseService: _purchaseService,
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
          const SnackBar(content: Text('Download link not configured for this app')),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download link not set. Contact the developer.')),
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
                        Text('Download the APK below', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PortfolioTheme.textMuted)),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _onDownloadPressed(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Download APK'),
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
                              'Secure APK after payment',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PortfolioTheme.textMuted),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              onPressed: () => _onVerifyPressed(context),
                              child: Text('Already paid? Enter transaction ID', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PortfolioTheme.accentPrimary, decoration: TextDecoration.underline)),
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

/// Dialog: show bKash number, user enters transaction ID and submits.
class _ManualPayDialog extends StatefulWidget {
  final PortfolioApp app;
  final VoidCallback onSubmitted;

  const _ManualPayDialog({required this.app, required this.onSubmitted});

  @override
  State<_ManualPayDialog> createState() => _ManualPayDialogState();
}

class _ManualPayDialogState extends State<_ManualPayDialog> {
  final _trxController = TextEditingController();
  final _emailController = TextEditingController();
  final _purchaseService = ManualPurchaseService();
  bool _submitting = false;
  String? _error;
  bool _isBank = false; // false = bKash, true = Bank

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
      );
      if (!mounted) return;
      widget.onSubmitted();
      Navigator.of(context).pop();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Submitted'),
          content: const Text(
            "We'll verify your payment and unlock your download soon. "
            "You can check status anytime using 'Already paid? Enter transaction ID' on this app.",
          ),
          actions: [FilledButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ),
      );
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _submitting = false; });
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
            // Option: bKash or Bank
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
            // Upper: instruction + bKash number OR bank details
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
            // Amount (bold and prominent)
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

/// Dialog: user enters transaction ID to check status; if verified, unlock and show download.
class _VerifyPurchaseDialog extends StatefulWidget {
  final PortfolioApp app;
  final ManualPurchaseService purchaseService;
  final VoidCallback onVerified;

  const _VerifyPurchaseDialog({required this.app, required this.purchaseService, required this.onVerified});

  @override
  State<_VerifyPurchaseDialog> createState() => _VerifyPurchaseDialogState();
}

class _VerifyPurchaseDialogState extends State<_VerifyPurchaseDialog> {
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
      final status = await widget.purchaseService.checkStatus(transactionId: trx, appId: widget.app.id);
      if (!mounted) return;
      if (status == 'verified') {
        await widget.purchaseService.saveVerifiedLocally(appId: widget.app.id, transactionId: trx);
        setState(() { _message = null; _verified = true; _checking = false; });
        widget.onVerified();
      } else if (status == 'pending') {
        setState(() { _message = "We're still verifying your payment. Try again later."; _checking = false; });
      } else {
        setState(() { _message = 'Transaction ID not found or not for this app.'; _checking = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _message = e.toString(); _checking = false; });
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
            const Text('Enter your bKash transaction ID to check status and unlock download.'),
            const SizedBox(height: 16),
            TextField(
              controller: _trxController,
              decoration: const InputDecoration(labelText: 'Transaction ID'),
              textCapitalization: TextCapitalization.none,
              onChanged: (_) => setState(() => _message = null),
            ),
            if (_message != null) ...[const SizedBox(height: 12), Text(_message!, style: TextStyle(color: _verified ? Colors.green : Theme.of(context).colorScheme.error))],
            if (_verified) ...[const SizedBox(height: 12), const Text('Verified! You can download the APK from the bar below.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500))],
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

