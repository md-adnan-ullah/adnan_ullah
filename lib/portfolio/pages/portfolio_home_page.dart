import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gems_responsive/gems_responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/portfolio_app.dart';
import '../models/portfolio_project.dart';
import '../services/portfolio_app_service.dart';
import '../utils/portfolio_theme.dart';
import '../widgets/animated_section.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_header.dart';
import '../widgets/skill_badge.dart';
import 'app_detail_page.dart';

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final _scrollController = ScrollController();
  final _service = const PortfolioAppService();

  late Future<List<PortfolioApp>> _appsFuture;
  late Future<List<PortfolioProject>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = _service.fetchApps();
    _projectsFuture = _service.fetchProjects();
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
                child: FutureBuilder<List<PortfolioProject>>(
                  future: _projectsFuture,
                  builder: (context, snapshot) {
                    final projects = snapshot.data ?? [];
                    return _PortfolioSection(projects: projects);
                  },
                ),
              ),
              AnimatedSection(
                child: const _ContactSection(),
              ),
              SizedBox(height: isSmall ? 32 : 48),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _scrollTo(0),
                    child: Text(
                      'AU',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: PortfolioTheme.accentPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                  ),
                  if (!isSmall)
                    Row(
                      children: [
                        _NavLink(label: 'Home', onTap: () => _scrollTo(0)),
                        _NavLink(label: 'Apps', onTap: () => _scrollTo(900)),
                        _NavLink(
                            label: 'Portfolio', onTap: () => _scrollTo(1400)),
                        _NavLink(
                            label: 'Contact', onTap: () => _scrollTo(2200)),
                      ],
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

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: PortfolioTheme.textSecondary,
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
    final height = ResponsiveHelper.getScreenHeight(context);

    return Container(
      height: height * 0.9,
      decoration: const BoxDecoration(
        gradient: PortfolioTheme.heroGradient,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 24 : 72,
          vertical: isSmall ? 32 : 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, I’m',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PortfolioTheme.textSecondary,
                  ),
            ).animate().fadeIn(duration: 400.ms).moveX(begin: -20, end: 0),
            const SizedBox(height: 8),
            Text(
              'Adnan Ullah',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: PortfolioTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 450.ms)
                .moveY(begin: 24, end: 0),
            const SizedBox(height: 12),
            Text(
              'Mobile App Developer',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: PortfolioTheme.accentSecondary,
                  ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 450.ms)
                .moveY(begin: 20, end: 0),
            const SizedBox(height: 20),
            Text(
              'I design and build high-quality Android and Flutter apps with\n'
              'clean architecture, smooth animations, and production-ready code.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PortfolioTheme.textSecondary,
                  ),
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 450.ms)
                .moveY(begin: 16, end: 0),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: onViewApps,
                  child: const Text('View My Apps'),
                )
                    .animate()
                    .fadeIn(delay: 450.ms, duration: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                OutlinedButton(
                  onPressed: onContact,
                  child: const Text('Contact Me'),
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
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
              childAspectRatio: 0.9,
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

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PortfolioTheme.accentPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.apps,
              color: PortfolioTheme.accentPrimary,
            ),
          ),
          const SizedBox(height: 16),
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
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '৳${app.priceBdt}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: PortfolioTheme.accentPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'View',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: PortfolioTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: PortfolioTheme.card,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.phone_android,
                              color: PortfolioTheme.accentPrimary,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: PortfolioTheme.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.role,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: PortfolioTheme.textMuted,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: PortfolioTheme.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: p.technologies
                                      .map(
                                        (t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                PortfolioTheme.glassBackground,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            t,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: PortfolioTheme
                                                      .textSecondary,
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
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  static const String _email = 'adnan@example.com';
  static const String _linkedIn = 'https://linkedin.com/in/adnanullah';
  static const String _github = 'https://github.com/adnanullah';

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
                value: 'linkedin.com/in/adnanullah',
                onTap: () => _launch(_linkedIn),
              ),
              _ContactRow(
                icon: Icons.code,
                label: 'GitHub',
                value: 'github.com/adnanullah',
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

