import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_draft.dart';

@Entity(tableName: 'article_draft', primaryKeys: ['draftKey'])
class ArticleDraftModel {
  const ArticleDraftModel({
    required this.draftKey,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.updatedAtEpochMs,
    this.thumbnailPath,
    this.thumbnailLocalPath,
    this.fileName,
  });

  final String draftKey;
  final String authorName;
  final String title;
  final String description;
  final String content;
  final String? thumbnailPath;
  final String? thumbnailLocalPath;
  final String? fileName;
  final int updatedAtEpochMs;

  factory ArticleDraftModel.fromEntity(ArticleDraftEntity entity) {
    return ArticleDraftModel(
      draftKey: entity.draftKey,
      authorName: entity.authorName,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      thumbnailPath: entity.thumbnailPath,
      thumbnailLocalPath: entity.thumbnailLocalPath,
      fileName: entity.fileName,
      updatedAtEpochMs: entity.updatedAt.millisecondsSinceEpoch,
    );
  }

  ArticleDraftEntity toEntity() {
    return ArticleDraftEntity(
      draftKey: draftKey,
      authorName: authorName,
      title: title,
      description: description,
      content: content,
      thumbnailPath: thumbnailPath,
      thumbnailLocalPath: thumbnailLocalPath,
      fileName: fileName,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtEpochMs),
    );
  }
}
