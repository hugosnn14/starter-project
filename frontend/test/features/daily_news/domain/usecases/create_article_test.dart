import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';

void main() {
  group('CreateArticleUseCase', () {
    test('creates a new article and prepends it to the repository list',
        () async {
      final repository = InMemoryArticleRepository();
      final createArticleUseCase = CreateArticleUseCase(repository);
      final getArticlesUseCase = GetArticlesUseCase(repository);

      final createdArticle = await createArticleUseCase(
        params: const CreateArticleParams(
          authorName: 'Hugo',
          title: 'A small vertical slice is enough',
          description: 'Keep the feature small and finished.',
          content: 'A tiny but reliable flow is easier to reason about.',
        ),
      );

      final articles = await getArticlesUseCase();

      expect(createdArticle.id, '4');
      expect(createdArticle.author, 'Hugo');
      expect(createdArticle.title, 'A small vertical slice is enough');
      expect(articles, hasLength(4));
      expect(articles.first.id, '4');
      expect(articles.first.title, 'A small vertical slice is enough');
    });
  });
}
