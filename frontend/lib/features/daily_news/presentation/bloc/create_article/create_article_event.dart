import 'package:equatable/equatable.dart';

abstract class CreateArticleEvent extends Equatable {
  const CreateArticleEvent();

  @override
  List<Object?> get props => [];
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
