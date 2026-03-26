import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article_draft.dart';

@dao
abstract class ArticleDraftDao {
  @Query('SELECT * FROM article_draft WHERE draftKey = :draftKey LIMIT 1')
  Future<ArticleDraftModel?> getDraftByKey(String draftKey);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> saveDraft(ArticleDraftModel articleDraft);

  @Query('DELETE FROM article_draft WHERE draftKey = :draftKey')
  Future<void> deleteDraftByKey(String draftKey);
}
