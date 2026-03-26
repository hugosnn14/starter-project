import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/articles_bloc.dart';
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
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
          settings,
        );
      case createArticle:
      case '/CreateArticle':
        return _materialRoute(
          BlocProvider.value(
            value: settings.arguments as ArticlesBloc,
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
}
