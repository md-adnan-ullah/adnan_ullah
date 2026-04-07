import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gems_responsive/gems_responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/portfolio_app.dart';
import '../models/portfolio_project.dart';
import '../models/github_repo.dart';
import '../config/lightroom_preset_product.dart';
import '../services/portfolio_app_service.dart';
import '../services/github_service.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/animated_section.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skill_badge.dart';
import 'app_detail_page.dart';
import 'lightroom_presets_page.dart';
import 'purchase_admin_page.dart';

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final _scrollController = ScrollController();
  final _service = const PortfolioAppService();
  final _githubService = const GithubService();

  late Future<List<PortfolioApp>> _appsFuture;
  late Future<List<PortfolioProject>> _projectsFuture;
  late Future<List<GithubRepo>> _githubReposFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = _service.fetchApps();
    _projectsFuture = _service.fetchProjects();
    _githubReposFuture = _githubService.fetchPinnedRepos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTo(double offset) {
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    return Scaffold(
      backgroundColor: PortfolioTheme.background,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              _HeroSection(
                onViewApps: () => _scrollTo(600),
                onContact: () => _scrollTo(2000),
              ),
              AnimatedSection(
                child: _AboutSection(),
              ),
              AnimatedSection(
                child: const _SkillsSection(),
              ),
              AnimatedSection(
                child: FutureBuilder<List<PortfolioApp>>(
                  future: _appsFuture,
                  builder: (context, snapshot) {
                    final apps = snapshot.data ?? [];
                    return _AppsSection(apps: apps);
                  },
                ),
              ),
              AnimatedSection(
                child: _PresetSection(presets: kLightroomPresetProducts),
              ),
              AnimatedSection(
                child: FutureBuilder<List<PortfolioProject>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    final projects = snapshot.data ?? [];
                    return _PortfolioSection(projects: projects);
                  },
                ),
              ),
              AnimatedSection(
                child: FutureBuilder<List<GithubRepo>>(
                  future: _githubReposFuture,
                  builder: (context, snapshot) {
                    final repos = snapshot.data ?? [];
                    if (repos.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return _GithubReposSection(repos: repos);
                  },
                ),
              ),
              AnimatedSection(
                child: const _ContactSection(),
              ),
              RepaintBoundary(
                child:               _Footer(
                onNavigateToApps: () => _scrollTo(900),
                onNavigateToPortfolio: () => _scrollTo(1400),
                onNavigateToPricing: () => _scrollTo(600),
                onNavigateToContact: () => _scrollTo(2200),
                onNavigateToPresets: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LightroomPresetsPage(),
                    ),
                  );
                },
                onAdminTap: () async {
                  final ok = await PurchaseAdminPage.checkCredentials(context);
                  if (ok && context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PurchaseAdminPage(),
                      ),
                    );
                  } else if (context.mounted && ok == false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid username or password')),
                    );
                  }
                },
                ),
              ),
              SizedBox(height: isSmall ? 32 : 48),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 16 : 32,
                vertical: 12,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: kIsWeb ? 8 : 20,
                        sigmaY: kIsWeb ? 8 : 20,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PortfolioTheme.surface.withOpacity(0.85),
                              PortfolioTheme.card.withOpacity(0.82),
                              PortfolioTheme.accentPrimary.withOpacity(0.08),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!isSmall)
                              Row(
                                children: [
                                  _NavLink(
                                      label: 'Work',
                                      onTap: () => _scrollTo(900)),
                                  _NavLink(
                                    label: 'Portfolio',
                                    onTap: () => _scrollTo(1400),
                                  ),
                                  _NavLink(
                                    label: 'Pricing',
                                    onTap: () => _scrollTo(600),
                                  ),
                                  _NavLink(
                                    label: 'Presets',
                                    onTap: () => _scrollTo(1250),
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                            GestureDetector(
                              onTap: () => _scrollTo(0),
                              child: Text(
                                'ADNAN ULLAH',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: PortfolioTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ),
                            if (!isSmall)
                              Row(
                                children: [
                                  _NavLink(
                                    label: 'Contact',
                                    onTap: () => _scrollTo(2200),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MENU',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color:
                                              PortfolioTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'MENU',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: PortfolioTheme.textPrimary,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _hovered
                  ? PortfolioTheme.accentPrimary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _hovered
                        ? PortfolioTheme.accentPrimary
                        : PortfolioTheme.textPrimary,
                    fontWeight: _hovered ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onViewApps;
  final VoidCallback onContact;

  const _HeroSection({
    required this.onViewApps,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final bannerHeight = isSmall ? 340.0 : 420.0;
    // Half of the card height: 50% inside banner, 50% below
    final halfCardHeight = isSmall ? 110.0 : 140.0;
    final totalHeroHeight = bannerHeight + halfCardHeight;

    return SizedBox(
      height: totalHeroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image banner (top portion only)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.25),
                BlendMode.darken,
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-Wyc7vHXfCDQ'
                '?auto=format&fit=crop&w=1600&q=85',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(
                  'https://images.unsplash.com/photo-1600610429853-81d08d9ae4b1'
                  '?auto=format&fit=crop&w=1600&q=85',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Subtle gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bannerHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    PortfolioTheme.background.withOpacity(0.2),
                    PortfolioTheme.background.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Card: 50% inside banner, 50% below (positioned at bottom of banner)
          Positioned(
            top: bannerHeight - halfCardHeight,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 24 : 72,
                ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: kIsWeb ? 10 : 24,
                    sigmaY: kIsWeb ? 10 : 24,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 900),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 20 : 36,
                      vertical: isSmall ? 22 : 32,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.22),
                          Colors.white.withOpacity(0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MOBILE APP DESIGN & DEVELOPMENT',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                        )
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .moveX(begin: -16, end: 0),
                        const SizedBox(height: 12),
                        Text(
                          'NEW TRANSFORMING APP EXPERIENCES',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                fontSize: 28,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: PortfolioTheme.accentPrimary
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                        )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 450.ms)
                            .moveY(begin: 18, end: 0),
                        const SizedBox(height: 16),
                        Text(
                          'From concept to deployment, I create polished Flutter and Android apps '
                          'with clear UX, strong architecture, and production‑ready animations.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                height: 1.6,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                        )
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 450.ms)
                            .moveY(begin: 12, end: 0),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: onViewApps,
                              child: Text(
                                'EXPLORE MY APPS',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black
                                              .withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    delay: 320.ms, duration: 400.ms)
                                .moveY(begin: 8, end: 0),
                            const SizedBox(width: 24),
                            ElevatedButton(
                              onPressed: onContact,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PortfolioTheme.accentPrimary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.35),
                              ),
                              child: const Text('START YOUR PROJECT'),
                            )
                                .animate()
                                .fadeIn(
                                    delay: 380.ms, duration: 400.ms)
                                .scale(
                                  begin: const Offset(0.98, 0.98),
                                  end: const Offset(1, 1),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    final aboutContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SectionHeader(
          title: 'About',
            subtitle:
                'Mobile developer focusing on Flutter and Android with a passion for\n'
                'clean UX and reliable, scalable apps.',
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Text(
              'Over the last few years I’ve been designing and building mobile apps —\n'
              'from small utility tools to complete product experiences. I enjoy\n'
              'turning product ideas into fast, beautiful apps using Flutter, Kotlin,\n'
              'and Firebase. My focus is on clear UX, performance, and maintainable\n'
              'architecture so apps can grow with your business.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PortfolioTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
          ),
        ],
    );

    const double bannerWidth = 180;
    const double bannerAspectRatio = 9 / 16;
    final banner = _AboutAdBanner(width: bannerWidth, aspectRatio: bannerAspectRatio);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      child: isSmall
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                aboutContent,
                const SizedBox(height: 32),
                Center(child: banner),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: aboutContent),
                const SizedBox(width: 32),
                banner,
              ],
            ),
    );
  }
}

/// 9:16 portrait ad banner: "Develop your custom product" / "Share your idea".
class _AboutAdBanner extends StatelessWidget {
  const _AboutAdBanner({required this.width, required this.aspectRatio});

  final double width;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PortfolioTheme.accentPrimary,
                PortfolioTheme.accentSecondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Develop your\ncustom product',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your idea',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PortfolioTheme.accentPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Get started'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection();

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final skills = const [
      ('Flutter', Icons.flutter_dash),
      ('Android', Icons.android),
      ('Kotlin', Icons.code),
      ('Firebase', Icons.local_fire_department_outlined),
      ('REST API', Icons.api),
      ('UI/UX', Icons.design_services_outlined),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Skills',
            subtitle: 'Technologies I use to design, build, and ship apps.',
          ),
          const SizedBox(height: 20),
          Wrap(
            children: skills
                .map(
                  (s) => SkillBadge(
                    label: s.$1,
                    icon: s.$2,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AppsSection extends StatelessWidget {
  final List<PortfolioApp> apps;

  const _AppsSection({required this.apps});

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final width = ResponsiveHelper.getScreenWidth(context);
    final crossAxisCount = isSmall
        ? 1
        : width < 1000
            ? 2
            : 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Apps & Products',
            subtitle: 'Premium ready‑to‑ship apps that you can purchase and use.',
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.82,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _AppCard(app: app);
            },
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final PortfolioApp app;

  const _AppCard({required this.app});

  String? get _cardImageUrl {
    if (app.iconUrl != null && app.iconUrl!.isNotEmpty) return app.iconUrl;
    if (app.screenshotUrls.isNotEmpty) return app.screenshotUrls.first;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _cardImageUrl;

    return GlassCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AppDetailPage(app: app),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _appCardImagePlaceholder(context),
                    )
                  : _appCardImagePlaceholder(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PortfolioTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.shortDescription,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PortfolioTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        '৳${app.priceBdt}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      backgroundColor: PortfolioTheme.accentPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      'View →',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: PortfolioTheme.accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appCardImagePlaceholder(BuildContext context) {
    return Container(
      color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.apps_rounded, color: PortfolioTheme.accentPrimary, size: 48),
      ),
    );
  }
}

class _PresetSection extends StatelessWidget {
  const _PresetSection({required this.presets});

  final List<PortfolioApp> presets;

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final width = ResponsiveHelper.getScreenWidth(context);
    final crossAxisCount = isSmall
        ? 1
        : width < 1000
            ? 2
            : 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Lightroom Presets',
            subtitle: 'Preset packs for portrait, travel, and moody edits.',
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.9,
            ),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return GlassCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LightroomPresetsPage(product: preset),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: SizedBox.expand(
                          child: preset.iconUrl != null && preset.iconUrl!.isNotEmpty
                              ? Image.network(
                                  preset.iconUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _presetThumbPlaceholder(),
                                )
                              : _presetThumbPlaceholder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Text(
                        preset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: PortfolioTheme.textPrimary,
                              fontWeight: FontWeight.w700,
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

Widget _presetThumbPlaceholder() {
  return Container(
    color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
    child: const Center(
      child: Icon(Icons.tune_rounded, color: PortfolioTheme.accentPrimary, size: 42),
    ),
  );
}

class _PortfolioSection extends StatelessWidget {
  final List<PortfolioProject> projects;

  const _PortfolioSection({required this.projects});

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Portfolio',
            subtitle: 'A selection of client work and UI explorations.',
          ),
          const SizedBox(height: 24),
          Column(
            children: projects
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: isSmall
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _portfolioImagePlaceholderSmall(context),
                                          )
                                        : _portfolioImagePlaceholderSmall(context),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _portfolioCardContent(context, p),
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                  child: SizedBox(
                                    width: 160,
                                    height: 130,
                                    child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            p.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _portfolioImagePlaceholder(context),
                                          )
                                        : _portfolioImagePlaceholder(context),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                                    child: _portfolioCardContent(context, p),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _portfolioCardContent(BuildContext context, PortfolioProject p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          p.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PortfolioTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          p.role,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: PortfolioTheme.textMuted,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          p.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PortfolioTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: p.technologies
              .map(
                (t) => Chip(
                  label: Text(
                    t,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PortfolioTheme.accentPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  backgroundColor: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
                  side: BorderSide(
                    color: PortfolioTheme.accentPrimary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _portfolioImagePlaceholder(BuildContext context) {
    return Container(
      width: 160,
      color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(
          Icons.phone_android,
          color: PortfolioTheme.accentPrimary,
          size: 40,
        ),
      ),
    );
  }

  Widget _portfolioImagePlaceholderSmall(BuildContext context) {
    return Container(
      color: PortfolioTheme.accentPrimary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(
          Icons.phone_android,
          color: PortfolioTheme.accentPrimary,
          size: 40,
        ),
      ),
    );
  }
}

class _GithubReposSection extends StatelessWidget {
  final List<GithubRepo> repos;

  const _GithubReposSection({required this.repos});

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);
    final width = ResponsiveHelper.getScreenWidth(context);
    final crossAxisCount = isSmall
        ? 1
        : width < 1000
            ? 2
            : 3;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'GitHub Projects',
            subtitle:
                'Open‑source repositories that showcase how I write and structure code.',
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.1,
            ),
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return _GithubRepoCard(repo: repo);
            },
          ),
        ],
      ),
    );
  }
}

class _GithubRepoCard extends StatelessWidget {
  final GithubRepo repo;

  const _GithubRepoCard({required this.repo});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            repo.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PortfolioTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            repo.description.isEmpty
                ? 'No description provided.'
                : repo.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PortfolioTheme.textSecondary,
                ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (repo.language.isNotEmpty)
                Chip(
                  avatar: Icon(
                    Icons.circle,
                    size: 8,
                    color: PortfolioTheme.accentPrimary,
                  ),
                  label: Text(
                    repo.language,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PortfolioTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  backgroundColor: PortfolioTheme.surface,
                  side: BorderSide(color: PortfolioTheme.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              Chip(
                avatar: const Icon(Icons.star_border, size: 14, color: PortfolioTheme.accentPrimary),
                label: Text(
                  repo.stargazersCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: PortfolioTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                backgroundColor: PortfolioTheme.surface,
                side: BorderSide(color: PortfolioTheme.border),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => _launchGithub(repo.htmlUrl),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: PortfolioTheme.accentPrimary,
            ),
            child: const Text('VIEW ON GITHUB'),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchGithub(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  static const String _email = 'saadnanullah@gmail.com';
  static const String _linkedIn = 'https://linkedin.com/in/adnan-ullah';
  static const String _github = 'https://github.com/md-adnan-ullah';

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Contact',
            subtitle: 'Let’s talk about your next app or product.',
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _ContactRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _email,
                onTap: () => _launch('mailto:$_email'),
              ),
              _ContactRow(
                icon: Icons.link,
                label: 'LinkedIn',
                value: 'linkedin.com/in/adnan-ullah',
                onTap: () => _launch(_linkedIn),
              ),
              _ContactRow(
                icon: Icons.code,
                label: 'GitHub',
                value: 'github.com/md-adnan-ullah',
                onTap: () => _launch(_github),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _ContactForm(),
        ],
      ),
    );
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: PortfolioTheme.accentPrimary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PortfolioTheme.textMuted,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PortfolioTheme.textPrimary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send a message',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: PortfolioTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _formKey.currentState?.save();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Thank you! This demo form does not send yet.',
                    ),
                  ),
                );
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onNavigateToApps,
    required this.onNavigateToPortfolio,
    required this.onNavigateToPricing,
    required this.onNavigateToContact,
    required this.onNavigateToPresets,
    required this.onAdminTap,
  });

  final VoidCallback onNavigateToApps;
  final VoidCallback onNavigateToPortfolio;
  final VoidCallback onNavigateToPricing;
  final VoidCallback onNavigateToContact;
  final VoidCallback onNavigateToPresets;
  final VoidCallback onAdminTap;

  static const String _email = 'saadnanullah@gmail.com';
  static const String _linkedIn = 'https://linkedin.com/in/adnan-ullah';
  static const String _github = 'https://github.com/md-adnan-ullah';

  @override
  Widget build(BuildContext context) {
    final isSmall = ResponsiveHelper.isSmallDevice(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 24 : 72,
        vertical: 48,
      ),
      decoration: const BoxDecoration(
        color: PortfolioTheme.accentPrimary,
      ),
      child: Column(
        children: [
          Text(
            'ADNAN ULLAH',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 12,
            children: [
              _FooterLink(label: 'Portfolio', onTap: onNavigateToPortfolio),
              _FooterLink(label: 'Apps', onTap: onNavigateToApps),
              _FooterLink(label: 'Pricing', onTap: onNavigateToPricing),
              _FooterLink(label: 'Presets', onTap: onNavigateToPresets),
              _FooterLink(label: 'Contact', onTap: onNavigateToContact),
              _FooterLink(label: 'Admin', onTap: onAdminTap),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.email_outlined, color: Colors.white, size: 20),
                onPressed: () => _launch('mailto:$_email'),
              ),
              IconButton(
                icon: const Icon(Icons.link, color: Colors.white, size: 20),
                onPressed: () => _launch(_linkedIn),
              ),
              IconButton(
                icon: const Icon(Icons.code, color: Colors.white, size: 20),
                onPressed: () => _launch(_github),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Privacy policy · Website by Adnan Ullah',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

