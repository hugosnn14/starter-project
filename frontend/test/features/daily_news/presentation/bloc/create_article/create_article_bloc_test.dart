import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/in_memory_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';
import '../../../../../helpers/fake_article_repository.dart';

void main() {
  group('CreateArticleBloc', () {
    test('emits submitting and success when an article is created', () async {
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(InMemoryArticleRepository()),
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

    test('returns to initial when the editor is reset', () async {
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(InMemoryArticleRepository()),
      );

      final emittedStatesFuture = bloc.stream.take(1).toList();

      bloc.add(const ResetCreateArticle());

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.initial);
      expect(emittedStates[0].article, isNull);

      await bloc.close();
    });

    test('emits submitting and failure when article creation throws', () async {
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(
          FakeArticleRepository(shouldThrowOnCreateArticle: true),
        ),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Broken flow',
          description: 'The repository throws during creation.',
          content: 'The bloc should surface a failure state.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.submitting);
      expect(emittedStates[1].status, CreateArticleStatus.failure);
      expect(
        emittedStates[1].errorMessage,
        'No se pudo crear el articulo.',
      );

      await bloc.close();
    });
  });
}
