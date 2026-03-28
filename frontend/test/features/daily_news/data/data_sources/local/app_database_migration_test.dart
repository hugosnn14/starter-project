import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late String databasePath;

  setUp(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    tempDir = await Directory.systemTemp.createTemp('daily_news_db_legacy_');
    databasePath = '${tempDir.path}${Platform.pathSeparator}app_database.db';

    final legacyDatabase = await sqflite.databaseFactory.openDatabase(
      databasePath,
      options: sqflite.OpenDatabaseOptions(
        version: 2,
        onCreate: (database, version) async {
          await database.execute(
            'CREATE TABLE IF NOT EXISTS `article` (`id` INTEGER, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))',
          );
          await database.execute(
            'CREATE TABLE IF NOT EXISTS `article_draft` (`draftKey` TEXT, `authorName` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `content` TEXT NOT NULL, `thumbnailPath` TEXT, `thumbnailLocalPath` TEXT, `fileName` TEXT, `updatedAtEpochMs` INTEGER NOT NULL, PRIMARY KEY (`draftKey`))',
          );
          await database.insert('article', {
            'id': 42,
            'author': 'Ada Lovelace',
            'title': 'Legacy row',
            'description': 'Stored before the id switched to String.',
            'url': 'https://example.com/legacy-row',
            'urlToImage': 'https://example.com/legacy-row.png',
            'publishedAt': '2026-03-27',
            'content': 'This row should survive the migration.',
          });
        },
      ),
    );

    await legacyDatabase.close();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('migrates legacy integer ids to text and accepts string ids', () async {
    final appDatabase = await $FloorAppDatabase
        .databaseBuilder(databasePath)
        .addMigrations([migration1To2, migration2To3]).build();
    final dataSource = SavedArticleLocalDataSourceImpl(
      articleDao: appDatabase.articleDAO,
    );

    final migratedArticles = await dataSource.getSavedArticles();
    expect(migratedArticles, hasLength(1));
    expect(migratedArticles.single.id, '42');

    await dataSource.saveArticle(
      const ArticleEntity(
        id: 'newsapi:headline-123',
        author: 'Grace Hopper',
        title: 'String ids now work',
        description: 'Saved articles should accept Firebase and NewsAPI ids.',
        url: 'https://example.com/string-id',
        urlToImage: 'https://example.com/string-id.png',
        publishedAt: '2026-03-28',
        content: 'SQLite should no longer reject string ids.',
      ),
    );

    final savedArticles = await dataSource.getSavedArticles();
    expect(
      savedArticles.any((article) => article.id == 'newsapi:headline-123'),
      isTrue,
    );

    await appDatabase.close();
  });
}
