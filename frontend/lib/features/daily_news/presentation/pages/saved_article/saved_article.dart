import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/saved_articles/saved_articles_bloc.dart';
import '../../bloc/saved_articles/saved_articles_event.dart';
import '../../bloc/saved_articles/saved_articles_state.dart';
import '../../widgets/article_tile.dart';

class SavedArticles extends StatelessWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SavedArticlesBloc>()..add(const SavedArticlesRequested()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 12,
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
        'Saved Articles',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh saved articles',
          onPressed: () => _reloadSavedArticles(context),
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<SavedArticlesBloc, SavedArticlesState>(
      builder: (context, state) {
        if (state.status == SavedArticlesStatus.initial ||
            state.status == SavedArticlesStatus.loading) {
          return _buildLoadingState();
        }
        if (state.status == SavedArticlesStatus.failure) {
          return _buildFailureState(context, state.errorMessage);
        }
        if (state.articles.isEmpty) {
          return _buildEmptyState(context);
        }
        return _buildArticlesList(context, state.articles);
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: const [
        _SavedHeader(
          title: 'Loading saved reads',
          subtitle: 'Collecting the articles you bookmarked for later review.',
        ),
        SizedBox(height: 16),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
      ],
    );
  }

  Widget _buildFailureState(BuildContext context, String? message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const _SavedHeader(
          title: 'Saved reads unavailable',
          subtitle:
              'The saved articles list could not be refreshed from the mocked store.',
        ),
        const SizedBox(height: 16),
        _SavedMessageCard(
          icon: Icons.bookmark_remove_outlined,
          title: 'The saved list could not be loaded',
          description:
              message ?? 'Something went wrong while loading saved articles.',
          primaryActionLabel: 'Retry',
          onPrimaryAction: () => _reloadSavedArticles(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        const _SavedHeader(
          title: 'Nothing has been saved yet',
          subtitle:
              'Bookmark an article from the detail screen and it will appear here.',
        ),
        const SizedBox(height: 16),
        _SavedMessageCard(
          icon: Icons.bookmark_border_rounded,
          title: 'Your reading list is empty',
          description:
              'Open an article, tap the bookmark action, and this screen will become your saved queue.',
          primaryActionLabel: 'Back to feed',
          onPrimaryAction: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildArticlesList(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _SavedHeader(
          title:
              '${articles.length} saved ${articles.length == 1 ? 'article' : 'articles'}',
          subtitle:
              'A persistent shortlist built on top of the mock repository.',
        ),
        const SizedBox(height: 12),
        ...articles.map(
          (article) => ArticleWidget(
            article: article,
            isRemovable: true,
            onRemove: (selectedArticle) =>
                _onRemoveArticle(context, selectedArticle),
            onArticlePressed: (selectedArticle) =>
                _onArticlePressed(context, selectedArticle),
          ),
        ),
      ],
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    context.read<SavedArticlesBloc>().add(SavedArticleDeleted(article));
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    final articleId = article.id;

    if (articleId == null) {
      _showMissingArticleIdMessage(context);
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.articleDetails,
      arguments: articleId,
    );
  }

  void _showMissingArticleIdMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The selected article is missing an id.'),
      ),
    );
  }

  void _reloadSavedArticles(BuildContext context) {
    context.read<SavedArticlesBloc>().add(const SavedArticlesRequested());
  }
}

class _SavedHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SavedHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SavedMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  const _SavedMessageCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppPalette.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppPalette.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onPrimaryAction,
            child: Text(primaryActionLabel),
          ),
        ],
      ),
    );
  }
}
