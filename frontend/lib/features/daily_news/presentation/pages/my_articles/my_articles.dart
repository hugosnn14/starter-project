import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/archive_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_my_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({super.key});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  late Future<List<ArticleEntity>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Articles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Published and archived pieces for the current author.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateArticle,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<ArticleEntity>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final articles = snapshot.data ?? const [];
          if (articles.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppPalette.primary,
            onRefresh: _refreshArticles,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _buildHeader(
                  title: 'Your editorial desk',
                  description:
                      '${articles.length} article${articles.length == 1 ? '' : 's'} tied to the current author account.',
                ),
                const SizedBox(height: 20),
                ...articles.map(
                  (article) => _MyArticleListItem(
                    article: article,
                    badgeLabel: _statusLabel(article.status),
                    onEdit: () => _openEditArticle(article),
                    onArchive: article.status == 'archived'
                        ? null
                        : () => _archiveArticle(article),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: const [
        _MyArticlesHero(
          title: 'Loading your desk',
          description: 'Fetching the latest author-scoped articles.',
        ),
        SizedBox(height: 20),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
        ArticleCardPlaceholder(),
      ],
    );
  }

  Widget _buildErrorState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildHeader(
          title: 'This desk could not be loaded',
          description:
              'The app could not fetch the current author articles from Firestore.',
        ),
        const SizedBox(height: 20),
        _MyArticlesMessageCard(
          icon: Icons.wifi_tethering_error_rounded,
          title: 'Author articles are temporarily unavailable',
          description: 'Retry the query or create a new article directly.',
          primaryLabel: 'Retry',
          onPrimary: _retryArticles,
          secondaryLabel: 'Create article',
          onSecondary: _openCreateArticle,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _buildHeader(
          title: 'No author articles yet',
          description:
              'This account has not published or archived any articles in the current project.',
        ),
        const SizedBox(height: 20),
        _MyArticlesMessageCard(
          icon: Icons.article_outlined,
          title: 'Start with the first article',
          description:
              'Newly created articles will appear here and can be edited later from the same desk.',
          primaryLabel: 'Create article',
          onPrimary: _openCreateArticle,
        ),
      ],
    );
  }

  Widget _buildHeader({
    required String title,
    required String description,
  }) {
    return _MyArticlesHero(
      title: title,
      description: description,
    );
  }

  Future<List<ArticleEntity>> _loadArticles() {
    return sl<GetMyArticlesUseCase>()();
  }

  Future<void> _refreshArticles() async {
    final future = _loadArticles();
    setState(() {
      _articlesFuture = future;
    });
    await future;
  }

  void _retryArticles() {
    setState(() {
      _articlesFuture = _loadArticles();
    });
  }

  void _openCreateArticle() {
    Navigator.pushNamed(context, AppRoutes.createArticle).then((_) {
      _retryArticles();
    });
  }

  void _openEditArticle(ArticleEntity article) {
    final articleId = article.id;
    if (articleId == null) {
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.editArticle,
      arguments: EditArticleRouteArgs(articleId: articleId),
    ).then((_) {
      _retryArticles();
    });
  }

  Future<void> _archiveArticle(ArticleEntity article) async {
    final articleId = article.id;
    if (articleId == null) {
      return;
    }

    final shouldArchive = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Archive article?'),
            content: Text(
              '“${article.title ?? 'This article'}” will leave the public feed and remain in your desk as archived.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archive'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldArchive || !mounted) {
      return;
    }

    try {
      await sl<ArchiveArticleUseCase>()(params: articleId);
      if (!mounted) {
        return;
      }

      context.read<ArticlesBloc>().add(const LoadArticles());
      _retryArticles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article archived.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The article could not be archived.'),
        ),
      );
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'archived':
        return 'Archived';
      case 'draft':
        return 'Draft';
      default:
        return 'Published';
    }
  }
}

class _MyArticleListItem extends StatelessWidget {
  const _MyArticleListItem({
    required this.article,
    required this.badgeLabel,
    required this.onEdit,
    this.onArchive,
  });

  final ArticleEntity article;
  final String badgeLabel;
  final VoidCallback onEdit;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ArticleWidget(
          article: article,
          badgeLabel: badgeLabel,
          onArticlePressed: (_) => onEdit(),
          margin: const EdgeInsets.only(bottom: 10),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              if (onArchive != null)
                TextButton.icon(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyArticlesHero extends StatelessWidget {
  const _MyArticlesHero({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
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

class _MyArticlesMessageCard extends StatelessWidget {
  const _MyArticlesMessageCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String description;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

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
          Icon(icon, color: AppPalette.primary),
          const SizedBox(height: 16),
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: onPrimary,
                child: Text(primaryLabel),
              ),
              if (secondaryLabel != null && onSecondary != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
