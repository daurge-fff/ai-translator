import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/app_strings.dart';
import '../../data/remote/github_service.dart';

class ChangelogScreen extends StatefulWidget {
  const ChangelogScreen({super.key});

  @override
  State<ChangelogScreen> createState() => _ChangelogScreenState();
}

class _ChangelogScreenState extends State<ChangelogScreen> {
  late Future<List<GitHubCommit>> _future;

  @override
  void initState() {
    super.initState();
    _future = GitHubService().getCommits(perPage: 50);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D14) : const Color(0xFFF2F2F7),
      body: Column(
        children: [
          _buildHeader(context, isDark),
          Expanded(
            child: FutureBuilder<List<GitHubCommit>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final commits = snapshot.data ?? [];
                if (commits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.cloud_download,
                            size: 40, color: isDark ? Colors.white30 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(context.l.changelogLoadError,
                            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
                      ],
                    ),
                  );
                }
                return _buildList(commits, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                ),
                alignment: Alignment.center,
                child: Icon(CupertinoIcons.back, size: 18, color: isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l.changelogTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<GitHubCommit> commits, bool isDark) {
    final grouped = <String, List<GitHubCommit>>{};
    for (final c in commits) {
      final day = _formatDate(c.date);
      grouped.putIfAbsent(day, () => []).add(c);
    }
    final sections = grouped.entries.toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final entry = sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 10),
              child: Text(entry.key.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white38 : Colors.black38)),
            ),
            ...entry.value.map((commit) => _buildCommitCard(commit, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildCommitCard(GitHubCommit commit, bool isDark) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(commit.url)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(commit.message,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: [
                // Author chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.person_crop_circle, size: 11,
                          color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Text(commit.author,
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Date + time chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.clock, size: 11,
                          color: isDark ? Colors.white38 : Colors.black38),
                      const SizedBox(width: 4),
                      Text('${_formatShortDate(commit.date)} · ${_formatTime(commit.date)}',
                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                ),
                const Spacer(),
                // SHA chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                  ),
                  child: Text(commit.sha,
                      style: TextStyle(fontSize: 10, fontFamily: 'monospace',
                          color: isDark ? Colors.white30 : Colors.black38)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d MMMM yyyy', 'ru').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatShortDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d MMM', 'ru').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }
}
