import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final GetArticlesUseCase _getArticlesUseCase;

  ArticlesBloc(this._getArticlesUseCase) : super(const ArticlesState()) {
    on<LoadArticles>(_onLoadArticles);
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
}
