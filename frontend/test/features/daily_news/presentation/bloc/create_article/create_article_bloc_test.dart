import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/clear_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/select_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
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
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
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
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
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
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(1).toList();

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Missing thumbnail',
          description: 'The editor should block publishing first.',
          content: 'A thumbnail is now required before publishing starts.',
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
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
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

    test('surfaces a StateError message when publishing fails with context',
        () async {
      final repository = FakeArticleRepository(
        pickedThumbnail: pickedThumbnail,
        createArticleError: StateError(
          'Firebase Auth no permite el acceso anonimo en este proyecto.',
        ),
      );
      final bloc = CreateArticleBloc(
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(4).toList();

      bloc.add(const SelectArticleThumbnailRequested());

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Auth blocked',
          description: 'Publishing should explain why it failed.',
          content: 'The user should get the contextual error message.',
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[2].status, CreateArticleStatus.submitting);
      expect(emittedStates[3].status, CreateArticleStatus.failure);
      expect(
        emittedStates[3].errorMessage,
        'Firebase Auth no permite el acceso anonimo en este proyecto.',
      );

      await bloc.close();
    });

    test('loads a persisted draft into state', () async {
      final repository = FakeArticleRepository(
        draft: ArticleDraftEntity(
          draftKey: CreateArticleState.defaultDraftKey,
          authorName: 'Hugo',
          title: 'Recovered draft',
          description: 'Draft summary',
          content: 'Draft body',
          thumbnailLocalPath: pickedThumbnail.path,
          fileName: pickedThumbnail.fileName,
          updatedAt: DateTime(2026, 3, 26),
        ),
      );
      final bloc = CreateArticleBloc(
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(1).toList();

      bloc.add(
        const LoadArticleDraftRequested(
          draftKey: CreateArticleState.defaultDraftKey,
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].hasLoadedDraft, isTrue);
      expect(emittedStates[0].restoredDraft?.title, 'Recovered draft');
      expect(emittedStates[0].selectedThumbnail, pickedThumbnail);

      await bloc.close();
    });

    test('updates an article in edit mode without requiring a new thumbnail',
        () async {
      final repository = FakeArticleRepository(
        articles: const [
          ArticleEntity(
            id: '1',
            author: 'Hugo',
            title: 'Original title',
            description: 'Original description',
            content: 'Original content',
            thumbnailPath: 'media/articles/1/thumbnail.jpg',
            status: 'published',
          ),
        ],
      );
      final bloc = CreateArticleBloc(
        ClearArticleDraftUseCase(repository),
        CreateArticleUseCase(repository),
        GetArticleDraftUseCase(repository),
        SaveArticleDraftUseCase(repository),
        SelectArticleThumbnailUseCase(repository),
        UpdateArticleUseCase(repository),
      );

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(
        const SubmitCreateArticle(
          authorName: 'Hugo',
          title: 'Updated title',
          description: 'Updated description',
          content: 'Updated content',
          articleId: '1',
          isEditing: true,
        ),
      );

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, CreateArticleStatus.submitting);
      expect(emittedStates[1].status, CreateArticleStatus.success);
      expect(emittedStates[1].article?.id, '1');
      expect(emittedStates[1].article?.title, 'Updated title');

      await bloc.close();
    });
  });
}
