import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

abstract class SavedArticlesEvent extends Equatable {
  const SavedArticlesEvent();

  @override
  List<Object?> get props => [];
}

class SavedArticlesRequested extends SavedArticlesEvent {
  const SavedArticlesRequested();
}

class SavedArticleStored extends SavedArticlesEvent {
  final ArticleEntity article;

  const SavedArticleStored(this.article);

  @override
  List<Object?> get props => [article];
}

class SavedArticleDeleted extends SavedArticlesEvent {
  final ArticleEntity article;

  const SavedArticleDeleted(this.article);

  @override
  List<Object?> get props => [article];
}
