import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/create_article.dart';
import '../../../domain/usecases/select_article_thumbnail.dart';
import 'create_article_event.dart';
import 'create_article_state.dart';

class CreateArticleBloc extends Bloc<CreateArticleEvent, CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;
  final SelectArticleThumbnailUseCase _selectArticleThumbnailUseCase;

  CreateArticleBloc(
    this._createArticleUseCase,
    this._selectArticleThumbnailUseCase,
  ) : super(const CreateArticleState()) {
    on<SelectArticleThumbnailRequested>(_onSelectArticleThumbnailRequested);
    on<ClearSelectedArticleThumbnail>(_onClearSelectedArticleThumbnail);
    on<SubmitCreateArticle>(_onSubmitCreateArticle);
    on<ResetCreateArticle>(_onResetCreateArticle);
  }

  Future<void> _onSelectArticleThumbnailRequested(
    SelectArticleThumbnailRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CreateArticleStatus.initial,
        isPickingThumbnail: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final selectedThumbnail = await _selectArticleThumbnailUseCase();

      if (selectedThumbnail == null) {
        emit(
          state.copyWith(
            status: CreateArticleStatus.initial,
            isPickingThumbnail: false,
            clearErrorMessage: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: CreateArticleStatus.initial,
          isPickingThumbnail: false,
          selectedThumbnail: selectedThumbnail,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CreateArticleStatus.failure,
          isPickingThumbnail: false,
          errorMessage: 'No se pudo seleccionar la miniatura.',
        ),
      );
    }
  }

  void _onClearSelectedArticleThumbnail(
    ClearSelectedArticleThumbnail event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(
      state.copyWith(
        status: CreateArticleStatus.initial,
        clearSelectedThumbnail: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onSubmitCreateArticle(
    SubmitCreateArticle event,
    Emitter<CreateArticleState> emit,
  ) async {
    if (state.selectedThumbnail == null) {
      emit(
        state.copyWith(
          status: CreateArticleStatus.failure,
          errorMessage: 'Selecciona una miniatura antes de publicar.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: CreateArticleStatus.submitting,
        clearErrorMessage: true,
      ),
    );

    try {
      // Keep the publishing transition visible in the mocked flow.
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final createdArticle = await _createArticleUseCase(
        params: CreateArticleParams(
          authorName: event.authorName,
          title: event.title,
          description: event.description,
          content: event.content,
        ),
      );

      emit(
        state.copyWith(
          status: CreateArticleStatus.success,
          article: createdArticle,
          isPickingThumbnail: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CreateArticleStatus.failure,
          errorMessage: 'No se pudo crear el articulo.',
        ),
      );
    }
  }

  void _onResetCreateArticle(
    ResetCreateArticle event,
    Emitter<CreateArticleState> emit,
  ) {
    emit(const CreateArticleState());
  }
}
