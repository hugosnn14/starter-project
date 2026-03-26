import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved_articles/saved_articles_state.dart';
import '../../../../../helpers/fake_article_repository.dart';

void main() {
  group('SavedArticlesBloc', () {
    test('emits loading and success when saved articles are requested',
        () async {
      final repository = InMemoryArticleRepository();
      final bloc = SavedArticlesBloc(
        GetSavedArticleUseCase(repository),
        SaveArticleUseCase(repository),
        RemoveArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const SavedArticlesRequested());

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, SavedArticlesStatus.loading);
      expect(emittedStates[1].status, SavedArticlesStatus.success);
      expect(emittedStates[1].articles, isEmpty);

      await bloc.close();
    });

    test('emits loading and success when an article is saved', () async {
      final repository = InMemoryArticleRepository();
      final article = (await GetArticlesUseCase(repository)()).first;
      final bloc = SavedArticlesBloc(
        GetSavedArticleUseCase(repository),
        SaveArticleUseCase(repository),
        RemoveArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(SavedArticleStored(article));

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, SavedArticlesStatus.loading);
      expect(emittedStates[1].status, SavedArticlesStatus.success);
      expect(emittedStates[1].articles, hasLength(1));
      expect(emittedStates[1].articles.first.id, article.id);

      await bloc.close();
    });

    test('emits loading and success when an article is removed', () async {
      final repository = InMemoryArticleRepository();
      final article = (await GetArticlesUseCase(repository)()).first;
      await SaveArticleUseCase(repository)(params: article);

      final bloc = SavedArticlesBloc(
        GetSavedArticleUseCase(repository),
        SaveArticleUseCase(repository),
        RemoveArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(SavedArticleDeleted(article));

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, SavedArticlesStatus.loading);
      expect(emittedStates[1].status, SavedArticlesStatus.success);
      expect(emittedStates[1].articles, isEmpty);

      await bloc.close();
    });

    test('emits loading and failure when saved articles cannot be loaded',
        () async {
      final repository = FakeArticleRepository(
        shouldThrowOnGetSavedArticles: true,
      );
      final bloc = SavedArticlesBloc(
        GetSavedArticleUseCase(repository),
        SaveArticleUseCase(repository),
        RemoveArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const SavedArticlesRequested());

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, SavedArticlesStatus.loading);
      expect(emittedStates[1].status, SavedArticlesStatus.failure);
      expect(
        emittedStates[1].errorMessage,
        'No se pudieron cargar los articulos guardados.',
      );

      await bloc.close();
    });
  });
}
