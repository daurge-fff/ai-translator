import 'package:dio/dio.dart';

class GitHubCommit {
  final String sha;
  final String message;
  final String author;
  final String date;
  final String url;

  GitHubCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.date,
    required this.url,
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    final commit = json['commit'] as Map<String, dynamic>? ?? {};
    final author = commit['author'] as Map<String, dynamic>? ?? {};
    final message = (commit['message'] as String? ?? '').trim();
    // Split on first newline: first line = title, rest = body
    final lines = message.split('\n');
    final title = lines.first;

    return GitHubCommit(
      sha: (json['sha'] as String? ?? '').substring(0, 7),
      message: title,
      author: author['name'] as String? ?? '',
      date: author['date'] as String? ?? '',
      url: json['html_url'] as String? ?? '',
    );
  }
}

class GitHubService {
  final Dio _dio;
  static const _owner = 'daurge-fff';
  static const _repo = 'ai-translator';

  GitHubService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.github.com',
    headers: {'Accept': 'application/vnd.github.v3+json'},
  ));

  /// Fetch recent commits from main branch
  Future<List<GitHubCommit>> getCommits({int perPage = 30}) async {
    try {
      final response = await _dio.get(
        '/repos/$_owner/$_repo/commits',
        queryParameters: {'per_page': perPage, 'sha': 'main'},
      );
      final data = response.data as List;
      return data.map((e) => GitHubCommit.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
