// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArticleDao? _articleDAOInstance;
  ArticleDraftDao? _articleDraftDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
          database,
          startVersion,
          endVersion,
          migrations,
        );

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `article` (`id` TEXT, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))',
        );
        await database.execute(
          'CREATE TABLE IF NOT EXISTS `article_draft` (`draftKey` TEXT, `authorName` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `content` TEXT NOT NULL, `thumbnailPath` TEXT, `thumbnailLocalPath` TEXT, `fileName` TEXT, `updatedAtEpochMs` INTEGER NOT NULL, PRIMARY KEY (`draftKey`))',
        );

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArticleDao get articleDAO {
    return _articleDAOInstance ??= _$ArticleDao(database, changeListener);
  }

  @override
  ArticleDraftDao get articleDraftDao {
    return _articleDraftDaoInstance ??=
        _$ArticleDraftDao(database, changeListener);
  }
}

class _$ArticleDao extends ArticleDao {
  _$ArticleDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _articleModelInsertionAdapter = InsertionAdapter(
          database,
          'article',
          (ArticleModel item) => <String, Object?>{
            'id': item.id,
            'author': item.author,
            'title': item.title,
            'description': item.description,
            'url': item.url,
            'urlToImage': item.urlToImage,
            'publishedAt': item.publishedAt,
            'content': item.content,
          },
        ),
        _articleModelDeletionAdapter = DeletionAdapter(
          database,
          'article',
          ['id'],
          (ArticleModel item) => <String, Object?>{
            'id': item.id,
            'author': item.author,
            'title': item.title,
            'description': item.description,
            'url': item.url,
            'urlToImage': item.urlToImage,
            'publishedAt': item.publishedAt,
            'content': item.content,
          },
        );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleModel> _articleModelInsertionAdapter;

  final DeletionAdapter<ArticleModel> _articleModelDeletionAdapter;

  @override
  Future<List<ArticleModel>> getArticles() async {
    return _queryAdapter.queryList(
      'SELECT * FROM article',
      mapper: (Map<String, Object?> row) => ArticleModel(
        id: row['id'] as String?,
        author: row['author'] as String?,
        title: row['title'] as String?,
        description: row['description'] as String?,
        url: row['url'] as String?,
        urlToImage: row['urlToImage'] as String?,
        publishedAt: row['publishedAt'] as String?,
        content: row['content'] as String?,
      ),
    );
  }

  @override
  Future<void> insertArticle(ArticleModel article) async {
    await _articleModelInsertionAdapter.insert(
      article,
      OnConflictStrategy.abort,
    );
  }

  @override
  Future<void> deleteArticle(ArticleModel articleModel) async {
    await _articleModelDeletionAdapter.delete(articleModel);
  }
}

class _$ArticleDraftDao extends ArticleDraftDao {
  _$ArticleDraftDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _articleDraftModelInsertionAdapter = InsertionAdapter(
          database,
          'article_draft',
          (ArticleDraftModel item) => <String, Object?>{
            'draftKey': item.draftKey,
            'authorName': item.authorName,
            'title': item.title,
            'description': item.description,
            'content': item.content,
            'thumbnailPath': item.thumbnailPath,
            'thumbnailLocalPath': item.thumbnailLocalPath,
            'fileName': item.fileName,
            'updatedAtEpochMs': item.updatedAtEpochMs,
          },
        );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArticleDraftModel> _articleDraftModelInsertionAdapter;

  @override
  Future<ArticleDraftModel?> getDraftByKey(String draftKey) async {
    return _queryAdapter.query(
      'SELECT * FROM article_draft WHERE draftKey = ?1 LIMIT 1',
      mapper: (Map<String, Object?> row) => ArticleDraftModel(
        draftKey: row['draftKey'] as String,
        authorName: row['authorName'] as String,
        title: row['title'] as String,
        description: row['description'] as String,
        content: row['content'] as String,
        updatedAtEpochMs: row['updatedAtEpochMs'] as int,
        thumbnailPath: row['thumbnailPath'] as String?,
        thumbnailLocalPath: row['thumbnailLocalPath'] as String?,
        fileName: row['fileName'] as String?,
      ),
      arguments: [draftKey],
    );
  }

  @override
  Future<void> saveDraft(ArticleDraftModel articleDraft) async {
    await _articleDraftModelInsertionAdapter.insert(
      articleDraft,
      OnConflictStrategy.replace,
    );
  }

  @override
  Future<void> deleteDraftByKey(String draftKey) async {
    await _queryAdapter.queryNoReturn(
      'DELETE FROM article_draft WHERE draftKey = ?1',
      arguments: [draftKey],
    );
  }
}
