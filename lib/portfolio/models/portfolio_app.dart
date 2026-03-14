class PortfolioApp {
  final String id;
  final String name;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String platform; // e.g. 'Android', 'Flutter'
  final int priceBdt;
  final String? iconUrl;
  final List<String> screenshotUrls;
  final List<String> features;
  final List<String> technologies;
  final String version;
  final String? updateInfo;
  final String? apkPath; // Storage path or download URL (will come from Firebase)
  final bool isFeatured;
  final DateTime createdAt;

  const PortfolioApp({
    required this.id,
    required this.name,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.platform,
    required this.priceBdt,
    this.iconUrl,
    this.screenshotUrls = const [],
    this.features = const [],
    this.technologies = const [],
    this.version = '1.0.0',
    this.updateInfo,
    this.apkPath,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory PortfolioApp.fromMap(String id, Map<String, dynamic> map) {
    return PortfolioApp(
      id: id,
      name: map['name'] as String? ?? '',
      title: map['title'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      longDescription: map['longDescription'] as String? ?? '',
      platform: map['platform'] as String? ?? 'Android',
      priceBdt: (map['priceBdt'] as num?)?.toInt() ?? 0,
      iconUrl: map['iconUrl'] as String?,
      screenshotUrls: (map['screenshotUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      features: (map['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      technologies: (map['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      version: map['version'] as String? ?? '1.0.0',
      updateInfo: map['updateInfo'] as String?,
      apkPath: map['apkPath'] as String?,
      isFeatured: map['isFeatured'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'platform': platform,
      'priceBdt': priceBdt,
      'iconUrl': iconUrl,
      'screenshotUrls': screenshotUrls,
      'features': features,
      'technologies': technologies,
      'version': version,
      'updateInfo': updateInfo,
      'apkPath': apkPath,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

