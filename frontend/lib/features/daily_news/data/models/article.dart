import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    String? id,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? thumbnailPath,
    String? publishedAt,
    String? content,
    String? status,
  }) : super(
          id: id,
          author: author,
          title: title,
          description: description,
          url: url,
          urlToImage: urlToImage,
          thumbnailPath: thumbnailPath,
          publishedAt: publishedAt,
          content: content,
          status: status,
        );

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as String?,
      author: map['author'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      url: map['url'] ?? "",
      urlToImage: map['urlToImage'] != null && map['urlToImage'] != ""
          ? map['urlToImage']
          : kDefaultImage,
      thumbnailPath: map['thumbnailPath'] as String?,
      publishedAt: map['publishedAt'] ?? "",
      content: map['content'] ?? "",
      status: map['status'] as String?,
    );
  }

  factory ArticleModel.fromFirestoreData(
    Map<String, dynamic> map, {
    String? thumbnailUrl,
  }) {
    return ArticleModel(
      id: map['id'] as String?,
      author: map['authorName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      url: map['sourceUrl'] as String?,
      urlToImage: thumbnailUrl ?? kDefaultImage,
      thumbnailPath: map['thumbnailPath'] as String?,
      publishedAt: _formatPublishedAt(map['publishedAt']),
      content: map['content'] as String? ?? '',
      status: map['status'] as String? ?? 'published',
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id,
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      thumbnailPath: entity.thumbnailPath,
      publishedAt: entity.publishedAt,
      content: entity.content,
      status: entity.status,
    );
  }

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      thumbnailPath: thumbnailPath,
      publishedAt: publishedAt,
      content: content,
      status: status,
    );
  }

  static String _formatPublishedAt(Object? value) {
    if (value is DateTime) {
      return DateFormat('yyyy-MM-dd').format(value);
    }

    if (value is String) {
      return value;
    }

    return '';
  }
}
