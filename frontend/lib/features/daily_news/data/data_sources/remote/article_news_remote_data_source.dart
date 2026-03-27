import 'dart:convert';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

import '../../../../../core/constants/constants.dart';

const _newsApiArticleIdPrefix = 'newsapi:';

abstract class ArticleNewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines();

  Future<ArticleModel?> getArticleById(String articleId);

  bool isNewsApiArticleId(String articleId);
}

class ArticleNewsRemoteDataSourceImpl implements ArticleNewsRemoteDataSource {
  ArticleNewsRemoteDataSourceImpl({
    required NewsApiService newsApiService,
  }) : _newsApiService = newsApiService;

  final NewsApiService _newsApiService;
  final Map<String, ArticleModel> _cachedArticlesById = {};

  @override
  Future<List<ArticleModel>> getTopHeadlines() async {
    final response = await _newsApiService.getNewsArticles(
      apiKey: newsAPIKey,
      country: countryQuery,
      category: categoryQuery,
    );

    final articles = response.data
        .map(_normalizeArticle)
        .where((article) => _hasText(article.title) || _hasText(article.url))
        .toList(growable: false);

    _cachedArticlesById
      ..clear()
      ..addEntries(
        articles
            .where((article) => article.id != null)
            .map((article) => MapEntry(article.id!, article)),
      );

    return articles;
  }

  @override
  Future<ArticleModel?> getArticleById(String articleId) async {
    final cachedArticle = _cachedArticlesById[articleId];
    if (cachedArticle != null) {
      return cachedArticle;
    }

    if (!isNewsApiArticleId(articleId)) {
      return null;
    }

    final headlines = await getTopHeadlines();

    for (final article in headlines) {
      if (article.id == articleId) {
        return article;
      }
    }

    return null;
  }

  @override
  bool isNewsApiArticleId(String articleId) {
    return articleId.startsWith(_newsApiArticleIdPrefix);
  }

  ArticleModel _normalizeArticle(ArticleModel article) {
    return ArticleModel(
      id: _buildArticleId(article),
      author: _normalizeText(article.author, fallback: 'NewsAPI'),
      title: _normalizeText(article.title),
      description: _normalizeText(article.description),
      url: _normalizeNullableText(article.url),
      urlToImage: _normalizeImage(article.urlToImage),
      publishedAt: _normalizePublishedAt(article.publishedAt),
      content: _normalizeText(article.content),
      status: 'published',
    );
  }

  String _buildArticleId(ArticleModel article) {
    final seed = [
      article.url,
      article.title,
      article.description,
      article.author,
      article.publishedAt,
    ].where(_hasText).join('|');

    final encodedSeed = base64Url
        .encode(utf8.encode(seed.isEmpty ? 'headline-without-identity' : seed))
        .replaceAll('=', '');

    return '$_newsApiArticleIdPrefix$encodedSeed';
  }

  String _normalizeText(String? value, {String fallback = ''}) {
    final normalized = _normalizeNullableText(value);
    return normalized ?? fallback;
  }

  String? _normalizeNullableText(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String _normalizeImage(String? value) {
    return _normalizeNullableText(value) ?? kDefaultImage;
  }

  String _normalizePublishedAt(String? value) {
    final parsedDate = value == null ? null : DateTime.tryParse(value);
    if (parsedDate == null) {
      return _normalizeText(value);
    }

    return parsedDate.toIso8601String().split('T').first;
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
