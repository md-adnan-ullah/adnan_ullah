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

    return Scaffold(
      backgroundColor: PortfolioTheme.background,
      appBar: AppBar(
        title: const Text('App details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 20 : 72,
          vertical: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(app: app),
            const SizedBox(height: 32),
            _ScreenshotsCarousel(app: app),
            const SizedBox(height: 32),
            _DescriptionCard(app: app),
            const SizedBox(height: 24),
            _FeaturesCard(app: app),
            const SizedBox(height: 24),
            _VersionAndPrice(app: app),
            const SizedBox(height: 32),
            _BuySection(app: app),
            const SizedBox(height: 48),
          ],
        ),
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
                          color: PortfolioTheme.glassBackground,
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

class _ScreenshotsCarousel extends StatelessWidget {
  final PortfolioApp app;

  const _ScreenshotsCarousel({required this.app});

  @override
  Widget build(BuildContext context) {
    final items = (app.screenshotUrls.isNotEmpty
            ? app.screenshotUrls
            : List<String>.filled(3, ''))
        .map(
      (url) {
        final child = Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: PortfolioTheme.card,
            border: Border.all(color: PortfolioTheme.glassBorder),
          ),
          child: url.isEmpty
              ? const Center(
                  child: Icon(
                    Icons.phone_android,
                    size: 64,
                    color: PortfolioTheme.textMuted,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),
                ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: child,
        );
      },
    ).toList();

    return ResponsiveCarousel(
      height: 320,
      autoPlay: items.length > 1,
      showArrows: true,
      showIndicators: true,
      indicatorColor: PortfolioTheme.textMuted,
      activeIndicatorColor: PortfolioTheme.accentPrimary,
      children: items,
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

class _BuySection extends StatelessWidget {
  final PortfolioApp app;

  const _BuySection({required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PortfolioTheme.bkash,
            foregroundColor: Colors.white,
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
        const SizedBox(height: 8),
        Text(
          'After a successful payment you will receive a secure APK download link.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PortfolioTheme.textMuted,
              ),
        ),
      ],
    );
  }
}

