import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_draft_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';

abstract class ArticleDraftLocalDataSource {
  Future<ArticleDraftEntity?> getDraft(String draftKey);

  Future<void> saveDraft(ArticleDraftEntity draft);

  Future<void> clearDraft(String draftKey);
}

class ArticleDraftLocalDataSourceImpl implements ArticleDraftLocalDataSource {
  ArticleDraftLocalDataSourceImpl({
    required ArticleDraftDao articleDraftDao,
  }) : _articleDraftDao = articleDraftDao;

  final ArticleDraftDao _articleDraftDao;

  @override
  Future<ArticleDraftEntity?> getDraft(String draftKey) async {
    final model = await _articleDraftDao.getDraftByKey(draftKey);

    if (model == null) {
      return null;
    }

    final entity = model.toEntity();
    final thumbnailLocalPath = entity.thumbnailLocalPath;

    if (thumbnailLocalPath == null || thumbnailLocalPath.isEmpty) {
      return entity;
    }

    if (await File(thumbnailLocalPath).exists()) {
      return entity;
    }

    return entity.copyWith(
      clearThumbnailLocalPath: true,
      clearFileName: true,
    );
  }

  @override
  Future<void> saveDraft(ArticleDraftEntity draft) {
    return _articleDraftDao.saveDraft(
      ArticleDraftModel.fromEntity(draft),
    );
  }

  @override
  Future<void> clearDraft(String draftKey) {
    return _articleDraftDao.deleteDraftByKey(draftKey);
  }
}
