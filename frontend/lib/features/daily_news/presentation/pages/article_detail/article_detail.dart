import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../config/theme/app_themes.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article_details/article_details_bloc.dart';
import '../../bloc/article_details/article_details_state.dart';

class ArticleDetailsView extends StatelessWidget {
  const ArticleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: BlocBuilder<ArticleDetailsBloc, ArticleDetailsState>(
        builder: (context, state) {
          if (state.status == ArticleDetailsStatus.initial ||
              state.status == ArticleDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ArticleDetailsStatus.notFound ||
              state.status == ArticleDetailsStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Algo ha ido mal.'),
            );
          }

          return _buildBody(context, state.article!);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
    );
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
    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          article.urlToImage ?? '',
          fit: BoxFit.cover,
        ),
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
}
