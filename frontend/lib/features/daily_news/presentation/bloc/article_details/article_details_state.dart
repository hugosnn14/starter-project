import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum ArticleDetailsStatus { initial, loading, success, notFound, failure }

class ArticleDetailsState extends Equatable {
  final ArticleDetailsStatus status;
  final ArticleEntity? article;
  final String? errorMessage;

  const ArticleDetailsState({
    this.status = ArticleDetailsStatus.initial,
    this.article,
    this.errorMessage,
  });

  ArticleDetailsState copyWith({
    ArticleDetailsStatus? status,
    ArticleEntity? article,
    String? errorMessage,
  }) {
    return ArticleDetailsState(
      status: status ?? this.status,
      article: article ?? this.article,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, article, errorMessage];
}
