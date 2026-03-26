import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

enum ArticlesStatus { initial, loading, success, failure }

class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<ArticleEntity> articles;
  final String? errorMessage;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, articles, errorMessage];
}
