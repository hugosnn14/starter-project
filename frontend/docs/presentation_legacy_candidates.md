# Presentation Legacy Candidates

The active presentation flow is now wired through:

- `lib/main.dart`
- `lib/config/routes/routes.dart`
- `lib/injection_container.dart`
- `lib/features/daily_news/presentation/bloc/article/articles_bloc.dart`
- `lib/features/daily_news/presentation/bloc/article_details/article_details_bloc.dart`
- `lib/features/daily_news/presentation/bloc/create_article/create_article_bloc.dart`
- `lib/features/daily_news/presentation/bloc/saved_articles/saved_articles_bloc.dart`

The following files remain in the repository for reference and review, but are
intentionally disconnected from the active application path:

- `lib/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart`
- `lib/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart`
- `lib/features/daily_news/presentation/pages/create_article/create_article.dart`

Possible future cleanup, once the team agrees to remove legacy code:

- Delete the legacy remote/local bloc trees after verifying no references remain.
- Delete the legacy create screen after the editorial editor is accepted.
- Keep route names and DI registrations aligned only with the active Bloc flow.
