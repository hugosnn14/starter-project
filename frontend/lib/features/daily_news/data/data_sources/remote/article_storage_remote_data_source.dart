import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_thumbnail.dart';

abstract class ArticleStorageRemoteDataSource {
  Future<void> uploadThumbnail({
    required String thumbnailPath,
    required ArticleThumbnailEntity thumbnail,
  });

  Future<String> getDownloadUrl(String thumbnailPath);
}

class ArticleStorageRemoteDataSourceImpl
    implements ArticleStorageRemoteDataSource {
  ArticleStorageRemoteDataSourceImpl({
    FirebaseStorage? firebaseStorage,
  }) : _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _firebaseStorage;

  @override
  Future<void> uploadThumbnail({
    required String thumbnailPath,
    required ArticleThumbnailEntity thumbnail,
  }) async {
    await _firebaseStorage.ref(thumbnailPath).putFile(
          File(thumbnail.path),
          SettableMetadata(
            contentType: _resolveContentType(thumbnail),
          ),
        );
  }

  @override
  Future<String> getDownloadUrl(String thumbnailPath) {
    return _firebaseStorage.ref(thumbnailPath).getDownloadURL();
  }

  String _resolveContentType(ArticleThumbnailEntity thumbnail) {
    final source = (thumbnail.fileName ?? thumbnail.path).toLowerCase();
    final dotIndex = source.lastIndexOf('.');
    final extension = dotIndex == -1 || dotIndex == source.length - 1
        ? 'jpg'
        : source.substring(dotIndex + 1);

    switch (extension) {
      case 'jpeg':
      case 'jpg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
