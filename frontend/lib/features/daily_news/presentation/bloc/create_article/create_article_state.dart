import 'package:equatable/equatable.dart';

import '../../../domain/entities/article.dart';

enum CreateArticleStatus { initial, submitting, success, failure }

class CreateArticleState extends Equatable {
  final CreateArticleStatus status;
  final ArticleEntity? article;
  final String? errorMessage;

  const CreateArticleState({
    this.status = CreateArticleStatus.initial,
    this.article,
    this.errorMessage,
  });

  CreateArticleState copyWith({
    CreateArticleStatus? status,
    ArticleEntity? article,
    String? errorMessage,
  }) {
    return CreateArticleState(
      status: status ?? this.status,
      article: article ?? this.article,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, article, errorMessage];
}
