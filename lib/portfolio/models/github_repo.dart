import 'dart:convert';

class GithubRepo {
  final String id;
  final String name;
  final String description;
  final String htmlUrl;
  final String language;
  final int stargazersCount;
  final DateTime updatedAt;

  const GithubRepo({
    required this.id,
    required this.name,
    required this.description,
    required this.htmlUrl,
    required this.language,
    required this.stargazersCount,
    required this.updatedAt,
  });

  /// Repo name formatted for display: hyphens/underscores → spaces, title case.
  String get displayName {
    if (name.isEmpty) return name;
    final words = name.split(RegExp(r'[-_\s]+'));
    return words
        .where((w) => w.isNotEmpty)
        .map((w) =>
            w.length > 1
                ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                : w.toUpperCase())
        .join(' ');
  }

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      htmlUrl: json['html_url'] as String? ?? '',
      language: json['language'] as String? ?? '',
      stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static List<GithubRepo> listFromResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(GithubRepo.fromJson)
        .toList();
  }
}

