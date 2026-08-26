// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TranslationItemsTable extends TranslationItems
    with TableInfo<$TranslationItemsTable, TranslationItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sourceTextMeta =
      const VerificationMeta('sourceText');
  @override
  late final GeneratedColumn<String> sourceText = GeneratedColumn<String>(
      'source_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _translatedTextMeta =
      const VerificationMeta('translatedText');
  @override
  late final GeneratedColumn<String> translatedText = GeneratedColumn<String>(
      'translated_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceLangMeta =
      const VerificationMeta('sourceLang');
  @override
  late final GeneratedColumn<String> sourceLang = GeneratedColumn<String>(
      'source_lang', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetLangMeta =
      const VerificationMeta('targetLang');
  @override
  late final GeneratedColumn<String> targetLang = GeneratedColumn<String>(
      'target_lang', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userContextMeta =
      const VerificationMeta('userContext');
  @override
  late final GeneratedColumn<String> userContext = GeneratedColumn<String>(
      'user_context', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceText,
        translatedText,
        sourceLang,
        targetLang,
        userContext,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_items';
  @override
  VerificationContext validateIntegrity(Insertable<TranslationItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_text')) {
      context.handle(
          _sourceTextMeta,
          sourceText.isAcceptableOrUnknown(
              data['source_text']!, _sourceTextMeta));
    } else if (isInserting) {
      context.missing(_sourceTextMeta);
    }
    if (data.containsKey('translated_text')) {
      context.handle(
          _translatedTextMeta,
          translatedText.isAcceptableOrUnknown(
              data['translated_text']!, _translatedTextMeta));
    } else if (isInserting) {
      context.missing(_translatedTextMeta);
    }
    if (data.containsKey('source_lang')) {
      context.handle(
          _sourceLangMeta,
          sourceLang.isAcceptableOrUnknown(
              data['source_lang']!, _sourceLangMeta));
    } else if (isInserting) {
      context.missing(_sourceLangMeta);
    }
    if (data.containsKey('target_lang')) {
      context.handle(
          _targetLangMeta,
          targetLang.isAcceptableOrUnknown(
              data['target_lang']!, _targetLangMeta));
    } else if (isInserting) {
      context.missing(_targetLangMeta);
    }
    if (data.containsKey('user_context')) {
      context.handle(
          _userContextMeta,
          userContext.isAcceptableOrUnknown(
              data['user_context']!, _userContextMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranslationItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sourceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_text'])!,
      translatedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}translated_text'])!,
      sourceLang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_lang'])!,
      targetLang: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_lang'])!,
      userContext: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_context']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TranslationItemsTable createAlias(String alias) {
    return $TranslationItemsTable(attachedDatabase, alias);
  }
}

class TranslationItem extends DataClass implements Insertable<TranslationItem> {
  final int id;
  final String sourceText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String? userContext;
  final DateTime createdAt;
  const TranslationItem(
      {required this.id,
      required this.sourceText,
      required this.translatedText,
      required this.sourceLang,
      required this.targetLang,
      this.userContext,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_text'] = Variable<String>(sourceText);
    map['translated_text'] = Variable<String>(translatedText);
    map['source_lang'] = Variable<String>(sourceLang);
    map['target_lang'] = Variable<String>(targetLang);
    if (!nullToAbsent || userContext != null) {
      map['user_context'] = Variable<String>(userContext);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TranslationItemsCompanion toCompanion(bool nullToAbsent) {
    return TranslationItemsCompanion(
      id: Value(id),
      sourceText: Value(sourceText),
      translatedText: Value(translatedText),
      sourceLang: Value(sourceLang),
      targetLang: Value(targetLang),
      userContext: userContext == null && nullToAbsent
          ? const Value.absent()
          : Value(userContext),
      createdAt: Value(createdAt),
    );
  }

  factory TranslationItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationItem(
      id: serializer.fromJson<int>(json['id']),
      sourceText: serializer.fromJson<String>(json['sourceText']),
      translatedText: serializer.fromJson<String>(json['translatedText']),
      sourceLang: serializer.fromJson<String>(json['sourceLang']),
      targetLang: serializer.fromJson<String>(json['targetLang']),
      userContext: serializer.fromJson<String?>(json['userContext']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceText': serializer.toJson<String>(sourceText),
      'translatedText': serializer.toJson<String>(translatedText),
      'sourceLang': serializer.toJson<String>(sourceLang),
      'targetLang': serializer.toJson<String>(targetLang),
      'userContext': serializer.toJson<String?>(userContext),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TranslationItem copyWith(
          {int? id,
          String? sourceText,
          String? translatedText,
          String? sourceLang,
          String? targetLang,
          Value<String?> userContext = const Value.absent(),
          DateTime? createdAt}) =>
      TranslationItem(
        id: id ?? this.id,
        sourceText: sourceText ?? this.sourceText,
        translatedText: translatedText ?? this.translatedText,
        sourceLang: sourceLang ?? this.sourceLang,
        targetLang: targetLang ?? this.targetLang,
        userContext: userContext.present ? userContext.value : this.userContext,
        createdAt: createdAt ?? this.createdAt,
      );
  TranslationItem copyWithCompanion(TranslationItemsCompanion data) {
    return TranslationItem(
      id: data.id.present ? data.id.value : this.id,
      sourceText:
          data.sourceText.present ? data.sourceText.value : this.sourceText,
      translatedText: data.translatedText.present
          ? data.translatedText.value
          : this.translatedText,
      sourceLang:
          data.sourceLang.present ? data.sourceLang.value : this.sourceLang,
      targetLang:
          data.targetLang.present ? data.targetLang.value : this.targetLang,
      userContext:
          data.userContext.present ? data.userContext.value : this.userContext,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationItem(')
          ..write('id: $id, ')
          ..write('sourceText: $sourceText, ')
          ..write('translatedText: $translatedText, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('userContext: $userContext, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceText, translatedText, sourceLang,
      targetLang, userContext, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationItem &&
          other.id == this.id &&
          other.sourceText == this.sourceText &&
          other.translatedText == this.translatedText &&
          other.sourceLang == this.sourceLang &&
          other.targetLang == this.targetLang &&
          other.userContext == this.userContext &&
          other.createdAt == this.createdAt);
}

class TranslationItemsCompanion extends UpdateCompanion<TranslationItem> {
  final Value<int> id;
  final Value<String> sourceText;
  final Value<String> translatedText;
  final Value<String> sourceLang;
  final Value<String> targetLang;
  final Value<String?> userContext;
  final Value<DateTime> createdAt;
  const TranslationItemsCompanion({
    this.id = const Value.absent(),
    this.sourceText = const Value.absent(),
    this.translatedText = const Value.absent(),
    this.sourceLang = const Value.absent(),
    this.targetLang = const Value.absent(),
    this.userContext = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TranslationItemsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
    this.userContext = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : sourceText = Value(sourceText),
        translatedText = Value(translatedText),
        sourceLang = Value(sourceLang),
        targetLang = Value(targetLang);
  static Insertable<TranslationItem> custom({
    Expression<int>? id,
    Expression<String>? sourceText,
    Expression<String>? translatedText,
    Expression<String>? sourceLang,
    Expression<String>? targetLang,
    Expression<String>? userContext,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceText != null) 'source_text': sourceText,
      if (translatedText != null) 'translated_text': translatedText,
      if (sourceLang != null) 'source_lang': sourceLang,
      if (targetLang != null) 'target_lang': targetLang,
      if (userContext != null) 'user_context': userContext,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TranslationItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? sourceText,
      Value<String>? translatedText,
      Value<String>? sourceLang,
      Value<String>? targetLang,
      Value<String?>? userContext,
      Value<DateTime>? createdAt}) {
    return TranslationItemsCompanion(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      userContext: userContext ?? this.userContext,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceText.present) {
      map['source_text'] = Variable<String>(sourceText.value);
    }
    if (translatedText.present) {
      map['translated_text'] = Variable<String>(translatedText.value);
    }
    if (sourceLang.present) {
      map['source_lang'] = Variable<String>(sourceLang.value);
    }
    if (targetLang.present) {
      map['target_lang'] = Variable<String>(targetLang.value);
    }
    if (userContext.present) {
      map['user_context'] = Variable<String>(userContext.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationItemsCompanion(')
          ..write('id: $id, ')
          ..write('sourceText: $sourceText, ')
          ..write('translatedText: $translatedText, ')
          ..write('sourceLang: $sourceLang, ')
          ..write('targetLang: $targetLang, ')
          ..write('userContext: $userContext, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ContextTemplateItemsTable extends ContextTemplateItems
    with TableInfo<$ContextTemplateItemsTable, ContextTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextTextMeta =
      const VerificationMeta('contextText');
  @override
  late final GeneratedColumn<String> contextText = GeneratedColumn<String>(
      'context_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, contextText, isPinned, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'context_template_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<ContextTemplateItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('context_text')) {
      context.handle(
          _contextTextMeta,
          contextText.isAcceptableOrUnknown(
              data['context_text']!, _contextTextMeta));
    } else if (isInserting) {
      context.missing(_contextTextMeta);
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextTemplateItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      contextText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_text'])!,
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ContextTemplateItemsTable createAlias(String alias) {
    return $ContextTemplateItemsTable(attachedDatabase, alias);
  }
}

class ContextTemplateItem extends DataClass
    implements Insertable<ContextTemplateItem> {
  final int id;
  final String title;
  final String contextText;
  final bool isPinned;
  final DateTime createdAt;
  const ContextTemplateItem(
      {required this.id,
      required this.title,
      required this.contextText,
      required this.isPinned,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['context_text'] = Variable<String>(contextText);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ContextTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return ContextTemplateItemsCompanion(
      id: Value(id),
      title: Value(title),
      contextText: Value(contextText),
      isPinned: Value(isPinned),
      createdAt: Value(createdAt),
    );
  }

  factory ContextTemplateItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextTemplateItem(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      contextText: serializer.fromJson<String>(json['contextText']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'contextText': serializer.toJson<String>(contextText),
      'isPinned': serializer.toJson<bool>(isPinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ContextTemplateItem copyWith(
          {int? id,
          String? title,
          String? contextText,
          bool? isPinned,
          DateTime? createdAt}) =>
      ContextTemplateItem(
        id: id ?? this.id,
        title: title ?? this.title,
        contextText: contextText ?? this.contextText,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt,
      );
  ContextTemplateItem copyWithCompanion(ContextTemplateItemsCompanion data) {
    return ContextTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      contextText:
          data.contextText.present ? data.contextText.value : this.contextText,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextTemplateItem(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('contextText: $contextText, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, contextText, isPinned, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextTemplateItem &&
          other.id == this.id &&
          other.title == this.title &&
          other.contextText == this.contextText &&
          other.isPinned == this.isPinned &&
          other.createdAt == this.createdAt);
}

class ContextTemplateItemsCompanion
    extends UpdateCompanion<ContextTemplateItem> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> contextText;
  final Value<bool> isPinned;
  final Value<DateTime> createdAt;
  const ContextTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.contextText = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContextTemplateItemsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String contextText,
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        contextText = Value(contextText);
  static Insertable<ContextTemplateItem> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? contextText,
    Expression<bool>? isPinned,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (contextText != null) 'context_text': contextText,
      if (isPinned != null) 'is_pinned': isPinned,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContextTemplateItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? contextText,
      Value<bool>? isPinned,
      Value<DateTime>? createdAt}) {
    return ContextTemplateItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      contextText: contextText ?? this.contextText,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contextText.present) {
      map['context_text'] = Variable<String>(contextText.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('contextText: $contextText, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TranslationItemsTable translationItems =
      $TranslationItemsTable(this);
  late final $ContextTemplateItemsTable contextTemplateItems =
      $ContextTemplateItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [translationItems, contextTemplateItems];
}

typedef $$TranslationItemsTableCreateCompanionBuilder
    = TranslationItemsCompanion Function({
  Value<int> id,
  required String sourceText,
  required String translatedText,
  required String sourceLang,
  required String targetLang,
  Value<String?> userContext,
  Value<DateTime> createdAt,
});
typedef $$TranslationItemsTableUpdateCompanionBuilder
    = TranslationItemsCompanion Function({
  Value<int> id,
  Value<String> sourceText,
  Value<String> translatedText,
  Value<String> sourceLang,
  Value<String> targetLang,
  Value<String?> userContext,
  Value<DateTime> createdAt,
});

class $$TranslationItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationItemsTable> {
  $$TranslationItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translatedText => $composableBuilder(
      column: $table.translatedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userContext => $composableBuilder(
      column: $table.userContext, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$TranslationItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationItemsTable> {
  $$TranslationItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translatedText => $composableBuilder(
      column: $table.translatedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userContext => $composableBuilder(
      column: $table.userContext, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$TranslationItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationItemsTable> {
  $$TranslationItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceText => $composableBuilder(
      column: $table.sourceText, builder: (column) => column);

  GeneratedColumn<String> get translatedText => $composableBuilder(
      column: $table.translatedText, builder: (column) => column);

  GeneratedColumn<String> get sourceLang => $composableBuilder(
      column: $table.sourceLang, builder: (column) => column);

  GeneratedColumn<String> get targetLang => $composableBuilder(
      column: $table.targetLang, builder: (column) => column);

  GeneratedColumn<String> get userContext => $composableBuilder(
      column: $table.userContext, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TranslationItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TranslationItemsTable,
    TranslationItem,
    $$TranslationItemsTableFilterComposer,
    $$TranslationItemsTableOrderingComposer,
    $$TranslationItemsTableAnnotationComposer,
    $$TranslationItemsTableCreateCompanionBuilder,
    $$TranslationItemsTableUpdateCompanionBuilder,
    (
      TranslationItem,
      BaseReferences<_$AppDatabase, $TranslationItemsTable, TranslationItem>
    ),
    TranslationItem,
    PrefetchHooks Function()> {
  $$TranslationItemsTableTableManager(
      _$AppDatabase db, $TranslationItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TranslationItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sourceText = const Value.absent(),
            Value<String> translatedText = const Value.absent(),
            Value<String> sourceLang = const Value.absent(),
            Value<String> targetLang = const Value.absent(),
            Value<String?> userContext = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TranslationItemsCompanion(
            id: id,
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLang: sourceLang,
            targetLang: targetLang,
            userContext: userContext,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sourceText,
            required String translatedText,
            required String sourceLang,
            required String targetLang,
            Value<String?> userContext = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              TranslationItemsCompanion.insert(
            id: id,
            sourceText: sourceText,
            translatedText: translatedText,
            sourceLang: sourceLang,
            targetLang: targetLang,
            userContext: userContext,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TranslationItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TranslationItemsTable,
    TranslationItem,
    $$TranslationItemsTableFilterComposer,
    $$TranslationItemsTableOrderingComposer,
    $$TranslationItemsTableAnnotationComposer,
    $$TranslationItemsTableCreateCompanionBuilder,
    $$TranslationItemsTableUpdateCompanionBuilder,
    (
      TranslationItem,
      BaseReferences<_$AppDatabase, $TranslationItemsTable, TranslationItem>
    ),
    TranslationItem,
    PrefetchHooks Function()>;
typedef $$ContextTemplateItemsTableCreateCompanionBuilder
    = ContextTemplateItemsCompanion Function({
  Value<int> id,
  required String title,
  required String contextText,
  Value<bool> isPinned,
  Value<DateTime> createdAt,
});
typedef $$ContextTemplateItemsTableUpdateCompanionBuilder
    = ContextTemplateItemsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> contextText,
  Value<bool> isPinned,
  Value<DateTime> createdAt,
});

class $$ContextTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ContextTemplateItemsTable> {
  $$ContextTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextText => $composableBuilder(
      column: $table.contextText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ContextTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextTemplateItemsTable> {
  $$ContextTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextText => $composableBuilder(
      column: $table.contextText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ContextTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextTemplateItemsTable> {
  $$ContextTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contextText => $composableBuilder(
      column: $table.contextText, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContextTemplateItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContextTemplateItemsTable,
    ContextTemplateItem,
    $$ContextTemplateItemsTableFilterComposer,
    $$ContextTemplateItemsTableOrderingComposer,
    $$ContextTemplateItemsTableAnnotationComposer,
    $$ContextTemplateItemsTableCreateCompanionBuilder,
    $$ContextTemplateItemsTableUpdateCompanionBuilder,
    (
      ContextTemplateItem,
      BaseReferences<_$AppDatabase, $ContextTemplateItemsTable,
          ContextTemplateItem>
    ),
    ContextTemplateItem,
    PrefetchHooks Function()> {
  $$ContextTemplateItemsTableTableManager(
      _$AppDatabase db, $ContextTemplateItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextTemplateItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextTemplateItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextTemplateItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> contextText = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ContextTemplateItemsCompanion(
            id: id,
            title: title,
            contextText: contextText,
            isPinned: isPinned,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String contextText,
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ContextTemplateItemsCompanion.insert(
            id: id,
            title: title,
            contextText: contextText,
            isPinned: isPinned,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContextTemplateItemsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ContextTemplateItemsTable,
        ContextTemplateItem,
        $$ContextTemplateItemsTableFilterComposer,
        $$ContextTemplateItemsTableOrderingComposer,
        $$ContextTemplateItemsTableAnnotationComposer,
        $$ContextTemplateItemsTableCreateCompanionBuilder,
        $$ContextTemplateItemsTableUpdateCompanionBuilder,
        (
          ContextTemplateItem,
          BaseReferences<_$AppDatabase, $ContextTemplateItemsTable,
              ContextTemplateItem>
        ),
        ContextTemplateItem,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TranslationItemsTableTableManager get translationItems =>
      $$TranslationItemsTableTableManager(_db, _db.translationItems);
  $$ContextTemplateItemsTableTableManager get contextTemplateItems =>
      $$ContextTemplateItemsTableTableManager(_db, _db.contextTemplateItems);
}
