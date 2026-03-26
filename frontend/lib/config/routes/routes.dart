import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_event.dart';
import '../../features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/domain/usecases/get_article_by_id.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article_editor.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/my_articles/my_articles.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/article-details';
  static const String createArticle = '/create-article';
  static const String editArticle = '/edit-article';
  static const String myArticles = '/my-articles';
  static const String savedArticles = '/saved-articles';

  static Route onGenerateRoutes(RouteSettings settings) {
    // Active navigation only exposes the current MVP article flow.
    // Legacy screens are intentionally excluded from this route table.
    switch (settings.name) {
      case home:
        return _materialRoute(const DailyNews(), settings);

      case articleDetails:
        return _materialRoute(
          MultiBlocProvider(
            providers: [
              BlocProvider<ArticleDetailsBloc>(
                create: (_) => sl<ArticleDetailsBloc>()
                  ..add(LoadArticleDetails(
                      _extractArticleId(settings.arguments))),
              ),
              BlocProvider<SavedArticlesBloc>(
                create: (_) => sl<SavedArticlesBloc>()
                  ..add(const SavedArticlesRequested()),
              ),
            ],
            child: const ArticleDetailsView(),
          ),
          settings,
        );
      case createArticle:
        return _materialRoute(
          BlocProvider<CreateArticleBloc>(
            create: (_) => sl<CreateArticleBloc>(),
            child: const CreateArticleEditorPage(),
          ),
          settings,
        );
      case editArticle:
        return _materialRoute(
          _EditArticleLoader(
            articleId: _extractEditArticleArgs(settings.arguments).articleId,
          ),
          settings,
        );
      case myArticles:
        return _materialRoute(const MyArticlesPage(), settings);
      case savedArticles:
        return _materialRoute(const SavedArticles(), settings);
      default:
        return _materialRoute(const DailyNews(), settings);
    }
  }

  static Route<dynamic> _materialRoute(Widget view, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => view,
      settings: settings,
    );
  }

  static String _extractArticleId(Object? arguments) {
    if (arguments is String) {
      return arguments;
    }

    throw ArgumentError(
      'Article details route requires a non-null articleId.',
    );
  }

  static EditArticleRouteArgs _extractEditArticleArgs(Object? arguments) {
    if (arguments is EditArticleRouteArgs) {
      return arguments;
    }

    throw ArgumentError(
      'Edit article route requires EditArticleRouteArgs.',
    );
  }
}

class EditArticleRouteArgs {
  const EditArticleRouteArgs({
    required this.articleId,
  });

  final String articleId;
}

class _EditArticleLoader extends StatefulWidget {
  const _EditArticleLoader({
    required this.articleId,
  });

  final String articleId;

  @override
  State<_EditArticleLoader> createState() => _EditArticleLoaderState();
}

class _EditArticleLoaderState extends State<_EditArticleLoader> {
  late Future<ArticleEntity?> _articleFuture;

  @override
  void initState() {
    super.initState();
    _articleFuture = sl<GetArticleByIdUseCase>()(params: widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ArticleEntity?>(
      future: _articleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final article = snapshot.data;
        if (article == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('The requested article could not be loaded.'),
            ),
          );
        }

        return BlocProvider<CreateArticleBloc>(
          create: (_) => sl<CreateArticleBloc>(),
          child: CreateArticleEditorPage(
            mode: ArticleEditorMode.edit,
            draftKey: 'edit_article_${widget.articleId}',
            initialArticle: article,
            initialThumbnailPath: article.thumbnailPath,
          ),
        );
      },
    );
  }
}
