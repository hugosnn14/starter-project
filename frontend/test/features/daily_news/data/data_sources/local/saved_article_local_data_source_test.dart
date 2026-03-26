import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

void main() {
  late AppDatabase appDatabase;
  late SavedArticleLocalDataSource dataSource;

  const savedArticle = ArticleEntity(
    id: 'article-1',
    author: 'Ada Lovelace',
    title: 'Local persistence works',
    description: 'Saved articles should survive app restarts.',
    url: 'https://example.com/articles/local-persistence',
    urlToImage: 'https://example.com/articles/local-persistence.png',
    publishedAt: '2026-03-26',
    content: 'Floor stores a snapshot of the saved article.',
  );

  setUp(() async {
    appDatabase = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    dataSource = SavedArticleLocalDataSourceImpl(
      articleDao: appDatabase.articleDAO,
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('persists and loads saved articles', () async {
    await dataSource.saveArticle(savedArticle);

    final savedArticles = await dataSource.getSavedArticles();

    expect(savedArticles, [savedArticle]);
  });

  test('removes a previously saved article', () async {
    await dataSource.saveArticle(savedArticle);

    await dataSource.removeArticle(savedArticle);

    final savedArticles = await dataSource.getSavedArticles();

    expect(savedArticles, isEmpty);
  });
}
