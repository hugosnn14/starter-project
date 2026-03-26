import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_thumbnail.dart';

abstract class ArticleThumbnailPickerDataSource {
  Future<ArticleThumbnailModel?> pickThumbnail();
}

class ArticleThumbnailPickerDataSourceImpl
    implements ArticleThumbnailPickerDataSource {
  ArticleThumbnailPickerDataSourceImpl({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<ArticleThumbnailModel?> pickThumbnail() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null) {
      return null;
    }

    return ArticleThumbnailModel.fromXFile(file);
  }
}
