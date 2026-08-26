import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/local/database.dart';
import 'translation_provider.dart';

class ContextTemplateModel {
  final int? id;
  final String title;
  final String contextText;
  final bool isPinned;

  ContextTemplateModel({
    this.id,
    required this.title,
    required this.contextText,
    this.isPinned = false,
  });
}

class ContextsNotifier extends StateNotifier<List<ContextTemplateModel>> {
  final AppDatabase _db;

  ContextsNotifier(this._db)
      : super([
          ContextTemplateModel(
            id: 1,
            title: 'Американцу в Slack',
            contextText: 'Разговорный формат, США, дружелюбный деловой тон',
            isPinned: true,
          ),
          ContextTemplateModel(
            id: 2,
            title: 'Домашка по UK English',
            contextText: 'Британский английский, академический стиль',
            isPinned: true,
          ),
          ContextTemplateModel(
            id: 3,
            title: 'Официальная деловая переписка',
            contextText: 'Строгий бизнес-стиль, вежливое обращение',
            isPinned: false,
          ),
          ContextTemplateModel(
            id: 4,
            title: 'Разговорный сленг',
            contextText: 'Неформальное общение, молодежный сленг',
            isPinned: false,
          ),
        ]) {
    loadFromDb();
  }

  Future<void> loadFromDb() async {
    try {
      final items = await _db.getAllContextTemplates();
      if (items.isNotEmpty) {
        state = items
            .map((e) => ContextTemplateModel(
                  id: e.id,
                  title: e.title,
                  contextText: e.contextText,
                  isPinned: e.isPinned,
                ))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> addTemplate(String title, String contextText) async {
    final entry = ContextTemplateItemsCompanion.insert(
      title: title,
      contextText: contextText,
      isPinned: const drift.Value(false),
    );
    final newId = await _db.insertContextTemplate(entry);
    state = [
      ...state,
      ContextTemplateModel(id: newId, title: title, contextText: contextText)
    ];
  }

  Future<void> updateTemplate(int id, String title, String contextText) async {
    // Update state
    state = state.map((item) {
      if (item.id == id) {
        return ContextTemplateModel(id: id, title: title, contextText: contextText, isPinned: item.isPinned);
      }
      return item;
    }).toList();

    // Persist to Drift DB
    try {
      await (_db.update(_db.contextTemplateItems)..where((t) => t.id.equals(id))).write(
        ContextTemplateItemsCompanion(
          title: drift.Value(title),
          contextText: drift.Value(contextText),
        ),
      );
    } catch (_) {}
  }

  Future<void> deleteTemplate(int id) async {
    await _db.deleteContextTemplate(id);
    state = state.where((item) => item.id != id).toList();
  }

  Future<void> clearAll() async {
    await _db.deleteAllContextTemplates();
    state = [];
  }
}

final contextsProvider = StateNotifierProvider<ContextsNotifier, List<ContextTemplateModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return ContextsNotifier(db);
});
