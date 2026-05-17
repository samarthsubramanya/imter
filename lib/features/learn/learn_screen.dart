import 'package:flutter/material.dart';

import 'format_articles.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final selected = formatArticles[_selectedIndex];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn Formats',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'A compact guide to picking the right output format.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 860;
                if (compact) {
                  return ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      _ArticleSelector(
                        selectedIndex: _selectedIndex,
                        scrollable: false,
                        onChanged: (index) =>
                            setState(() => _selectedIndex = index),
                      ),
                      const SizedBox(height: 16),
                      _ArticlePanel(article: selected),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 300,
                      child: _ArticleSelector(
                        selectedIndex: _selectedIndex,
                        onChanged: (index) =>
                            setState(() => _selectedIndex = index),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ArticlePanel(article: selected, scrollable: true),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleSelector extends StatelessWidget {
  const _ArticleSelector({
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (var index = 0; index < formatArticles.length; index++)
        _ArticleTile(
          article: formatArticles[index],
          selected: index == selectedIndex,
          onTap: () => onChanged(index),
        ),
    ];

    return Card(
      child: scrollable
          ? ListView.separated(
              primary: false,
              physics: const ClampingScrollPhysics(),
              itemCount: tiles.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) => tiles[index],
            )
          : Column(
              children: [
                for (var index = 0; index < tiles.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  tiles[index],
                ],
              ],
            ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({
    required this.article,
    required this.selected,
    required this.onTap,
  });

  final FormatArticle article;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.45),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : const Color(0xff102d2a),
        foregroundColor: Colors.white,
        child: Text(
          article.format.label.substring(
            0,
            article.format.label.length >= 2 ? 2 : 1,
          ),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ),
      title: Text(article.format.label),
      subtitle: Text(
        article.format.bestFor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}

class _ArticlePanel extends StatelessWidget {
  const _ArticlePanel({required this.article, this.scrollable = false});

  final FormatArticle article;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final children = [
      Row(
        children: [
          Container(
            width: 68,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff102d2a),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              article.format.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.format.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${article.format.lossy ? 'Lossy' : 'Lossless'} · ${article.format.supportsAlpha ? 'Transparency' : 'No transparency'} · ${article.format.supportsAnimation ? 'Animation' : 'Static'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      _ArticleSection(title: 'Overview', body: article.summary),
      _ArticleSection(title: 'Best For', body: article.bestFor),
      _ArticleSection(title: 'Watch Out For', body: article.watchOutFor),
      _ArticleSection(
        title: 'Recommended Settings',
        body: article.recommendedSettings,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: scrollable
            ? ListView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                children: children,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  const _ArticleSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
