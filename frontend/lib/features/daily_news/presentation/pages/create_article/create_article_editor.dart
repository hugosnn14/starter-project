import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/create_article/create_article_state.dart';

import '../../../domain/entities/article.dart';
import '../../../domain/entities/article_thumbnail.dart';

enum ArticleEditorMode { create, edit }

class CreateArticleEditorPage extends StatefulWidget {
  const CreateArticleEditorPage({
    super.key,
    this.draftKey = CreateArticleState.defaultDraftKey,
    this.initialArticle,
    this.initialThumbnailPath,
    this.mode = ArticleEditorMode.create,
  });

  final String draftKey;
  final ArticleEntity? initialArticle;
  final String? initialThumbnailPath;
  final ArticleEditorMode mode;

  @override
  State<CreateArticleEditorPage> createState() =>
      _CreateArticleEditorPageState();
}

class _CreateArticleEditorPageState extends State<CreateArticleEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _authorController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  ArticleThumbnailEntity? _lastObservedSelectedThumbnail;
  Timer? _draftSaveTimer;
  bool _hasAppliedLoadedDraft = false;
  bool _showValidation = false;

  bool get _isEditing => widget.mode == ArticleEditorMode.edit;

  @override
  void initState() {
    super.initState();
    _applyInitialArticle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<CreateArticleBloc>().add(
            LoadArticleDraftRequested(draftKey: widget.draftKey),
          );
    });
  }

  @override
  void dispose() {
    _draftSaveTimer?.cancel();
    _scrollController.dispose();
    _authorController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateArticleBloc, CreateArticleState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.selectedThumbnail != current.selectedThumbnail ||
          previous.hasLoadedDraft != current.hasLoadedDraft ||
          previous.restoredDraft != current.restoredDraft,
      listener: (context, state) {
        if (state.hasLoadedDraft && !_hasAppliedLoadedDraft) {
          _applyLoadedDraft(state);
        }

        if (_hasAppliedLoadedDraft &&
            _lastObservedSelectedThumbnail != state.selectedThumbnail) {
          _lastObservedSelectedThumbnail = state.selectedThumbnail;
          if (!_shouldSkipThumbnailDraftSave(state)) {
            _persistDraft(immediate: true);
          }
        }

        if (state.status == CreateArticleStatus.success) {
          context.read<ArticlesBloc>().add(const LoadArticles());
        }

        if (state.status == CreateArticleStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'The article could not be published.',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: _buildAppBar(context, state),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    CreateArticleState state,
  ) {
    final isPublished = state.status == CreateArticleStatus.success;
    final isPublishing = state.status == CreateArticleStatus.submitting;

    return AppBar(
      centerTitle: false,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPublished
                ? _isEditing
                    ? 'Article updated'
                    : 'Article published'
                : _isEditing
                    ? 'Edit article'
                    : 'Create article',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            isPublished
                ? _isEditing
                    ? 'Preview the updated result.'
                    : 'Preview the published result.'
                : _isEditing
                    ? 'Refine the current story and push changes live.'
                    : 'Compose a new story for the editorial feed.',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      actions: [
        if (!isPublished)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: isPublishing ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              child: Text(
                isPublishing
                    ? _isEditing
                        ? 'Saving...'
                        : 'Publishing...'
                    : _isEditing
                        ? 'Save changes'
                        : 'Publish',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, CreateArticleState state) {
    if (state.status == CreateArticleStatus.success && state.article != null) {
      return _buildSuccessState(context, state);
    }

    return Stack(
      children: [
        _buildEditor(context, state),
        if (state.status == CreateArticleStatus.submitting)
          _buildPublishingOverlay(context),
      ],
    );
  }

  Widget _buildEditor(BuildContext context, CreateArticleState state) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      child: Form(
        key: _formKey,
        autovalidateMode: _showValidation
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [
                    AppPalette.surface,
                    AppPalette.surfaceLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppPalette.shadow,
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      (_isEditing ? 'Editorial revision' : 'Editorial draft')
                          .toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppPalette.onSecondaryContainer,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isEditing
                        ? 'Update the live article'
                        : 'Build a publication-ready story',
                    style: textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isEditing
                        ? 'The editor starts from the remote article and applies any saved local draft on top of it.'
                        : 'Write a real article, attach a cover image, and publish it to the live editorial feed.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppPalette.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildHeroAttachmentCard(context, state),
            const SizedBox(height: 24),
            _buildFieldSection(
              context,
              title: 'Title',
              child: TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write a strong headline...',
                ),
                onChanged: (_) => _scheduleDraftSave(),
                validator: (value) => _validateRequired(
                  value,
                  'Add a title before publishing.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldSection(
              context,
              title: 'Author',
              child: TextFormField(
                controller: _authorController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Who is publishing this article?',
                ),
                onChanged: (_) => _scheduleDraftSave(),
                validator: (value) => _validateRequired(
                  value,
                  'Add the author name.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldSection(
              context,
              title: 'Summary',
              trailing: _buildCharacterCount(
                context,
                current: _descriptionController.text.trim().length,
                max: 180,
              ),
              child: TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Summarize the story in one clear paragraph...',
                ),
                onChanged: (_) {
                  setState(() {});
                  _scheduleDraftSave();
                },
                validator: (value) => _validateRequired(
                  value,
                  'Add a short summary.',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldSection(
              context,
              title: 'Body',
              trailing: _buildCharacterCount(
                context,
                current: _contentController.text.trim().length,
                max: 1200,
              ),
              child: TextFormField(
                controller: _contentController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 12,
                minLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Add the complete article body here...',
                ),
                onChanged: (_) {
                  setState(() {});
                  _scheduleDraftSave();
                },
                validator: (value) => _validateRequired(
                  value,
                  'Add the article content.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroAttachmentCard(
    BuildContext context,
    CreateArticleState state,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final selectedThumbnail = state.selectedThumbnail;
    final isBusy = state.isPickingThumbnail ||
        state.status == CreateArticleStatus.submitting;
    final showValidationMessage = !_isEditing &&
        _showValidation &&
        selectedThumbnail == null &&
        !_hasRemoteThumbnail;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  AppPalette.surfaceLow,
                  AppPalette.surfaceContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildThumbnailPreview(state),
          ),
          const SizedBox(height: 16),
          Text(
            selectedThumbnail == null && !_hasRemoteThumbnail
                ? 'Cover image'
                : 'Cover image ready',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            selectedThumbnail != null
                ? selectedThumbnail.fileName ??
                    'The selected image will be uploaded with this article.'
                : _hasRemoteThumbnail
                    ? 'The current remote thumbnail will stay in place unless you select a new image.'
                    : 'Select the image that will be uploaded to Firebase Storage when the article is published.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: isBusy ? null : () => _pickThumbnail(context),
                icon: state.isPickingThumbnail
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        selectedThumbnail == null
                            ? Icons.add_photo_alternate_outlined
                            : Icons.refresh_rounded,
                      ),
                label: Text(
                  state.isPickingThumbnail
                      ? 'Selecting...'
                      : selectedThumbnail == null
                          ? 'Select thumbnail'
                          : 'Change thumbnail',
                ),
              ),
              if (selectedThumbnail != null)
                TextButton(
                  onPressed: isBusy ? null : () => _clearThumbnail(context),
                  child: const Text('Remove'),
                ),
            ],
          ),
          if (showValidationMessage) ...[
            const SizedBox(height: 12),
            Text(
              'Select a thumbnail before publishing.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnailPreviewImage(String imagePath) {
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppPalette.surfaceContainer,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 42,
          color: AppPalette.onSurfaceMuted,
        ),
      ),
    );
  }

  Widget _buildThumbnailPreview(CreateArticleState state) {
    final selectedThumbnail = state.selectedThumbnail;
    if (selectedThumbnail != null) {
      return _buildThumbnailPreviewImage(selectedThumbnail.path);
    }

    final remoteImageUrl = widget.initialArticle?.urlToImage;
    if (remoteImageUrl != null && remoteImageUrl.isNotEmpty) {
      return Image.network(
        remoteImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildThumbnailPlaceholder(),
      );
    }

    return _buildThumbnailPlaceholder();
  }

  Widget _buildThumbnailPlaceholder() {
    return const Center(
      child: Icon(
        Icons.add_photo_alternate_outlined,
        size: 52,
        color: AppPalette.primary,
      ),
    );
  }

  Widget _buildFieldSection(
    BuildContext context, {
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildCharacterCount(
    BuildContext context, {
    required int current,
    required int max,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$current / $max',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }

  Widget _buildPublishingOverlay(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withValues(alpha: 0.55),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [
                    BoxShadow(
                      color: AppPalette.shadow,
                      blurRadius: 32,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppPalette.surfaceLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        size: 38,
                        color: AppPalette.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isEditing ? 'Saving changes...' : 'Publishing...',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isEditing
                          ? 'Applying the latest revision to the live article.'
                          : 'Finalizing the editorial polish for your story.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    const LinearProgressIndicator(
                      minHeight: 6,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    const SizedBox(height: 18),
                    _buildPublishingStep(
                      context,
                      icon: Icons.check_circle_rounded,
                      label: 'Validating structure',
                      isActive: false,
                    ),
                    const SizedBox(height: 10),
                    _buildPublishingStep(
                      context,
                      icon: Icons.more_horiz_rounded,
                      label: _isEditing
                          ? 'Updating the article'
                          : 'Publishing the article',
                      isActive: true,
                    ),
                    const SizedBox(height: 10),
                    _buildPublishingStep(
                      context,
                      icon: Icons.outlined_flag_rounded,
                      label: 'Refreshing the feed',
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPublishingStep(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? AppPalette.primary : AppPalette.onSurfaceMuted;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, CreateArticleState state) {
    final article = state.article!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: AppPalette.shadow,
                blurRadius: 32,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppPalette.surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: AppPalette.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isEditing ? 'Updated successfully' : 'Published successfully',
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                _isEditing
                    ? 'The latest revision is live and ready to be reviewed.'
                    : 'The new article is already available in the feed and ready to be reviewed.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _buildSuccessPreviewCard(
                context,
                article,
                state.selectedThumbnail,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _viewPublishedArticle(context, article),
                      child: const Text('View article'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetEditor,
                      child:
                          Text(_isEditing ? 'Keep editing' : 'Create another'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessPreviewCard(
    BuildContext context,
    ArticleEntity article,
    ArticleThumbnailEntity? selectedThumbnail,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: selectedThumbnail != null
                ? _buildThumbnailPreviewImage(selectedThumbnail.path)
                : Image.network(
                    article.urlToImage ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppPalette.surfaceContainer,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppPalette.onSurfaceMuted,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (_isEditing ? 'Updated' : 'Published').toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppPalette.onSecondaryContainer,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  article.title ?? '',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.description ?? '',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  '${article.author ?? 'Unknown author'} • ${article.publishedAt ?? ''}',
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  void _submit() {
    setState(() {
      _showValidation = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<CreateArticleBloc>().add(
          SubmitCreateArticle(
            authorName: _authorController.text.trim(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
            articleId: widget.initialArticle?.id,
            sourceUrl: widget.initialArticle?.url,
            isEditing: _isEditing,
          ),
        );
  }

  void _pickThumbnail(BuildContext context) {
    context.read<CreateArticleBloc>().add(
          const SelectArticleThumbnailRequested(),
        );
  }

  void _clearThumbnail(BuildContext context) {
    context.read<CreateArticleBloc>().add(
          const ClearSelectedArticleThumbnail(),
        );
    _persistDraft(
      immediate: true,
      clearSelectedThumbnail: true,
    );
  }

  void _resetEditor() {
    _draftSaveTimer?.cancel();
    _authorController.clear();
    _titleController.clear();
    _descriptionController.clear();
    _contentController.clear();

    setState(() {
      _showValidation = false;
    });

    context.read<CreateArticleBloc>().add(const ResetCreateArticle());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _viewPublishedArticle(BuildContext context, ArticleEntity article) {
    final articleId = article.id;

    if (articleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The published article is missing an id.'),
        ),
      );
      return;
    }

    Navigator.popAndPushNamed(
      context,
      AppRoutes.articleDetails,
      arguments: articleId,
    );
  }

  void _applyInitialArticle() {
    final initialArticle = widget.initialArticle;
    if (initialArticle == null) {
      return;
    }

    _authorController.text = initialArticle.author ?? '';
    _titleController.text = initialArticle.title ?? '';
    _descriptionController.text = initialArticle.description ?? '';
    _contentController.text = initialArticle.content ?? '';
  }

  void _applyLoadedDraft(CreateArticleState state) {
    final restoredDraft = state.restoredDraft;
    if (restoredDraft != null) {
      _authorController.text = restoredDraft.authorName;
      _titleController.text = restoredDraft.title;
      _descriptionController.text = restoredDraft.description;
      _contentController.text = restoredDraft.content;
    }

    setState(() {
      _hasAppliedLoadedDraft = true;
    });
  }

  void _scheduleDraftSave() {
    if (!_hasAppliedLoadedDraft) {
      return;
    }

    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(
      const Duration(milliseconds: 500),
      () => _persistDraft(),
    );
  }

  void _persistDraft({
    bool immediate = false,
    bool clearSelectedThumbnail = false,
  }) {
    if (!_hasAppliedLoadedDraft && !immediate) {
      return;
    }

    if (!mounted) {
      return;
    }

    context.read<CreateArticleBloc>().add(
          PersistArticleDraftRequested(
            draftKey: widget.draftKey,
            authorName: _authorController.text.trim(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            content: _contentController.text.trim(),
            thumbnailPath: widget.initialThumbnailPath,
            clearSelectedThumbnail: clearSelectedThumbnail,
          ),
        );
  }

  bool _shouldSkipThumbnailDraftSave(CreateArticleState state) {
    if (state.status == CreateArticleStatus.success) {
      return true;
    }

    return state.selectedThumbnail == null &&
        _authorController.text.trim().isEmpty &&
        _titleController.text.trim().isEmpty &&
        _descriptionController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty;
  }

  bool get _hasRemoteThumbnail {
    final remoteThumbnailPath =
        widget.initialThumbnailPath ?? widget.initialArticle?.thumbnailPath;
    return remoteThumbnailPath != null && remoteThumbnailPath.isNotEmpty;
  }
}
