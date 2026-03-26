import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';

import '../../../../helpers/in_memory_article_repository.dart';

void main() {
  group('UpdateArticleUseCase', () {
    test('updates an existing article by id', () async {
      final repository = InMemoryArticleRepository();
      final useCase = UpdateArticleUseCase(repository);

      final updatedArticle = await useCase(
        params: const UpdateArticleParams(
          articleId: '1',
          authorName: 'Ada Lovelace',
          title: 'Updated title',
          description: 'Updated description',
          content: 'Updated content',
          sourceUrl: 'https://example.com/articles/updated',
        ),
      );

      expect(updatedArticle.id, '1');
      expect(updatedArticle.title, 'Updated title');

      final fetchedArticle = await repository.getArticleById('1');
      expect(fetchedArticle?.title, 'Updated title');
    });
  });
}
