import 'package:equatable/equatable.dart';

abstract class ArticlesEvent extends Equatable {
  const ArticlesEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticles extends ArticlesEvent {
  const LoadArticles();
}

class CreateArticleRequested extends ArticlesEvent {
  final String authorName;
  final String title;
  final String description;
  final String content;

  const CreateArticleRequested({
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  List<Object?> get props => [authorName, title, description, content];
}
