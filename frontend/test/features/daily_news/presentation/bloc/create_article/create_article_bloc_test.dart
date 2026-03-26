import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';

void main() {
  group('CreateArticleBloc', () {
    test('emits submitting and success when an article is created', () async {
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(ArticleRepositoryImpl()),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Create flow works',
          description: 'The form writes into the in-memory repository.',
          content: 'After saving, the new article should be available.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.submitting);
      expect(emittedStates[1].status, CreateArticleStatus.success);
      expect(emittedStates[1].article, isNotNull);
      expect(emittedStates[1].article!.title, 'Create flow works');

      await bloc.close();
    });
  });
}
