class RssSource {
  final String id;
  final String name;
  final String url;
  final String? siteUrl;
  final String? iconUrl;
  final List<String> categories;
  final bool isEnabled;
  final DateTime lastFetchedAt;
  final DateTime createdAt;

  RssSource({
    required this.id,
    required this.name,
    required this.url,
    this.siteUrl,
    this.iconUrl,
    List<String>? categories,
    this.isEnabled = true,
    DateTime? lastFetchedAt,
    DateTime? createdAt,
  })  : categories = categories ?? [],
        lastFetchedAt = lastFetchedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        createdAt = createdAt ?? DateTime.now();

  RssSource copyWith({
    String? name,
    String? url,
    String? siteUrl,
    String? iconUrl,
    List<String>? categories,
    bool? isEnabled,
    DateTime? lastFetchedAt,
  }) {
    return RssSource(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      siteUrl: siteUrl ?? this.siteUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      categories: categories ?? this.categories,
      isEnabled: isEnabled ?? this.isEnabled,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'siteUrl': siteUrl,
        'iconUrl': iconUrl,
        'categories': categories,
        'isEnabled': isEnabled,
        'lastFetchedAt': lastFetchedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory RssSource.fromJson(Map<String, dynamic> json) => RssSource(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        siteUrl: json['siteUrl'] as String?,
        iconUrl: json['iconUrl'] as String?,
        categories: (json['categories'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        isEnabled: json['isEnabled'] as bool? ?? true,
        lastFetchedAt: DateTime.parse(json['lastFetchedAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
