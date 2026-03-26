import 'package:equatable/equatable.dart';

abstract class ArticleDetailsEvent extends Equatable {
  const ArticleDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticleDetails extends ArticleDetailsEvent {
  final int articleId;

  const LoadArticleDetails(this.articleId);

  @override
  List<Object?> get props => [articleId];
}
