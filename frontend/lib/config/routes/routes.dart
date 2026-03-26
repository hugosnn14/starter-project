import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection_container.dart';
import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_bloc.dart';
import '../../features/daily_news/presentation/bloc/article_details/article_details_event.dart';
import '../../features/daily_news/presentation/bloc/create_article/create_article_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart';
import '../../features/daily_news/presentation/bloc/saved_articles/saved_articles_event.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';
import '../../features/daily_news/presentation/pages/saved_article/saved_article.dart';

class AppRoutes {
  static const String home = '/';
  static const String articleDetails = '/article-details';
  static const String createArticle = '/create-article';
  static const String savedArticles = '/saved-articles';

  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _materialRoute(const DailyNews(), settings);

      case articleDetails:
      case '/ArticleDetails':
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
      case '/CreateArticle':
        return _materialRoute(
          BlocProvider<CreateArticleBloc>(
            create: (_) => sl<CreateArticleBloc>(),
            child: const CreateArticlePage(),
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

    if (arguments is ArticleEntity && arguments.id != null) {
      return arguments.id!;
    }

    throw ArgumentError(
      'Article details route requires an articleId or an ArticleEntity with a non-null id.',
    );
  }
}
