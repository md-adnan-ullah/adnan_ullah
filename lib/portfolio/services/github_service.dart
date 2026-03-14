import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/github_repo.dart';

class GithubService {
  const GithubService();

  static const String _username = 'md-adnan-ullah';

  Future<List<GithubRepo>> fetchPinnedRepos() async {
    final uri =
        Uri.parse('https://api.github.com/users/$_username/repos?per_page=100');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return const [];
    }

    final list = GithubRepo.listFromResponse(response.body);

    // Filter out forks and sort by stargazers & recent activity
    final decoded = jsonDecode(response.body) as List<dynamic>;
    final withForkFlag = <Map<String, dynamic>>[];
    for (final item in decoded.whereType<Map<String, dynamic>>()) {
      withForkFlag.add(item);
    }

    final repos = <GithubRepo>[];
    for (final item in withForkFlag) {
      if (item['fork'] == true) continue;
      repos.add(GithubRepo.fromJson(item));
    }

    repos.sort((a, b) {
      final starCmp = b.stargazersCount.compareTo(a.stargazersCount);
      if (starCmp != 0) return starCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    // Take top 6 for the portfolio
    return repos.take(6).toList();
  }
}

