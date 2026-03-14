import 'package:flutter/material.dart';
import 'package:gems_responsive/gems_responsive.dart';

import '../models/portfolio_app.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/glass_card.dart';
import '../services/portfolio_purchase_service.dart';

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
        title: const Text('App details'),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: PortfolioTheme.accentPrimary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.apps_rounded,
            color: PortfolioTheme.accentPrimary,
            size: 40,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                app.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: PortfolioTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                app.shortDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PortfolioTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: app.technologies
                    .map(
                      (t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PortfolioTheme.surface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: PortfolioTheme.textSecondary,
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App preview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PortfolioTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
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
              errorBuilder: (_, __, ___) => _DummyScreenContent(
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
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
          Text(
            'About this app',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PortfolioTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            app.longDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PortfolioTheme.textSecondary,
                  height: 1.6,
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
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PortfolioTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...app.features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: PortfolioTheme.accentPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PortfolioTheme.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Version ${app.version}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PortfolioTheme.textMuted,
              ),
        ),
        Text(
          '৳${app.priceBdt}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PortfolioTheme.accentPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

/// Static bottom bar so user doesn't need to scroll to tap Buy.
class _BuyBar extends StatelessWidget {
  final PortfolioApp app;

  const _BuyBar({required this.app});

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          isSmall ? 20 : 72,
          16,
          isSmall ? 20 : 72,
          16,
        ),
        decoration: BoxDecoration(
          color: PortfolioTheme.background,
          border: Border(
            top: BorderSide(color: PortfolioTheme.divider),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PortfolioTheme.bkash,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                final service = PortfolioPurchaseService();
                final result = await service.initiateBkashPayment(
                  app: app,
                  customerEmail: 'customer@example.com',
                  customerPhone: '+8801XXXXXXXXX',
                );
                if (!context.mounted) return;
                if (result == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'bKash integration coming soon. Please contact me to purchase this app.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Buy with bKash'),
            ),
            const SizedBox(height: 6),
            Text(
              'After payment you will receive a secure APK download link.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PortfolioTheme.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

