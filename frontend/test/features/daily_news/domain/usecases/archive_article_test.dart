import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/archive_article.dart';

import '../../../../helpers/in_memory_article_repository.dart';

void main() {
  group('ArchiveArticleUseCase', () {
    test('removes an article from the in-memory repository', () async {
      final repository = InMemoryArticleRepository();
      final useCase = ArchiveArticleUseCase(repository);

      await useCase(params: '1');

      final articles = await repository.getArticles();
      expect(articles, hasLength(2));
      expect(articles.any((article) => article.id == '1'), isFalse);
    });
  });
}
