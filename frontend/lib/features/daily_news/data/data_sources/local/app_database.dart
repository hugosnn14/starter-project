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

@Database(version: 2, entities: [ArticleModel, ArticleDraftModel])
abstract class AppDatabase extends FloorDatabase {
  ArticleDao get articleDAO;

  ArticleDraftDao get articleDraftDao;
}
