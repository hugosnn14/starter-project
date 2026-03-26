import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_saved_article.dart';
import '../../../domain/usecases/remove_article.dart';
import '../../../domain/usecases/save_article.dart';
import 'saved_articles_event.dart';
import 'saved_articles_state.dart';

class SavedArticlesBloc extends Bloc<SavedArticlesEvent, SavedArticlesState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final SaveArticleUseCase _saveArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;

  SavedArticlesBloc(
    this._getSavedArticleUseCase,
    this._saveArticleUseCase,
    this._removeArticleUseCase,
  ) : super(const SavedArticlesState()) {
    on<SavedArticlesRequested>(_onSavedArticlesRequested);
    on<SavedArticleStored>(_onSavedArticleStored);
    on<SavedArticleDeleted>(_onSavedArticleDeleted);
  }

  Future<void> _onSavedArticlesRequested(
    SavedArticlesRequested event,
    Emitter<SavedArticlesState> emit,
  ) async {
    await _emitSavedArticles(emit);
  }

  Future<void> _onSavedArticleStored(
    SavedArticleStored event,
    Emitter<SavedArticlesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.loading,
          errorMessage: null,
        ),
      );
      await _saveArticleUseCase(params: event.article);
      final articles = await _getSavedArticleUseCase();
      emit(
        SavedArticlesState(
          status: SavedArticlesStatus.success,
          articles: articles,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.failure,
          errorMessage: 'No se pudo guardar el articulo.',
        ),
      );
    }
  }

  Future<void> _onSavedArticleDeleted(
    SavedArticleDeleted event,
    Emitter<SavedArticlesState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.loading,
          errorMessage: null,
        ),
      );
      await _removeArticleUseCase(params: event.article);
      final articles = await _getSavedArticleUseCase();
      emit(
        SavedArticlesState(
          status: SavedArticlesStatus.success,
          articles: articles,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.failure,
          errorMessage: 'No se pudo eliminar el articulo.',
        ),
      );
    }
  }

  Future<void> _emitSavedArticles(Emitter<SavedArticlesState> emit) async {
    try {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.loading,
          errorMessage: null,
        ),
      );
      final articles = await _getSavedArticleUseCase();
      emit(
        SavedArticlesState(
          status: SavedArticlesStatus.success,
          articles: articles,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: SavedArticlesStatus.failure,
          errorMessage: 'No se pudieron cargar los articulos guardados.',
        ),
      );
    }
  }
}
