import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';

void main() {
  late AppDatabase appDatabase;
  late ArticleDraftLocalDataSource dataSource;

  const draftKey = 'create_article';

  setUp(() async {
    appDatabase = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    dataSource = ArticleDraftLocalDataSourceImpl(
      articleDraftDao: appDatabase.articleDraftDao,
    );
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('persists and loads a draft', () async {
    final draft = ArticleDraftEntity(
      draftKey: draftKey,
      authorName: 'Hugo',
      title: 'Saved draft',
      description: 'Draft summary',
      content: 'Draft content',
      updatedAt: DateTime(2026, 3, 26),
    );

    await dataSource.saveDraft(draft);

    final loadedDraft = await dataSource.getDraft(draftKey);

    expect(loadedDraft, draft);
  });

  test('restores text but drops thumbnail when the local file is missing',
      () async {
    final draft = ArticleDraftEntity(
      draftKey: draftKey,
      authorName: 'Hugo',
      title: 'Draft with broken thumbnail',
      description: 'Draft summary',
      content: 'Draft content',
      thumbnailPath: 'media/articles/draft/thumbnail.jpg',
      thumbnailLocalPath: 'C:/missing/thumbnail.jpg',
      fileName: 'thumbnail.jpg',
      updatedAt: DateTime(2026, 3, 26),
    );

    await dataSource.saveDraft(draft);

    final loadedDraft = await dataSource.getDraft(draftKey);

    expect(loadedDraft?.title, 'Draft with broken thumbnail');
    expect(loadedDraft?.thumbnailPath, 'media/articles/draft/thumbnail.jpg');
    expect(loadedDraft?.thumbnailLocalPath, isNull);
    expect(loadedDraft?.fileName, isNull);
  });

  test('clears a saved draft by key', () async {
    final draft = ArticleDraftEntity(
      draftKey: draftKey,
      authorName: 'Hugo',
      title: 'Temporary draft',
      description: 'Draft summary',
      content: 'Draft content',
      updatedAt: DateTime(2026, 3, 26),
    );

    await dataSource.saveDraft(draft);

    await dataSource.clearDraft(draftKey);

    final loadedDraft = await dataSource.getDraft(draftKey);

    expect(loadedDraft, isNull);
  });
}
