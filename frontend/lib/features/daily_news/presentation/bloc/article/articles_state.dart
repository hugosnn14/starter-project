import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

enum ArticlesStatus { initial, loading, success, failure, submitting }

class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<ArticleEntity> articles;
  final String? errorMessage;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.errorMessage,
  });

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<ArticleEntity>? articles,
    String? errorMessage,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, errorMessage];
}
