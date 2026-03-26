import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_thumbnail.dart';

enum CreateArticleStatus { initial, submitting, success, failure }

class CreateArticleState extends Equatable {
  final CreateArticleStatus status;
  final ArticleEntity? article;
  final ArticleThumbnailEntity? selectedThumbnail;
  final bool isPickingThumbnail;
  final String? errorMessage;

  const CreateArticleState({
    this.status = CreateArticleStatus.initial,
    this.article,
    this.selectedThumbnail,
    this.isPickingThumbnail = false,
    this.errorMessage,
  });

  CreateArticleState copyWith({
    CreateArticleStatus? status,
    ArticleEntity? article,
    bool clearArticle = false,
    ArticleThumbnailEntity? selectedThumbnail,
    bool clearSelectedThumbnail = false,
    bool? isPickingThumbnail,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CreateArticleState(
      status: status ?? this.status,
      article: clearArticle ? null : article ?? this.article,
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
        article,
        selectedThumbnail,
        isPickingThumbnail,
        errorMessage,
      ];
}
