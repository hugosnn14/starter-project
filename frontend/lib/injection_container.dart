import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_draft_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_draft_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/article_thumbnail_picker_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_local_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_firestore_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_news_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/article_storage_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/archive_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/clear_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article_by_id.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article_draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/select_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final appDatabase = await $FloorAppDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1To2]).build();
  sl.registerSingleton<AppDatabase>(appDatabase);
  sl.registerLazySingleton<ArticleDao>(
    () => sl<AppDatabase>().articleDAO,
  );
  sl.registerLazySingleton<ArticleDraftDao>(
    () => sl<AppDatabase>().articleDraftDao,
  );
  sl.registerLazySingleton<ArticleThumbnailPickerDataSource>(
    () => ArticleThumbnailPickerDataSourceImpl(),
  );
  sl.registerLazySingleton<ArticleDraftLocalDataSource>(
    () => ArticleDraftLocalDataSourceImpl(articleDraftDao: sl()),
  );
  sl.registerLazySingleton<SavedArticleLocalDataSource>(
    () => SavedArticleLocalDataSourceImpl(articleDao: sl()),
  );
  sl.registerLazySingleton<ArticleAuthRemoteDataSource>(
    () => ArticleAuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<NewsApiService>(
    () => NewsApiService(sl<Dio>()),
  );
  sl.registerLazySingleton<ArticleFirestoreRemoteDataSource>(
    () => ArticleFirestoreRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ArticleNewsRemoteDataSource>(
    () => ArticleNewsRemoteDataSourceImpl(newsApiService: sl()),
  );
  sl.registerLazySingleton<ArticleStorageRemoteDataSource>(
    () => ArticleStorageRemoteDataSourceImpl(),
  );
  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(
      authRemoteDataSource: sl(),
      articleDraftLocalDataSource: sl(),
      firestoreRemoteDataSource: sl(),
      newsRemoteDataSource: sl(),
      savedArticleLocalDataSource: sl(),
      storageRemoteDataSource: sl(),
      thumbnailPickerDataSource: sl(),
    ),
  );

  sl.registerSingleton<CreateArticleUseCase>(CreateArticleUseCase(sl()));
  sl.registerSingleton<SelectArticleThumbnailUseCase>(
    SelectArticleThumbnailUseCase(sl()),
  );
  sl.registerSingleton<ArchiveArticleUseCase>(ArchiveArticleUseCase(sl()));
  sl.registerSingleton<GetArticlesUseCase>(GetArticlesUseCase(sl()));
  sl.registerSingleton<GetArticleByIdUseCase>(GetArticleByIdUseCase(sl()));
  sl.registerSingleton<GetArticleDraftUseCase>(GetArticleDraftUseCase(sl()));
  sl.registerSingleton<GetMyArticlesUseCase>(GetMyArticlesUseCase(sl()));
  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));
  sl.registerSingleton<SaveArticleDraftUseCase>(SaveArticleDraftUseCase(sl()));
  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));
  sl.registerSingleton<ClearArticleDraftUseCase>(
      ClearArticleDraftUseCase(sl()));
  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<UpdateArticleUseCase>(UpdateArticleUseCase(sl()));

  // Production DI only wires the Firebase-backed article flow.
  // Test fixtures and legacy implementations stay outside this container.
  sl.registerFactory<ArticlesBloc>(() => ArticlesBloc(sl()));
  sl.registerFactory<CreateArticleBloc>(
    () => CreateArticleBloc(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<ArticleDetailsBloc>(() => ArticleDetailsBloc(sl()));
  sl.registerFactory<SavedArticlesBloc>(
      () => SavedArticlesBloc(sl(), sl(), sl()));
}
