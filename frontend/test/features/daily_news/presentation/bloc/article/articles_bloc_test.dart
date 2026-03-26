import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_articles.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/articles_state.dart';

void main() {
  group('ArticlesBloc', () {
    test('emits loading and success when articles are loaded', () async {
      final bloc = ArticlesBloc(GetArticlesUseCase(ArticleRepositoryImpl()));

      final emittedStatesFuture = bloc.stream.take(2).toList();

      bloc.add(const LoadArticles());

      final emittedStates = await emittedStatesFuture;

      expect(emittedStates[0].status, ArticlesStatus.loading);
      expect(emittedStates[1].status, ArticlesStatus.success);
      expect(emittedStates[1].articles, hasLength(3));

      await bloc.close();
    });
  });
}
