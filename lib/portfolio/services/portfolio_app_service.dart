import '../models/portfolio_app.dart';
import '../models/portfolio_project.dart';

/// Read-only catalog of apps and projects for the portfolio.
///
/// For now this uses in-memory sample data so the site works
/// without any backend. Later you can plug this into Firestore
/// collections (e.g. `portfolio_apps` and `portfolio_projects`).
class PortfolioAppService {
  const PortfolioAppService();

  Future<List<PortfolioApp>> fetchApps() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _sampleApps;
  }

  Future<PortfolioApp?> fetchAppById(String id) async {
    final apps = await fetchApps();
    try {
      return apps.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<PortfolioProject>> fetchProjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _sampleProjects;
  }
}

// --- Sample data ------------------------------------------------------------

final List<PortfolioApp> _sampleApps = [
  PortfolioApp(
    id: 'task-flow',
    name: 'Task Flow',
    title: 'Task Flow — Minimal Task Manager',
    shortDescription: 'Clean, focused task manager for busy developers.',
    longDescription:
        'Task Flow helps you capture tasks, group them by projects, and '
        'stay focused with a clean, distraction-free UI. Built with '
        'Flutter and Firebase, it syncs across devices and supports dark mode.',
    platform: 'Flutter · Android',
    priceBdt: 149,
    iconUrl: 'https://images.unsplash.com/photo-1611224923853-80b023f02d71?auto=format&fit=crop&w=400&q=80',
    screenshotUrls: [],
    features: [
      'Inbox, Today, and Upcoming views',
      'Project and label support',
      'Offline-first with local cache',
      'Dark mode and custom themes',
    ],
    technologies: ['Flutter', 'Firebase', 'GetX'],
    version: '1.0.0',
    updateInfo: 'Initial public release.',
    apkPath: null,
    isFeatured: true,
    createdAt: DateTime(2024, 5, 12),
  ),
  PortfolioApp(
    id: 'expense-tracker',
    name: 'Expense Tracker',
    title: 'Expense Tracker — Personal Finance',
    shortDescription: 'Track income and expenses with beautiful charts.',
    longDescription:
        'A lightweight expense tracker focusing on speed and clarity. '
        'Categorise expenses, see trends, and export your data.',
    platform: 'Android (Kotlin)',
    priceBdt: 199,
    iconUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=400&q=80',
    screenshotUrls: [],
    features: [
      'One-tap expense entry',
      'Custom categories',
      'Daily, weekly, monthly charts',
      'CSV export',
    ],
    technologies: ['Kotlin', 'Room', 'Material 3'],
    version: '1.2.0',
    updateInfo: 'Added CSV export and improved charts.',
    apkPath: null,
    isFeatured: false,
    createdAt: DateTime(2023, 11, 4),
  ),
];

final List<PortfolioProject> _sampleProjects = [
  PortfolioProject(
    id: 'ecommerce-app',
    title: 'Furniture E‑Commerce App',
    description:
        'A full e‑commerce experience with product listing, cart, checkout, '
        'and order history for a furniture brand.',
    role: 'Lead Flutter Developer',
    technologies: ['Flutter', 'Firebase', 'Stripe'],
    imageUrl: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=400&q=80',
    caseStudyUrl: null,
    playStoreUrl: null,
    sortOrder: 0,
  ),
  PortfolioProject(
    id: 'food-delivery-ui',
    title: 'Food Delivery UI Kit',
    description:
        'Pixel-perfect food delivery UI with onboarding, restaurant listing, '
        'menu, cart, and order tracking screens.',
    role: 'UI/UX & Implementation',
    technologies: ['Flutter', 'Figma'],
    imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=400&q=80',
    caseStudyUrl: null,
    playStoreUrl: null,
    sortOrder: 1,
  ),
];

