class PortfolioProject {
  final String id;
  final String title;
  final String description;
  final String role; // e.g. 'Lead Developer', 'Solo Project'
  final List<String> technologies;
  final String? imageUrl;
  final String? caseStudyUrl;
  final String? playStoreUrl;
  final int sortOrder;

  const PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    required this.role,
    this.technologies = const [],
    this.imageUrl,
    this.caseStudyUrl,
    this.playStoreUrl,
    this.sortOrder = 0,
  });

  factory PortfolioProject.fromMap(String id, Map<String, dynamic> map) {
    return PortfolioProject(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      role: map['role'] as String? ?? '',
      technologies: (map['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      imageUrl: map['imageUrl'] as String?,
      caseStudyUrl: map['caseStudyUrl'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'role': role,
      'technologies': technologies,
      'imageUrl': imageUrl,
      'caseStudyUrl': caseStudyUrl,
      'playStoreUrl': playStoreUrl,
      'sortOrder': sortOrder,
    };
  }
}

