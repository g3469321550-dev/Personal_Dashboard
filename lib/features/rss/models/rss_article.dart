class RssArticle {
  final String id;
  final String sourceId;
  final String sourceName;
  final String title;
  final String? summary;
  final String content;
  final String link;
  final String? imageUrl;
  final List<String> categories;
  final DateTime publishedAt;
  final bool isRead;
  final bool isBookmarked;

  RssArticle({
    required this.id,
    required this.sourceId,
    required this.sourceName,
    required this.title,
    this.summary,
    required this.content,
    required this.link,
    this.imageUrl,
    List<String>? categories,
    required this.publishedAt,
    this.isRead = false,
    this.isBookmarked = false,
  }) : categories = categories ?? [];

  RssArticle copyWith({
    bool? isRead,
    bool? isBookmarked,
  }) {
    return RssArticle(
      id: id,
      sourceId: sourceId,
      sourceName: sourceName,
      title: title,
      summary: summary,
      content: content,
      link: link,
      imageUrl: imageUrl,
      categories: categories,
      publishedAt: publishedAt,
      isRead: isRead ?? this.isRead,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceId': sourceId,
        'sourceName': sourceName,
        'title': title,
        'summary': summary,
        'content': content,
        'link': link,
        'imageUrl': imageUrl,
        'categories': categories,
        'publishedAt': publishedAt.toIso8601String(),
        'isRead': isRead,
        'isBookmarked': isBookmarked,
      };

  factory RssArticle.fromJson(Map<String, dynamic> json) => RssArticle(
        id: json['id'] as String,
        sourceId: json['sourceId'] as String,
        sourceName: json['sourceName'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String?,
        content: json['content'] as String? ?? '',
        link: json['link'] as String,
        imageUrl: json['imageUrl'] as String?,
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
}
