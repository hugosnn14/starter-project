import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_state.dart';

import '../../../domain/entities/article.dart';
import '../../widgets/article_tile.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: Text(
        'Daily News',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildPage() {
    return BlocBuilder<ArticlesBloc, ArticlesState>(
      builder: (context, state) {
        if (state.status == ArticlesStatus.initial ||
            state.status == ArticlesStatus.loading) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        if (state.status == ArticlesStatus.failure) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Algo ha ido mal.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ArticlesBloc>().add(
                          const LoadArticles(),
                        ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _onCreateArticlePressed(context),
              child: const Icon(Icons.add),
            ),
          );
        }
        if (state.status == ArticlesStatus.success ||
            state.status == ArticlesStatus.submitting) {
          return _buildArticlesPage(context, state.articles);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: articles.isEmpty
          ? const Center(
              child: Text('No hay articulos disponibles.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticleWidget(
                  article: articles[index],
                  onArticlePressed: (article) =>
                      _onArticlePressed(context, article),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreateArticlePressed(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(
      context,
      AppRoutes.articleDetails,
      arguments: article,
    );
  }

  void _onCreateArticlePressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.createArticle,
      arguments: context.read<ArticlesBloc>(),
    );
  }
}
