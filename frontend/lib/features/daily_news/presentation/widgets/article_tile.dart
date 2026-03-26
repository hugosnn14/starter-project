import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/article.dart';

enum ArticleCardVariant { featured, standard }

class ArticleWidget extends StatelessWidget {
  final ArticleEntity article;
  final bool isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;
  final ArticleCardVariant variant;
  final String? badgeLabel;
  final EdgeInsetsGeometry? margin;

  const ArticleWidget({
    super.key,
    required this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
    this.variant = ArticleCardVariant.standard,
    this.badgeLabel,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final content = variant == ArticleCardVariant.featured
        ? _buildFeaturedCard(context)
        : _buildStandardCard(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: content,
    );
  }

  Widget _buildFeaturedCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(
            context,
            width: double.infinity,
            height: 220,
            borderRadius: 24,
          ),
          const SizedBox(height: 18),
          _buildMetaRow(
            context,
            badgeLabel: badgeLabel ?? 'Top story',
          ),
          const SizedBox(height: 12),
          Text(
            article.title ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            article.description ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              color: AppPalette.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  article.author ?? 'Unknown author',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_outward_rounded,
                color: AppPalette.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.width / 2.5,
        child: Row(
          children: [
            _buildImage(
              context,
              width: MediaQuery.of(context).size.width / 3,
              height: double.maxFinite,
              borderRadius: 20,
            ),
            _buildTitleAndDescription(context),
            _buildRemovableArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(
    BuildContext context, {
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return CachedNetworkImage(
        imageUrl: article.urlToImage ?? '',
        imageBuilder: (context, imageProvider) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: variant == ArticleCardVariant.standard ? 14 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceContainer,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: variant == ArticleCardVariant.standard ? 14 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: const CupertinoActivityIndicator(),
                  decoration: const BoxDecoration(
                    color: AppPalette.surfaceContainer,
                  ),
                ),
              ),
            ),
        errorWidget: (context, url, error) => Padding(
              padding: EdgeInsetsDirectional.only(
                end: variant == ArticleCardVariant.standard ? 14 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  width: width,
                  height: height,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.error_outline,
                    color: AppPalette.error,
                  ),
                  decoration: const BoxDecoration(
                    color: AppPalette.surfaceContainer,
                  ),
                ),
              ),
            ));
  }

  Widget _buildTitleAndDescription(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeLabel != null) ...[
              _buildInlineBadge(context, badgeLabel!),
              const SizedBox(height: 10),
            ],
            // Title
            Text(
              article.title ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            // Description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  article.description ?? '',
                  maxLines: 2,
                  style: textTheme.bodyMedium,
                ),
              ),
            ),

            // Datetime
            Row(
              children: [
                const Icon(Icons.timeline_outlined, size: 16),
                const SizedBox(width: 4),
                Text(
                  article.publishedAt ?? '',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppPalette.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineBadge(BuildContext context, String label) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelMedium?.copyWith(
          color: AppPalette.onSecondaryContainer,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildRemovableArea() {
    if (isRemovable) {
      return GestureDetector(
        onTap: _onRemove,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.remove_circle_outline,
            color: AppPalette.error,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetaRow(BuildContext context, {required String badgeLabel}) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppPalette.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badgeLabel.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: AppPalette.onSecondaryContainer,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            article.publishedAt ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium,
          ),
        ),
      ],
    );
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article);
    }
  }
}

class ArticleCardPlaceholder extends StatelessWidget {
  final ArticleCardVariant variant;
  final EdgeInsetsGeometry? margin;

  const ArticleCardPlaceholder({
    super.key,
    this.variant = ArticleCardVariant.standard,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == ArticleCardVariant.featured) {
      return Container(
        margin: margin ?? const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: AppPalette.shadow,
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlaceholderBlock(height: 220, radius: 24),
            SizedBox(height: 18),
            _PlaceholderRow(),
            SizedBox(height: 12),
            _PlaceholderBlock(height: 24, widthFactor: 0.88),
            SizedBox(height: 10),
            _PlaceholderBlock(height: 24, widthFactor: 0.72),
            SizedBox(height: 14),
            _PlaceholderBlock(height: 16, widthFactor: 0.94),
            SizedBox(height: 8),
            _PlaceholderBlock(height: 16, widthFactor: 0.66),
          ],
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppPalette.shadow,
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: const SizedBox(
        height: 150,
        child: Row(
          children: [
            _PlaceholderBlock(
              width: 112,
              height: double.infinity,
              radius: 20,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlaceholderBlock(height: 20, widthFactor: 0.9),
                  SizedBox(height: 10),
                  _PlaceholderBlock(height: 20, widthFactor: 0.76),
                  SizedBox(height: 12),
                  _PlaceholderBlock(height: 14, widthFactor: 1),
                  SizedBox(height: 8),
                  _PlaceholderBlock(height: 14, widthFactor: 0.74),
                  Spacer(),
                  _PlaceholderBlock(height: 12, widthFactor: 0.35),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _PlaceholderBlock(width: 92, height: 28, radius: 999),
        SizedBox(width: 10),
        Expanded(
          child: _PlaceholderBlock(height: 12, widthFactor: 0.42),
        ),
      ],
    );
  }
}

class _PlaceholderBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double widthFactor;
  final double radius;

  const _PlaceholderBlock({
    this.width,
    required this.height,
    this.widthFactor = 1,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final block = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (width != null) {
      return block;
    }

    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: block,
    );
  }
}
