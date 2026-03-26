import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';

import '../../../../helpers/in_memory_article_repository.dart';

void main() {
  group('GetMyArticlesUseCase', () {
    test('returns the current repository articles', () async {
      final repository = InMemoryArticleRepository();
      final useCase = GetMyArticlesUseCase(repository);

      final articles = await useCase();

      expect(articles, hasLength(3));
      expect(articles.first.id, '1');
    });
  });
}
