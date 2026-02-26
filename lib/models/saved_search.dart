class SavedSearch {
  final String id;
  final String userId;
  final String searchTerm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavedSearch({
    required this.id,
    required this.userId,
    required this.searchTerm,
    this.createdAt,
    this.updatedAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      searchTerm: (json['search_term'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
