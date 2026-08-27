import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../data/remote/notification_service.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<AppNotification> _notifications = [];
  String? _loadError;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    _service.setToken(user.idToken.isNotEmpty ? user.idToken : null);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    _service.setDeviceId('admin-panel');
    final result = await _service.getAllNotificationsWithError();
    if (mounted) {
      setState(() {
        _notifications = result.items;
        _loadError = result.error;
        _isLoading = false;
      });
    }
  }

  void _showSendDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final emailController = TextEditingController();
    bool sendToAll = true;

    // Collect known emails from incidents and bans
    final adminState = ref.read(adminProvider);
    final knownEmails = <String>{
      ...adminState.incidents.map((i) => i.user).where((e) => e.contains('@')),
      ...adminState.bans.where((b) => b.type == 'user').map((b) => b.value),
    }.toList();

    showGlassDialog<void>(
      context,
      title: Row(children: [
        const Icon(CupertinoIcons.bell_fill, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(context.l.sendNotification)),
      ]),
      content: StatefulBuilder(
        builder: (context, setInner) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Target selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setInner(() => sendToAll = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: sendToAll
                                ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: sendToAll ? AppColors.primaryBlue : AppColors.separator(isDark),
                            ),
                          ),
                          child: Center(
                            child: Text(context.l.notificationToAll,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: sendToAll ? FontWeight.w600 : FontWeight.w400,
                                    color: sendToAll ? AppColors.primaryBlue : Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setInner(() => sendToAll = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: !sendToAll
                                ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: !sendToAll ? AppColors.primaryBlue : AppColors.separator(isDark),
                            ),
                          ),
                          child: Center(
                            child: Text(context.l.notificationToUser,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: !sendToAll ? FontWeight.w600 : FontWeight.w400,
                                    color: !sendToAll ? AppColors.primaryBlue : Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!sendToAll) ...[
                  const SizedBox(height: 12),
                  Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return knownEmails;
                      final q = textEditingValue.text.toLowerCase();
                      return knownEmails.where((e) => e.toLowerCase().contains(q));
                    },
                    onSelected: (v) => emailController.text = v,
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      // Sync with emailController
                      if (controller.text.isEmpty && emailController.text.isNotEmpty) {
                        controller.text = emailController.text;
                      }
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (v) => emailController.text = v,
                        decoration: InputDecoration(
                          labelText: context.l.notificationEmailHint,
                          prefixIcon: const Icon(CupertinoIcons.person_crop_circle, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final optionList = options.toList();
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            width: 300,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(8),
                              itemCount: optionList.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final option = optionList[index];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(CupertinoIcons.person, size: 16),
                                  title: Text(option, style: const TextStyle(fontSize: 13)),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: context.l.notificationTitle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.l.notificationBody,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l.cancel),
        ),
        GlassButton(
          primary: true,
          color: AppColors.primaryBlue,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: () async {
            if (titleController.text.isNotEmpty && bodyController.text.isNotEmpty) {
              final user = ref.read(authProvider);
              _service.setToken(user.idToken.isNotEmpty ? user.idToken : null);
              final error = await _service.sendNotification(
                title: titleController.text,
                body: bodyController.text,
                targetEmail: sendToAll ? null : emailController.text,
              );
              final success = error == null;
              if (!mounted) return;
              Navigator.pop(context);
              _loadNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? (sendToAll ? context.l.notificationSentToAll : context.l.notificationSent)
                        : error),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            }
          },
          child: Text(context.l.notificationSend, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = themeState.effectiveAccent;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D0D14) : const Color(0xFFF2F2F7),
      body: Column(
        children: [
          SafeArea(
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
                    child: Text(context.l.notificationsTitle,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ),
                  GestureDetector(
                    onTap: _showSendDialog,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.15),
                      ),
                      alignment: Alignment.center,
                      child: Icon(CupertinoIcons.plus, size: 18, color: accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.bell_slash, size: 44,
                                color: isDark ? Colors.white30 : Colors.black26),
                            const SizedBox(height: 12),
                            Text(context.l.noNotifications,
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 16)),
                            if (_loadError != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _loadNotifications,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(context.l.retry,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: _notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final notif = _notifications[i];
                          return LiquidGlassPanel(
                            padding: const EdgeInsets.all(14),
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      notif.isRead ? CupertinoIcons.bell : CupertinoIcons.bell_fill,
                                      size: 16,
                                      color: notif.isRead ? Colors.grey : accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(notif.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await _service.deleteNotification(notif.id);
                                        _loadNotifications();
                                      },
                                      child: const Icon(CupertinoIcons.trash, size: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(notif.body,
                                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(notif.targetEmail != null ? CupertinoIcons.person : CupertinoIcons.person_2,
                                        size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      notif.targetEmail ?? context.l.notificationToAll,
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    const Spacer(),
                                    Text(_formatDate(notif.createdAt),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
