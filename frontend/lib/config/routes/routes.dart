import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_event.dart';
import '../../features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article_editor.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/article-details';
  static const String createArticle = '/create-article';
  static const String savedArticles = '/saved-articles';

  static Route onGenerateRoutes(RouteSettings settings) {
    // Active navigation only exposes the current Bloc-based presentation flow.
    // Legacy screens remain in the repository, but are intentionally not wired
    // through this route table anymore.
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

  static int _extractArticleId(Object? arguments) {
    if (arguments is int) {
      return arguments;
    }

    throw ArgumentError(
      'Article details route requires a non-null articleId.',
    );
  }
}
