import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_details/article_details_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_details/article_details_state.dart';
import '../../../../../helpers/fake_article_repository.dart';

void main() {
  group('ArticleDetailsBloc', () {
    test('emits loading and success when the article exists', () async {
      final bloc = ArticleDetailsBloc(
        GetArticleByIdUseCase(InMemoryArticleRepository()),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const LoadArticleDetails('2'));

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, ArticleDetailsStatus.loading);
      expect(emittedStates[1].status, ArticleDetailsStatus.success);
      expect(
        emittedStates[1].article?.title,
        'Why public tech products need simpler writing',
      );

      await bloc.close();
    });

    test('emits loading and notFound when the article does not exist',
        () async {
      final bloc = ArticleDetailsBloc(
        GetArticleByIdUseCase(InMemoryArticleRepository()),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const LoadArticleDetails('999'));

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, ArticleDetailsStatus.loading);
      expect(emittedStates[1].status, ArticleDetailsStatus.notFound);
      expect(emittedStates[1].article, isNull);

      await bloc.close();
    });

    test('emits loading and failure when the repository throws', () async {
      final bloc = ArticleDetailsBloc(
        GetArticleByIdUseCase(
          FakeArticleRepository(shouldThrowOnGetArticleById: true),
        ),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const LoadArticleDetails('2'));

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, ArticleDetailsStatus.loading);
      expect(emittedStates[1].status, ArticleDetailsStatus.failure);
      expect(
        emittedStates[1].errorMessage,
        'No se pudo cargar el articulo.',
      );

      await bloc.close();
    });
  });
}
