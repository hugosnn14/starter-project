import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article_details/article_details_bloc.dart';
import '../../bloc/saved_articles/saved_articles_bloc.dart';
import '../../bloc/saved_articles/saved_articles_event.dart';
import '../../bloc/saved_articles/saved_articles_state.dart';
import '../../bloc/article_details/article_details_state.dart';

class ArticleDetailsView extends StatelessWidget {
  const ArticleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedArticlesBloc, SavedArticlesState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == SavedArticlesStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'The saved articles action failed.',
            ),
          ),
        );
      },
      child: BlocBuilder<ArticleDetailsBloc, ArticleDetailsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(
              context,
              state.status == ArticleDetailsStatus.success
                  ? state.article
                  : null,
            ),
            body: _buildContent(context, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ArticleEntity? article,
  ) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(
            Ionicons.chevron_back,
            color: AppPalette.onSurface,
          ),
        ),
      ),
      title: Text(
        'Article',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        if (article != null) _buildSavedAction(context, article),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ArticleDetailsState state) {
    if (state.status == ArticleDetailsStatus.initial ||
        state.status == ArticleDetailsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ArticleDetailsStatus.notFound ||
        state.status == ArticleDetailsStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.errorMessage ?? 'Algo ha ido mal.'),
        ),
      );
    }

    return _buildBody(context, state.article!);
  }

  Widget _buildBody(BuildContext context, ArticleEntity article) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleTitleAndDate(context, article),
          _buildArticleImage(article),
          _buildArticleDescription(context, article),
        ],
      ),
    );
  }

  Widget _buildSavedAction(BuildContext context, ArticleEntity article) {
    return BlocBuilder<SavedArticlesBloc, SavedArticlesState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.articles != current.articles,
      builder: (context, state) {
        final isLoading = state.status == SavedArticlesStatus.loading &&
            state.articles.isEmpty;
        final isSaved = state.articles.any((item) => item.id == article.id);

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return IconButton(
          tooltip: isSaved ? 'Remove from saved' : 'Save article',
          onPressed: () => _toggleSavedArticle(context, article, isSaved),
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isSaved ? AppPalette.primary : AppPalette.onSurface,
          ),
        );
      },
    );
  }

  Widget _buildArticleTitleAndDate(
    BuildContext context,
    ArticleEntity article,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title ?? '',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 14),
          Text(
            article.author ?? '',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Ionicons.time_outline,
                size: 16,
                color: AppPalette.onSurfaceMuted,
              ),
              const SizedBox(width: 4),
              Text(
                article.publishedAt ?? '',
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage(ArticleEntity article) {
    final imageUrl = article.urlToImage?.trim();

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageFallback();
    }

    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return _buildImageFallback(
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildImageFallback(),
        ),
      ),
    );
  }

  Widget _buildImageFallback({Widget? child}) {
    return Container(
      color: AppPalette.surfaceContainer,
      alignment: Alignment.center,
      child: child ??
          const Icon(
            Icons.image_outlined,
            size: 42,
            color: AppPalette.onSurfaceMuted,
          ),
    );
  }

  Widget _buildArticleDescription(
    BuildContext context,
    ArticleEntity article,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Text(
        '${article.description ?? ''}\n\n${article.content ?? ''}',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _toggleSavedArticle(
    BuildContext context,
    ArticleEntity article,
    bool isSaved,
  ) {
    final bloc = context.read<SavedArticlesBloc>();

    if (isSaved) {
      bloc.add(SavedArticleDeleted(article));
      return;
    }

    bloc.add(SavedArticleStored(article));
  }
}
