import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';

class ArticleDraftEntity extends Equatable {
  const ArticleDraftEntity({
    required this.draftKey,
    required this.authorName,
    required this.title,
    required this.description,
    required this.content,
    required this.updatedAt,
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
  final DateTime updatedAt;

  ArticleThumbnailEntity? get selectedThumbnail {
    final localPath = thumbnailLocalPath;
    if (localPath == null || localPath.isEmpty) {
      return null;
    }

    return ArticleThumbnailEntity(
      path: localPath,
      fileName: fileName,
    );
  }

  ArticleDraftEntity copyWith({
    String? draftKey,
    String? authorName,
    String? title,
    String? description,
    String? content,
    String? thumbnailPath,
    bool clearThumbnailPath = false,
    String? thumbnailLocalPath,
    bool clearThumbnailLocalPath = false,
    String? fileName,
    bool clearFileName = false,
    DateTime? updatedAt,
  }) {
    return ArticleDraftEntity(
      draftKey: draftKey ?? this.draftKey,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnailPath:
          clearThumbnailPath ? null : thumbnailPath ?? this.thumbnailPath,
      thumbnailLocalPath: clearThumbnailLocalPath
          ? null
          : thumbnailLocalPath ?? this.thumbnailLocalPath,
      fileName: clearFileName ? null : fileName ?? this.fileName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        draftKey,
        authorName,
        title,
        description,
        content,
        thumbnailPath,
        thumbnailLocalPath,
        fileName,
        updatedAt,
      ];
}
