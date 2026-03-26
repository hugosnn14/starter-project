import 'package:equatable/equatable.dart';

class ArticleThumbnailEntity extends Equatable {
  final String path;
  final String? fileName;

  const ArticleThumbnailEntity({
    required this.path,
    this.fileName,
  });

  @override
  List<Object?> get props => [path, fileName];
}
