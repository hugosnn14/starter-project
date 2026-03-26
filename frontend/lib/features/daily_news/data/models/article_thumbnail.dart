import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';

class ArticleThumbnailModel extends ArticleThumbnailEntity {
  const ArticleThumbnailModel({
    required super.path,
    super.fileName,
  });

  factory ArticleThumbnailModel.fromXFile(XFile file) {
    return ArticleThumbnailModel(
      path: file.path,
      fileName: file.name,
    );
  }
}
