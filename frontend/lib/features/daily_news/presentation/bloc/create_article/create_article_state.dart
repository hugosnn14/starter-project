import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_draft.dart';
import '../../../domain/entities/article_thumbnail.dart';

enum CreateArticleStatus { initial, submitting, success, failure }

class CreateArticleState extends Equatable {
  static const String defaultDraftKey = 'create_article';

  final CreateArticleStatus status;
  final String draftKey;
  final ArticleEntity? article;
  final ArticleDraftEntity? restoredDraft;
  final bool hasLoadedDraft;
  final ArticleThumbnailEntity? selectedThumbnail;
  final bool isPickingThumbnail;
  final String? errorMessage;

  const CreateArticleState({
    this.status = CreateArticleStatus.initial,
    this.draftKey = defaultDraftKey,
    this.article,
    this.restoredDraft,
    this.hasLoadedDraft = false,
    this.selectedThumbnail,
    this.isPickingThumbnail = false,
    this.errorMessage,
  });

  CreateArticleState copyWith({
    CreateArticleStatus? status,
    String? draftKey,
    ArticleEntity? article,
    bool clearArticle = false,
    ArticleDraftEntity? restoredDraft,
    bool clearRestoredDraft = false,
    bool? hasLoadedDraft,
    ArticleThumbnailEntity? selectedThumbnail,
    bool clearSelectedThumbnail = false,
    bool? isPickingThumbnail,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CreateArticleState(
      status: status ?? this.status,
      draftKey: draftKey ?? this.draftKey,
      article: clearArticle ? null : article ?? this.article,
      restoredDraft:
          clearRestoredDraft ? null : restoredDraft ?? this.restoredDraft,
      hasLoadedDraft: hasLoadedDraft ?? this.hasLoadedDraft,
      selectedThumbnail: clearSelectedThumbnail
          ? null
          : selectedThumbnail ?? this.selectedThumbnail,
      isPickingThumbnail: isPickingThumbnail ?? this.isPickingThumbnail,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        draftKey,
        article,
        restoredDraft,
        hasLoadedDraft,
        selectedThumbnail,
        isPickingThumbnail,
        errorMessage,
      ];
}
