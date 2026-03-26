import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum SavedArticlesStatus { initial, loading, success, failure }

class SavedArticlesState extends Equatable {
  final SavedArticlesStatus status;
  final List<ArticleEntity> articles;
  final String? errorMessage;

  const SavedArticlesState({
    this.status = SavedArticlesStatus.initial,
    this.articles = const [],
    this.errorMessage,
  });

  SavedArticlesState copyWith({
    SavedArticlesStatus? status,
    List<ArticleEntity>? articles,
    String? errorMessage,
  }) {
    return SavedArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, errorMessage];
}
