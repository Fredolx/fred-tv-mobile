class Source {
  final int? id;
  final String name;
  final String? url;
  final String? urlOrigin;
  final String? username;
  final String? password;
  final int sourceType;
  final bool? useTvgId;
  final bool enabled;

  Source({
    this.id,
    required this.name,
    this.url,
    this.urlOrigin,
    this.username,
    this.password,
    required this.sourceType,
    this.useTvgId,
    required this.enabled,
  });
}
