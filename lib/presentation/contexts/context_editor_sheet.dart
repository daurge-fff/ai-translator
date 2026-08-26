import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/liquid_glass.dart';
import '../../providers/contexts_provider.dart';
import '../../providers/theme_provider.dart';

class ContextEditorSheet extends ConsumerStatefulWidget {
  final ContextTemplateModel? existingItem;

  const ContextEditorSheet({
    super.key,
    this.existingItem,
  });

  static void show(BuildContext context, {ContextTemplateModel? existingItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ContextEditorSheet(existingItem: existingItem),
    );
  }

  @override
  ConsumerState<ContextEditorSheet> createState() => _ContextEditorSheetState();
}

class _ContextEditorSheetState extends ConsumerState<ContextEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingItem?.title ?? '');
    _textController = TextEditingController(text: widget.existingItem?.contextText ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = themeState.glassOpacity;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
              color: isDark
                  ? const Color(0xFF161622).withValues(alpha: opacity)
                  : Colors.white.withValues(alpha: opacity),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.60),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white30 : Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingItem == null
                          ? context.l.newContextTemplate
                          : context.l.editContextTemplate,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 24, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title Field Card
                Text(
                  context.l.templateNameLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: context.l.templateNameHint,
                  ),
                ),
                const SizedBox(height: 24),

                // Context Area Card
                Text(
                  context.l.templateDescLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                    decoration: InputDecoration(
                      hintText: context.l.templateDescHint,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Pill Button
                GlassButton(
                  primary: true,
                  width: double.infinity,
                  height: 54,
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                        _textController.text.isNotEmpty) {
                      final notifier = ref.read(contextsProvider.notifier);
                      if (widget.existingItem != null &&
                          widget.existingItem!.id != null) {
                        notifier.updateTemplate(
                          widget.existingItem!.id!,
                          _titleController.text,
                          _textController.text,
                        );
                      } else {
                        notifier.addTemplate(
                          _titleController.text,
                          _textController.text,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    context.l.saveTemplate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
