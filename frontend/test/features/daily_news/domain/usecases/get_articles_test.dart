import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';

import '../../../../helpers/in_memory_article_repository.dart';

void main() {
  group('GetArticlesUseCase', () {
    test('returns the seeded articles from the test repository', () async {
      final useCase = GetArticlesUseCase(InMemoryArticleRepository());

      final articles = await useCase();

      expect(articles, hasLength(3));
      expect(articles.first.author, 'Ada Lovelace');
      expect(
          articles.first.title, 'Cities can reuse water better than we think');
    });
  });
}
