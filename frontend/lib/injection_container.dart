import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_storage_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/select_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  sl.registerLazySingleton<ArticleThumbnailPickerDataSource>(
    () => ArticleThumbnailPickerDataSourceImpl(),
  );
  sl.registerLazySingleton<ArticleAuthRemoteDataSource>(
    () => ArticleAuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ArticleFirestoreRemoteDataSource>(
    () => ArticleFirestoreRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ArticleStorageRemoteDataSource>(
    () => ArticleStorageRemoteDataSourceImpl(),
  );
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      authRemoteDataSource: sl(),
      firestoreRemoteDataSource: sl(),
      storageRemoteDataSource: sl(),
      thumbnailPickerDataSource: sl(),
    ),
  );

  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));
  sl.registerSingleton<SelectArticleThumbnailUseCase>(
    SelectArticleThumbnailUseCase(sl()),
  );
  sl.registerSingleton<GetArticlesUseCase>(GetArticlesUseCase(sl()));
  sl.registerSingleton<GetArticleByIdUseCase>(GetArticleByIdUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));

  // Production DI only wires the Firebase-backed article flow.
  // Test fixtures and legacy implementations stay outside this container.
  sl.registerFactory<ArticlesBloc>(() => ArticlesBloc(sl()));
  sl.registerFactory<CreateArticleBloc>(() => CreateArticleBloc(sl(), sl()));
  sl.registerFactory<ArticleDetailsBloc>(() => ArticleDetailsBloc(sl()));
  sl.registerFactory<SavedArticlesBloc>(
      () => SavedArticlesBloc(sl(), sl(), sl()));
}
