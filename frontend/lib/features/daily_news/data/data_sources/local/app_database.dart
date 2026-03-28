import 'dart:async';

import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_draft_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../models/article.dart';
import '../../models/article_draft.dart';

part 'app_database.g.dart';

final migration1To2 = Migration(1, 2, (database) async {
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `article_draft` (`draftKey` TEXT, `authorName` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `content` TEXT NOT NULL, `thumbnailPath` TEXT, `thumbnailLocalPath` TEXT, `fileName` TEXT, `updatedAtEpochMs` INTEGER NOT NULL, PRIMARY KEY (`draftKey`))',
  );
});

final migration2To3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE `article` RENAME TO `article_legacy`');
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `article` (`id` TEXT, `author` TEXT, `title` TEXT, `description` TEXT, `url` TEXT, `urlToImage` TEXT, `publishedAt` TEXT, `content` TEXT, PRIMARY KEY (`id`))',
  );
  await database.execute(
    'INSERT OR REPLACE INTO `article` (`id`, `author`, `title`, `description`, `url`, `urlToImage`, `publishedAt`, `content`) '
    'SELECT CAST(`id` AS TEXT), `author`, `title`, `description`, `url`, `urlToImage`, `publishedAt`, `content` '
    'FROM `article_legacy` WHERE `id` IS NOT NULL',
  );
  await database.execute('DROP TABLE `article_legacy`');
});

@Database(version: 3, entities: [ArticleModel, ArticleDraftModel])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;

  ArticleDraftDao get articleDraftDao;
}
