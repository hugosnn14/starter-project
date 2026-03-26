import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_draft.dart';
import '../../../domain/usecases/clear_article_draft.dart';
import '../../../domain/usecases/create_article.dart';
import '../../../domain/usecases/get_article_draft.dart';
import '../../../domain/usecases/save_article_draft.dart';
import '../../../domain/usecases/select_article_thumbnail.dart';
import '../../../domain/usecases/update_article.dart';
import 'create_article_event.dart';
import 'create_article_state.dart';

class CreateArticleBloc extends Bloc<CreateArticleEvent, CreateArticleState> {
  final ClearArticleDraftUseCase _clearArticleDraftUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final GetArticleDraftUseCase _getArticleDraftUseCase;
  final SaveArticleDraftUseCase _saveArticleDraftUseCase;
  final SelectArticleThumbnailUseCase _selectArticleThumbnailUseCase;
  final UpdateArticleUseCase _updateArticleUseCase;

  CreateArticleBloc(
    this._clearArticleDraftUseCase,
    this._createArticleUseCase,
    this._getArticleDraftUseCase,
    this._saveArticleDraftUseCase,
    this._selectArticleThumbnailUseCase,
    this._updateArticleUseCase,
  ) : super(const CreateArticleState()) {
    on<LoadArticleDraftRequested>(_onLoadArticleDraftRequested);
    on<PersistArticleDraftRequested>(_onPersistArticleDraftRequested);
    on<SelectArticleThumbnailRequested>(_onSelectArticleThumbnailRequested);
    on<ClearSelectedArticleThumbnail>(_onClearSelectedArticleThumbnail);
    on<SubmitCreateArticle>(_onSubmitCreateArticle);
    on<ResetCreateArticle>(_onResetCreateArticle);
  }

  Future<void> _onLoadArticleDraftRequested(
    LoadArticleDraftRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    try {
      final draft = await _getArticleDraftUseCase(params: event.draftKey);

      emit(
        state.copyWith(
          status: CreateArticleStatus.initial,
          draftKey: event.draftKey,
          restoredDraft: draft,
          clearRestoredDraft: draft == null,
          hasLoadedDraft: true,
          selectedThumbnail: draft?.selectedThumbnail,
          clearSelectedThumbnail: draft?.selectedThumbnail == null,
          isPickingThumbnail: false,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: CreateArticleStatus.initial,
          draftKey: event.draftKey,
          hasLoadedDraft: true,
          clearRestoredDraft: true,
          isPickingThumbnail: false,
          clearErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _onPersistArticleDraftRequested(
    PersistArticleDraftRequested event,
    Emitter<CreateArticleState> emit,
  ) async {
    try {
      final selectedThumbnail =
          event.clearSelectedThumbnail ? null : state.selectedThumbnail;

      await _saveArticleDraftUseCase(
        params: ArticleDraftEntity(
          draftKey: event.draftKey,
          authorName: event.authorName,
          title: event.title,
          description: event.description,
          content: event.content,
          thumbnailPath:
              event.clearSelectedThumbnail ? null : event.thumbnailPath,
          thumbnailLocalPath:
              event.clearSelectedThumbnail ? null : selectedThumbnail?.path,
          fileName:
              event.clearSelectedThumbnail ? null : selectedThumbnail?.fileName,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Draft autosave should never interrupt the active editor flow.
    }
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
    if (!event.isEditing && state.selectedThumbnail == null) {
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
      final createdArticle = event.isEditing
          ? await _updateArticleUseCase(
              params: UpdateArticleParams(
                articleId: event.articleId!,
                authorName: event.authorName,
                title: event.title,
                description: event.description,
                content: event.content,
                sourceUrl: event.sourceUrl,
                thumbnail: state.selectedThumbnail,
              ),
            )
          : await _createArticleUseCase(
              params: CreateArticleParams(
                authorName: event.authorName,
                title: event.title,
                description: event.description,
                content: event.content,
                thumbnail: state.selectedThumbnail!,
              ),
            );
      await _clearArticleDraftUseCase(params: state.draftKey);

      emit(
        state.copyWith(
          status: CreateArticleStatus.success,
          article: createdArticle,
          clearRestoredDraft: true,
          hasLoadedDraft: true,
          isPickingThumbnail: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CreateArticleStatus.failure,
          errorMessage: error is StateError
              ? error.message.toString()
              : event.isEditing
                  ? 'No se pudo actualizar el articulo.'
                  : 'No se pudo crear el articulo.',
        ),
      );
    }
  }

  Future<void> _onResetCreateArticle(
    ResetCreateArticle event,
    Emitter<CreateArticleState> emit,
  ) async {
    await _clearArticleDraftUseCase(params: state.draftKey);
    emit(
      CreateArticleState(
        draftKey: state.draftKey,
        hasLoadedDraft: true,
      ),
    );
  }
}
