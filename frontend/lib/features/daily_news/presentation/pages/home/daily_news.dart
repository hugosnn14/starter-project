import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreateArticlePressed(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ArticlesBloc, ArticlesState>(
        builder: (context, state) {
          if (state.status == ArticlesStatus.initial ||
              state.status == ArticlesStatus.loading) {
            return _buildLoadingState(context);
          }
          if (state.status == ArticlesStatus.failure) {
            return _buildErrorState(context, state.errorMessage);
          }
          if (state.status == ArticlesStatus.success &&
              state.articles.isEmpty) {
            return _buildEmptyState(context);
          }
          if (state.status == ArticlesStatus.success) {
            return _buildArticlesPage(context, state.articles);
          }
          return const SizedBox();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      centerTitle: false,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily News',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Editorial selection for the current build',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Saved articles',
          onPressed: () => _onSavedArticlesPressed(context),
          icon: const Icon(Icons.bookmark_border_rounded),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: const [
        _EditorialHero(
          eyebrow: 'Morning edition',
          title: 'Loading the desk',
          description:
              'Pulling the latest stories into a calmer, more readable newsroom.',
        ),
        SizedBox(height: 24),
        ArticleCardPlaceholder(
          variant: ArticleCardVariant.featured,
        ),
        SizedBox(height: 8),
        _SectionHeader(
          title: 'Latest dispatches',
          subtitle: 'Preparing the next set of stories.',
        ),
        SizedBox(height: 8),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        const _EditorialHero(
          eyebrow: 'Newsroom interrupted',
          title: 'The feed could not be refreshed',
          description:
              'The app is running, but the latest published articles could not be loaded.',
        ),
        const SizedBox(height: 24),
        _StateMessageCard(
          icon: Icons.wifi_tethering_error_rounded,
          title: 'We hit a loading issue',
          description:
              message ?? 'Something went wrong while loading articles.',
          primaryActionLabel: 'Retry',
          onPrimaryAction: () => context.read<ArticlesBloc>().add(
                const LoadArticles(),
              ),
          secondaryActionLabel: 'Create article',
          onSecondaryAction: () => _onCreateArticlePressed(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        const _EditorialHero(
          eyebrow: 'Fresh issue',
          title: 'No stories have been published yet',
          description:
              'This screen is ready for content. Publish the first article to bring the feed to life.',
        ),
        const SizedBox(height: 24),
        _StateMessageCard(
          icon: Icons.auto_stories_outlined,
          title: 'An empty front page is still a state worth designing',
          description:
              'Create the first article and the featured layout will populate automatically.',
          primaryActionLabel: 'Create first article',
          onPrimaryAction: () => _onCreateArticlePressed(context),
        ),
      ],
    );
  }

  Widget _buildArticlesPage(
    BuildContext context,
    List<ArticleEntity> articles,
  ) {
    final featuredArticle = articles.first;
    final latestArticles = articles.skip(1).toList();

    return RefreshIndicator(
      color: AppPalette.primary,
      onRefresh: () => _reloadArticles(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _EditorialHero(
            eyebrow: 'Today\'s edition',
            title: 'Stories worth opening',
            description:
                '${articles.length} curated piece${articles.length == 1 ? '' : 's'} available in the current newsroom build.',
          ),
          const SizedBox(height: 24),
          ArticleWidget(
            article: featuredArticle,
            variant: ArticleCardVariant.featured,
            badgeLabel: 'Top story',
            onArticlePressed: (article) => _onArticlePressed(context, article),
          ),
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'Latest dispatches',
            subtitle: latestArticles.isEmpty
                ? 'The featured story is currently the only piece on the desk.'
                : 'A quieter list for the rest of the feed.',
          ),
          const SizedBox(height: 8),
          if (latestArticles.isEmpty)
            _StateMessageCard(
              icon: Icons.library_add_check_rounded,
              title: 'The issue is concise for now',
              description:
                  'Publish another article to expand the feed beneath the featured story.',
              primaryActionLabel: 'Create another article',
              onPrimaryAction: () => _onCreateArticlePressed(context),
              isCompact: true,
            )
          else
            ...latestArticles.map(
              (article) => ArticleWidget(
                article: article,
                onArticlePressed: (selectedArticle) =>
                    _onArticlePressed(context, selectedArticle),
              ),
            ),
        ],
      ),
    );
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

  void _onCreateArticlePressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.createArticle,
    );
  }

  void _onSavedArticlesPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.savedArticles,
    );
  }

  Future<void> _reloadArticles(BuildContext context) async {
    final bloc = context.read<ArticlesBloc>();
    bloc.add(const LoadArticles());
    await bloc.stream.firstWhere(
      (state) => state.status != ArticlesStatus.loading,
    );
  }

  void _showMissingArticleIdMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The selected article is missing an id.'),
      ),
    );
  }
}

class _EditorialHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _EditorialHero({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppPalette.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              eyebrow.toUpperCase(),
              style: textTheme.labelMedium?.copyWith(
                color: AppPalette.onSecondaryContainer,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: textTheme.bodyLarge?.copyWith(
              color: AppPalette.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
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
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _StateMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool isCompact;

  const _StateMessageCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.isCompact = false,
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
          if (isCompact)
            ElevatedButton(
              onPressed: onPrimaryAction,
              child: Text(primaryActionLabel),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: onPrimaryAction,
                  child: Text(primaryActionLabel),
                ),
                if (secondaryActionLabel != null && onSecondaryAction != null)
                  OutlinedButton(
                    onPressed: onSecondaryAction,
                    child: Text(secondaryActionLabel!),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
