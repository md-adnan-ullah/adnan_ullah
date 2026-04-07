import 'package:flutter/material.dart';
import 'package:gems_responsive/gems_responsive.dart';

import '../config/lightroom_preset_product.dart';
import '../models/portfolio_app.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/product_buy_bar.dart';
import '../widgets/section_header.dart';

/// Sell Lightroom preset packs with the same bKash/bank + Firestore flow as apps.
class LightroomPresetsPage extends StatelessWidget {
  const LightroomPresetsPage({
    super.key,
    this.product,
  });

  final PortfolioApp? product;

  @override
  Widget build(BuildContext context) {
    final selected = product ?? kLightroomPresetProducts.first;
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final pad = isSmall ? 20.0 : 72.0;

    return Scaffold(
      backgroundColor: PortfolioTheme.background,
      appBar: AppBar(
        title: Text(
          'Lightroom presets',
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
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: selected.iconUrl != null && selected.iconUrl!.isNotEmpty
                              ? Image.network(
                                  selected.iconUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _presetThumbPlaceholder(),
                                )
                              : _presetThumbPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: PortfolioTheme.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PortfolioTheme.accentPrimary.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                '৳${selected.priceBdt} BDT',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: PortfolioTheme.accentPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selected.platform,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: PortfolioTheme.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'About this pack',
                    subtitle: selected.shortDescription,
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Text(
                      selected.longDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PortfolioTheme.textSecondary,
                            height: 1.6,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: "What's included",
                    subtitle: 'One purchase — instant workflow upgrade.',
                  ),
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final f in selected.features) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 20, color: PortfolioTheme.accentPrimary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: PortfolioTheme.textSecondary,
                                        height: 1.45,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected.technologies
                        .map(
                          (t) => Chip(
                            label: Text(
                              t,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: PortfolioTheme.accentPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            backgroundColor: PortfolioTheme.accentPrimary.withValues(alpha: 0.1),
                            side: BorderSide(color: PortfolioTheme.accentPrimary.withValues(alpha: 0.28)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          ProductBuyBar(
            app: selected,
            paymentHint: 'Secure preset pack (.zip) after payment',
            purchasedSubtitle: 'Download your Lightroom preset pack below',
            downloadButtonLabel: 'Download presets',
            downloadMissingConfigMessage:
                'Preset download link is not configured. Contact the seller with your transaction ID.',
            downloadNotSetMessage:
                'Add your .zip URL to kLightroomPresetPack.apkPath in lightroom_preset_product.dart, or contact the seller.',
            verifyDialogIntro:
                'Enter your bKash or bank transaction ID to verify payment and unlock the preset download.',
            verifySuccessLine:
                'Verified! You can download the preset pack from the bar below.',
            verifyClaimedLine:
                'This purchase was already claimed on another device. Only that device can download the preset pack.',
            verifyNotFoundLine:
                'Transaction ID not found or not for this preset pack.',
            manualSubmitFollowUp:
                "You can check status anytime using 'Already paid? Enter transaction ID' on this page.",
          ),
        ],
      ),
    );
  }
}

Widget _presetThumbPlaceholder() {
  return Container(
    color: PortfolioTheme.accentPrimary.withValues(alpha: 0.14),
    child: const Center(
      child: Icon(Icons.tune_rounded, color: PortfolioTheme.accentPrimary, size: 36),
    ),
  );
}
