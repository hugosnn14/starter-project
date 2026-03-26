import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/daily_news/domain/entities/article.dart';
import '../../features/daily_news/presentation/bloc/article/articles_bloc.dart';
import '../../features/daily_news/presentation/pages/article_detail/article_detail.dart';
import '../../features/daily_news/presentation/pages/create_article/create_article.dart';
import '../../features/daily_news/presentation/pages/home/daily_news.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        return _materialRoute(
          ArticleDetailsView(article: settings.arguments as ArticleEntity),
        );
      case '/CreateArticle':
        return _materialRoute(
          BlocProvider.value(
            value: settings.arguments as ArticlesBloc,
            child: const CreateArticlePage(),
          ),
        );
      default:
        return _materialRoute(const DailyNews());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
