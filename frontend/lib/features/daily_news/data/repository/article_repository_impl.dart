import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final List<ArticleEntity> _articles = [
    const ArticleEntity(
      id: 1,
      author: 'Ada Lovelace',
      title: 'Cities can reuse water better than we think',
      description:
          'A short piece about practical water reuse strategies that can be deployed right now.',
      url: 'https://example.com/articles/water-reuse',
      urlToImage: 'https://placehold.co/600x400/png?text=Water+Reuse',
      publishedAt: '2026-03-24',
      content:
          'Water reuse is no longer a futuristic idea. Municipal systems can adopt small improvements that generate measurable impact in the short term.',
    ),
    const ArticleEntity(
      id: 2,
      author: 'Grace Hopper',
      title: 'Why public tech products need simpler writing',
      description:
          'Clarity in digital services is not decoration. It is part of whether a product actually works.',
      url: 'https://example.com/articles/simpler-writing',
      urlToImage:
          'https://placehold.co/600x400/png?text=Simple+Writing',
      publishedAt: '2026-03-22',
      content:
          'When interfaces are difficult to understand, the system fails before the user even starts. Clear text is product quality, not polish.',
    ),
    const ArticleEntity(
      id: 3,
      author: 'Katherine Johnson',
      title: 'Small teams win by finishing smaller scopes',
      description:
          'The fastest way to show quality is to close a small vertical slice end to end.',
      url: 'https://example.com/articles/small-scope',
      urlToImage:
          'https://placehold.co/600x400/png?text=Small+Scope',
      publishedAt: '2026-03-20',
      content:
          'Small scopes reduce uncertainty, make testing easier, and help teams prove reliability with less noise.',
    ),
  ];

  int _nextId = 4;

  @override
  Future<List<ArticleEntity>> getArticles() async {
    return List.unmodifiable(_articles);
  }

  @override
  Future<ArticleEntity?> getArticleById(int articleId) async {
    for (final article in _articles) {
      if (article.id == articleId) {
        return article;
      }
    }
    return null;
  }

  @override
  Future<ArticleEntity> createArticle(ArticleEntity article) async {
    final createdArticle = ArticleEntity(
      id: _nextId++,
      author: article.author,
      title: article.title,
      description: article.description,
      url: 'https://example.com/articles/${DateTime.now().millisecondsSinceEpoch}',
      urlToImage: 'https://placehold.co/600x400/png?text=New+Article',
      publishedAt: DateTime.now().toIso8601String().split('T').first,
      content: article.content,
    );

    _articles.insert(0, createdArticle);

    return createdArticle;
  }
}
