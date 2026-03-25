# Firestore DB Schema

## Goal
Define a Firestore schema for journalist-created articles that:
- fits the current frontend article model,
- is easy to validate with Firestore rules,
- stores thumbnails in Firebase Cloud Storage under `media/articles`,
- leaves room for later implementation without overcomplicating the first version.

## Design Principles
- Keep the write model simple: one top-level collection for articles.
- Store only the data needed to render and manage an article.
- Use Firestore document IDs as the article identifier instead of duplicating numeric IDs.
- Store a Cloud Storage reference, not a hardcoded external image URL.
- Keep moderation and lifecycle fields explicit so rules can be enforced later.

## Collections

### `articles`
Top-level collection containing every journalist-created article.

Document path:

```text
articles/{articleId}
```

`articleId`:
- Firestore auto-generated document id.
- Used as the canonical identifier across Firestore, Storage and frontend integration.

## Article Document Schema

| Field | Type | Required | Example | Notes |
|---|---|---|---|---|
| `authorId` | `string` | Yes | `"uid_123"` | Firebase Auth user id of the journalist who owns the article. |
| `authorName` | `string` | Yes | `"Ada Lovelace"` | Human-readable author name shown in the UI. |
| `title` | `string` | Yes | `"How Cities Can Reuse Water Better"` | Main article title. |
| `description` | `string` | Yes | `"A short summary for article cards and previews."` | Short summary used in list views. |
| `content` | `string` | Yes | `"Full article body..."` | Main body text of the article. |
| `category` | `string` | Yes | `"general"` | Matches the current app filtering direction and future queries. |
| `thumbnailPath` | `string` | Yes | `"media/articles/{articleId}/thumbnail.jpg"` | Firebase Cloud Storage path for the article thumbnail. |
| `status` | `string` | Yes | `"published"` | Allowed values: `draft`, `published`, `archived`. |
| `publishedAt` | `timestamp \| null` | No | `Timestamp(...)` | Null while draft; required once published. |
| `createdAt` | `timestamp` | Yes | `Timestamp(...)` | Audit field for initial creation. |
| `updatedAt` | `timestamp` | Yes | `Timestamp(...)` | Audit field for latest update. |
| `sourceUrl` | `string \| null` | No | `"https://example.com/original-story"` | Optional external reference when the article is adapted from another source. |
| `tags` | `array<string>` | No | `["water", "climate"]` | Optional metadata for later search/filter features. |

## Storage Schema

Thumbnails must live in Firebase Cloud Storage under:

```text
media/articles/{articleId}/thumbnail.{extension}
```

Examples:

```text
media/articles/abc123/thumbnail.jpg
media/articles/abc123/thumbnail.webp
```

Decision:
- Firestore stores `thumbnailPath`, not the download URL.
- The app can resolve this path through Firebase Storage when building the final UI model.
- This avoids stale public URLs and makes storage rules easier to reason about.

## Firestore Example

```json
{
  "authorId": "uid_123",
  "authorName": "Ada Lovelace",
  "title": "How Cities Can Reuse Water Better",
  "description": "A short summary for article cards and previews.",
  "content": "Full article body written by the journalist.",
  "category": "general",
  "thumbnailPath": "media/articles/article_001/thumbnail.jpg",
  "status": "published",
  "publishedAt": "Firestore Timestamp",
  "createdAt": "Firestore Timestamp",
  "updatedAt": "Firestore Timestamp",
  "sourceUrl": null,
  "tags": ["water", "climate"]
}
```

## Mapping to the Current Frontend Model

The existing frontend article entity uses these fields:
- `author`
- `title`
- `description`
- `url`
- `urlToImage`
- `publishedAt`
- `content`

Recommended mapping from Firestore to frontend:
- `authorName` -> `author`
- `title` -> `title`
- `description` -> `description`
- `sourceUrl` -> `url`
- resolved `thumbnailPath` download URL -> `urlToImage`
- `publishedAt` formatted as string -> `publishedAt`
- `content` -> `content`

This keeps the backend schema clean while preserving compatibility with the current presentation layer.

## Comparison with the Current News API Shape

The assignment suggests studying the article data already used by the app. Today, the frontend consumes NewsAPI articles with this effective shape:

```json
{
  "author": "string",
  "title": "string",
  "description": "string",
  "url": "string",
  "urlToImage": "string",
  "publishedAt": "string",
  "content": "string"
}
```

This schema was the starting point for the Firestore design, but it was not copied literally because Firestore must support journalist-owned content, lifecycle management and Cloud Storage integration.

| NewsAPI field | Firestore field | Reason |
|---|---|---|
| `author` | `authorName` | Keeps the visible author name while separating it from identity concerns. |
| not present | `authorId` | Needed to know which authenticated journalist owns the article. |
| `title` | `title` | Direct mapping. |
| `description` | `description` | Direct mapping. |
| `content` | `content` | Direct mapping. |
| `publishedAt` | `publishedAt` | Same meaning, but stored as Firestore `timestamp` instead of UI string data. |
| `url` | `sourceUrl` | Optional source reference instead of assuming every article needs a public external link. |
| `urlToImage` | `thumbnailPath` | The assignment requires images to live in Firebase Cloud Storage under `media/articles`, so a storage path is more appropriate than an external URL. |
| not present | `status` | Needed to support draft, published and archived article states. |
| not present | `createdAt` / `updatedAt` | Required for auditability, ordering and safe updates. |
| not present | `category` | Useful for filtering and aligned with the current app's query pattern. |
| not present | `tags` | Optional metadata for future search and classification. |

Conclusion:
- NewsAPI defines the content shape the UI already expects.
- Firestore extends that shape with ownership, timestamps and publication metadata.
- The main structural change is replacing `urlToImage` with `thumbnailPath` to comply with the Firebase Storage requirement.

## Query Patterns This Schema Supports
- List latest published articles:
  - filter `status == "published"`
  - order by `publishedAt desc`
- List published articles by category:
  - filter `status == "published"`
  - filter `category == ...`
  - order by `publishedAt desc`
- List articles created by one journalist:
  - filter `authorId == ...`
  - order by `createdAt desc`

## Suggested Indexes for Later Implementation
- `status ASC, publishedAt DESC`
- `category ASC, status ASC, publishedAt DESC`
- `authorId ASC, createdAt DESC`

## Why This Schema
- It is inspired by the article structure already used by the News API-backed frontend.
- It supports the new requirement of journalists uploading their own content.
- It is straightforward to enforce with Firestore rules.
- It avoids unnecessary nesting, which keeps writes, reads and validation simpler.
