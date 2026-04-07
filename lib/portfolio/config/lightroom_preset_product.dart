import '../models/portfolio_app.dart';

/// Lightroom preset products sold with manual payment + Firestore verification flow.
/// Set each [apkPath] to your hosted .zip URL for actual downloads.
final List<PortfolioApp> kLightroomPresetProducts = [
  PortfolioApp(
    id: 'lightroom_presets_warm_portrait',
    name: 'Warm portrait pack',
    title: 'Warm portrait preset pack',
    shortDescription:
        'Soft skin tones and warm mood for portraits, weddings, and lifestyle photos.',
    longDescription:
        'A portrait-focused preset bundle crafted for natural skin rendering and warm cinematic tones. '
        'Great for daylight portraits, couple sessions, and indoor natural-light edits.\n\n'
        'Includes installation notes for Lightroom mobile + desktop.',
    platform: 'Lightroom',
    priceBdt: 299,
    iconUrl:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=1200&q=80',
    features: const [
      'Portrait-friendly skin tones',
      'Warm cinematic mood',
      'Mobile + desktop compatible',
      'ZIP download after verification',
    ],
    technologies: const ['Lightroom', 'XMP', 'Mobile', 'Desktop'],
    version: '1.0.0',
    updateInfo: 'Minor tone updates may be included for verified buyers.',
    apkPath: null,
    isFeatured: true,
    createdAt: DateTime(2025, 1, 1),
  ),
  PortfolioApp(
    id: 'lightroom_presets_travel_vivid',
    name: 'Travel vivid pack',
    title: 'Travel vivid preset pack',
    shortDescription:
        'Clean contrast, punchy colors, and sky enhancement for travel and outdoor shots.',
    longDescription:
        'Designed for travel and street photography with brighter highlights, controlled shadows, '
        'and crisp color separation. Helps maintain a bold but clean social media look.\n\n'
        'Works with Lightroom Classic, cloud Lightroom, and mobile.',
    platform: 'Lightroom',
    priceBdt: 349,
    iconUrl:
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
    features: const [
      'Vivid travel color profile',
      'Sky + landscape friendly',
      'Fast one-tap edits',
      'ZIP delivery after payment verification',
    ],
    technologies: const ['Lightroom', 'XMP', 'Travel', 'Mobile'],
    version: '1.0.0',
    updateInfo: 'Additional travel looks may be added in future.',
    apkPath: null,
    isFeatured: false,
    createdAt: DateTime(2025, 1, 1),
  ),
  PortfolioApp(
    id: 'lightroom_presets_moody_dark',
    name: 'Moody dark pack',
    title: 'Moody dark preset pack',
    shortDescription:
        'Deep contrast and muted cinematic tones for dramatic, storytelling edits.',
    longDescription:
        'A moody preset collection for creators who prefer low-key contrast, matte shadows, '
        'and filmic color depth. Great for cafes, night shots, and storytelling reels.\n\n'
        'Includes quick setup guide for both desktop and mobile workflows.',
    platform: 'Lightroom',
    priceBdt: 329,
    iconUrl:
        'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1200&q=80',
    features: const [
      'Moody cinematic grade',
      'Matte and dark-tone looks',
      'Desktop + mobile workflow',
      'Secure ZIP download',
    ],
    technologies: const ['Lightroom', 'XMP', 'Cinematic', 'Desktop'],
    version: '1.0.0',
    updateInfo: 'Future dark variations may be included.',
    apkPath: null,
    isFeatured: false,
    createdAt: DateTime(2025, 1, 1),
  ),
];

/// Backward compatibility alias used in previous screens.
final PortfolioApp kLightroomPresetPack = kLightroomPresetProducts.first;
