import 'package:equatable/equatable.dart';

abstract class CreateArticleEvent extends Equatable {
  const CreateArticleEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticleDraftRequested extends CreateArticleEvent {
  const LoadArticleDraftRequested({
    required this.draftKey,
  });

  final String draftKey;

  @override
  List<Object?> get props => [draftKey];
}

class PersistArticleDraftRequested extends CreateArticleEvent {
  const PersistArticleDraftRequested({
    required this.draftKey,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    this.thumbnailPath,
    this.clearSelectedThumbnail = false,
  });

  final String draftKey;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final String? thumbnailPath;
  final bool clearSelectedThumbnail;

  @override
  List<Object?> get props => [
        draftKey,
        authorName,
        title,
        description,
        content,
        thumbnailPath,
        clearSelectedThumbnail,
      ];
}

class SelectArticleThumbnailRequested extends CreateArticleEvent {
  const SelectArticleThumbnailRequested();
}

class ClearSelectedArticleThumbnail extends CreateArticleEvent {
  const ClearSelectedArticleThumbnail();
}

class SubmitCreateArticle extends CreateArticleEvent {
  final String authorName;
  final String title;
  final String description;
  final String content;

  const SubmitCreateArticle({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  List<Object?> get props => [authorName, title, description, content];
}

class ResetCreateArticle extends CreateArticleEvent {
  const ResetCreateArticle();
}
