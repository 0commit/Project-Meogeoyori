import 'package:flutter/material.dart';

class ShortsModel {
  final String videoUrl;
  final String creatorName;
  final String title;
  final List<String> hashtags;
  final String musicName;
  final String likeCount;
  final String commentCount;

  ShortsModel({
    required this.videoUrl,
    required this.creatorName,
    required this.title,
    required this.hashtags,
    required this.musicName,
    required this.likeCount,
    required this.commentCount,
  });

  factory ShortsModel.fromJson(Map<String, dynamic> json) {
    return ShortsModel(
      videoUrl: json['video_url'] ?? '',
      creatorName: json['creator_name'] ?? '알 수 없음',
      title: json['title'] ?? '',
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : [],
      musicName: json['music_name'] ?? 'Original Sound',
      likeCount: json['like_count'] ?? '0',
      commentCount: json['comment_count'] ?? '0',
    );
  }
}
