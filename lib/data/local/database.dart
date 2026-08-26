import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class TranslationItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sourceText => text()();
  TextColumn get translatedText => text()();
  TextColumn get sourceLang => text()();
  TextColumn get targetLang => text()();
  TextColumn get userContext => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ContextTemplateItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get contextText => text()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [TranslationItems, ContextTemplateItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'contextual_translator_db');
  }

  // Translation history queries
  Future<List<TranslationItem>> getAllTranslations() =>
      (select(translationItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<TranslationItem>> watchAllTranslations() =>
      (select(translationItems)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<int> insertTranslation(TranslationItemsCompanion entry) =>
      into(translationItems).insert(entry);

  Future<int> deleteTranslation(int id) =>
      (delete(translationItems)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllTranslations() => delete(translationItems).go();

  // Context templates queries
  Future<List<ContextTemplateItem>> getAllContextTemplates() =>
      (select(contextTemplateItems)..orderBy([(t) => OrderingTerm.desc(t.isPinned)])).get();

  Future<int> insertContextTemplate(ContextTemplateItemsCompanion entry) =>
      into(contextTemplateItems).insert(entry);

  Future<int> deleteContextTemplate(int id) =>
      (delete(contextTemplateItems)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllContextTemplates() => delete(contextTemplateItems).go();
}
