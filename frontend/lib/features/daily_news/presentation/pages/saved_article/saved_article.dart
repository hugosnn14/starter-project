import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
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
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back, color: Colors.black),
        ),
      ),
      title:
          const Text('Saved Articles', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SavedArticlesBloc, SavedArticlesState>(
      builder: (context, state) {
        if (state.status == SavedArticlesStatus.initial ||
            state.status == SavedArticlesStatus.loading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state.status == SavedArticlesStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? 'Algo ha ido mal.'),
          );
        }
        return _buildArticlesList(state.articles);
      },
    );
  }

  Widget _buildArticlesList(List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return const Center(
        child: Text(
          'NO SAVED ARTICLES',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return ArticleWidget(
          article: articles[index],
          isRemovable: true,
          onRemove: (article) => _onRemoveArticle(context, article),
          onArticlePressed: (article) => _onArticlePressed(context, article),
        );
      },
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    context.read<SavedArticlesBloc>().add(SavedArticleDeleted(article));
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(
      context,
      AppRoutes.articleDetails,
      arguments: article,
    );
  }
}
