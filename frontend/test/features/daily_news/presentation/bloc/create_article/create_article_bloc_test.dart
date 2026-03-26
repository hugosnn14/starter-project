import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/select_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';
import '../../../../../helpers/fake_article_repository.dart';

void main() {
  const pickedThumbnail = ArticleThumbnailEntity(
    path: '/tmp/thumbnail.jpg',
    fileName: 'thumbnail.jpg',
  );

  group('CreateArticleBloc', () {
    test('selects a thumbnail and emits success when the article is created',
        () async {
      final repository = FakeArticleRepository(
        pickedThumbnail: pickedThumbnail,
      );
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(4).toList();

      bloc.add(const SelectArticleThumbnailRequested());

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Create flow works',
          description: 'The form writes into the in-memory repository.',
          content: 'After saving, the new article should be available.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].isPickingThumbnail, isTrue);
      expect(emittedStates[1].selectedThumbnail, pickedThumbnail);
      expect(emittedStates[2].status, CreateArticleStatus.submitting);
      expect(emittedStates[3].status, CreateArticleStatus.success);
      expect(emittedStates[3].article, isNotNull);
      expect(emittedStates[3].article!.title, 'Create flow works');

      await bloc.close();
    });

    test('returns to initial when the editor is reset', () async {
      final repository = FakeArticleRepository();
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(1).toList();

      bloc.add(const ResetCreateArticle());

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.initial);
      expect(emittedStates[0].article, isNull);

      await bloc.close();
    });

    test('emits failure when publishing without a selected thumbnail',
        () async {
      final repository = FakeArticleRepository();
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(1).toList();

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Missing thumbnail',
          description: 'The editor should block publishing first.',
          content: 'A thumbnail is now required before the mock publish step.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.failure);
      expect(
        emittedStates[0].errorMessage,
        'Selecciona una miniatura antes de publicar.',
      );

      await bloc.close();
    });

    test('emits submitting and failure when article creation throws', () async {
      final repository = FakeArticleRepository(
        pickedThumbnail: pickedThumbnail,
        shouldThrowOnCreateArticle: true,
      );
      final bloc = CreateArticleBloc(
        CreateArticleUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(4).toList();

      bloc.add(const SelectArticleThumbnailRequested());

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Broken flow',
          description: 'The repository throws during creation.',
          content: 'The bloc should surface a failure state.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].isPickingThumbnail, isTrue);
      expect(emittedStates[1].selectedThumbnail, pickedThumbnail);
      expect(emittedStates[2].status, CreateArticleStatus.submitting);
      expect(emittedStates[3].status, CreateArticleStatus.failure);
      expect(
        emittedStates[3].errorMessage,
        'No se pudo crear el articulo.',
      );

      await bloc.close();
    });
  });
}
