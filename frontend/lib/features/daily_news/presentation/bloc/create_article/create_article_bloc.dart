import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/create_article.dart';
import 'create_article_event.dart';
import 'create_article_state.dart';

class CreateArticleBloc extends Bloc<CreateArticleEvent, CreateArticleState> {
  final CreateArticleUseCase _createArticleUseCase;

  CreateArticleBloc(this._createArticleUseCase)
      : super(const CreateArticleState()) {
    on<SubmitCreateArticle>(_onSubmitCreateArticle);
    on<ResetCreateArticle>(_onResetCreateArticle);
  }

  Future<void> _onSubmitCreateArticle(
    SubmitCreateArticle event,
    Emitter<CreateArticleState> emit,
  ) async {
    emit(
      const CreateArticleState(
        status: CreateArticleStatus.submitting,
      ),
    );

    try {
      final createdArticle = await _createArticleUseCase(
        params: CreateArticleParams(
          authorName: event.authorName,
          title: event.title,
          description: event.description,
          content: event.content,
        ),
      );

      emit(
        CreateArticleState(
          status: CreateArticleStatus.success,
          article: createdArticle,
        ),
      );
    } catch (_) {
      emit(
        const CreateArticleState(
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
