import 'package:flutter/material.dart';
import 'package:gems_responsive/gems_responsive.dart';

import '../models/portfolio_app.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/product_buy_bar.dart';

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
          ProductBuyBar(app: app),
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

