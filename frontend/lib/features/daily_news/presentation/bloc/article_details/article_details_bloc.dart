import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_article_by_id.dart';
import 'article_details_event.dart';
import 'article_details_state.dart';

class ArticleDetailsBloc
    extends Bloc<ArticleDetailsEvent, ArticleDetailsState> {
  final GetArticleByIdUseCase _getArticleByIdUseCase;

  ArticleDetailsBloc(this._getArticleByIdUseCase)
      : super(const ArticleDetailsState()) {
    on<LoadArticleDetails>(_onLoadArticleDetails);
  }

  Future<void> _onLoadArticleDetails(
    LoadArticleDetails event,
    Emitter<ArticleDetailsState> emit,
  ) async {
    emit(
      const ArticleDetailsState(
        status: ArticleDetailsStatus.loading,
      ),
    );

    try {
      final article = await _getArticleByIdUseCase(params: event.articleId);

      if (article == null) {
        emit(
          const ArticleDetailsState(
            status: ArticleDetailsStatus.notFound,
            errorMessage: 'No se encontro el articulo.',
          ),
        );
        return;
      }

      emit(
        ArticleDetailsState(
          status: ArticleDetailsStatus.success,
          article: article,
        ),
      );
    } catch (_) {
      emit(
        const ArticleDetailsState(
          status: ArticleDetailsStatus.failure,
          errorMessage: 'No se pudo cargar el articulo.',
        ),
      );
    }
  }
}
