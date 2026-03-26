import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final GetArticlesUseCase _getArticlesUseCase;
  final CreateArticleUseCase _createArticleUseCase;

  ArticlesBloc(
    this._getArticlesUseCase,
    this._createArticleUseCase,
  ) : super(const ArticlesState()) {
    on<LoadArticles>(_onLoadArticles);
    on<CreateArticleRequested>(_onCreateArticleRequested);
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(const ArticlesState(status: ArticlesStatus.loading));

    try {
      final articles = await _getArticlesUseCase();
      emit(
        ArticlesState(
          status: ArticlesStatus.success,
          articles: articles,
        ),
      );
    } catch (_) {
      emit(
        const ArticlesState(
          status: ArticlesStatus.failure,
          errorMessage: 'No se pudieron cargar los articulos.',
        ),
      );
    }
  }

  Future<void> _onCreateArticleRequested(
    CreateArticleRequested event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ArticlesStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await _createArticleUseCase(
        params: CreateArticleParams(
          authorName: event.authorName,
          title: event.title,
          description: event.description,
          content: event.content,
        ),
      );

      final updatedArticles = await _getArticlesUseCase();

      emit(
        ArticlesState(
          status: ArticlesStatus.success,
          articles: updatedArticles,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ArticlesStatus.failure,
          errorMessage: 'No se pudo crear el articulo.',
        ),
      );
    }
  }
}
