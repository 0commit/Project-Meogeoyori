class CommentModel {
  final String id;
  final String userId;
  final String shortId;
  final String content;
  final DateTime createdAt;
  final String userName;
  final String profileImageUrl;

  CommentModel({
    required this.id,
    required this.userId,
    required this.shortId,
    required this.content,
    required this.createdAt,
    required this.userName,
    required this.profileImageUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String name = "익명";
    String avatar = "";
    if (json['profiles'] != null) {
      if (json['profiles']['nickname'] != null) {
        name = json['profiles']['nickname'];
      }
      if (json['profiles']['avatar_url'] != null) {
        avatar = json['profiles']['avatar_url'];
      }
    }

    return CommentModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      shortId: json['short_id']?.toString() ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      userName: name,
      profileImageUrl: avatar,
    );
  }
}
