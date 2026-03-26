import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final String? id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? thumbnailPath;
  final String? publishedAt;
  final String? content;
  final String? status;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.thumbnailPath,
    this.publishedAt,
    this.content,
    this.status,
  });

  @override
  List<Object?> get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      thumbnailPath,
      publishedAt,
      content,
      status,
    ];
  }
}
