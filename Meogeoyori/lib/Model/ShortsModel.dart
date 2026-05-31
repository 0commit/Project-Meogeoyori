import 'package:flutter/material.dart';

class ShortsModel {
  final String id;
  final String videoUrl;
  final String creatorName;
  final String title;
  final List<String> hashtags;
  final String musicName;
  final String likeCount;
  final String commentCount;
  final List<dynamic> ingredients;
  final List<dynamic> recipeSteps;

  ShortsModel({
    required this.id,
    required this.videoUrl,
    required this.creatorName,
    required this.title,
    required this.hashtags,
    required this.musicName,
    required this.likeCount,
    required this.commentCount,
    this.ingredients = const [],
    this.recipeSteps = const [],
  });

  factory ShortsModel.fromJson(Map<String, dynamic> json) {
    return ShortsModel(
      id: json['id']?.toString() ?? '',
      videoUrl: json['video_url'] ?? '',
      creatorName: json['creator_name'] ?? '알 수 없음',
      title: json['title'] ?? '',
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : [],
      musicName: json['music_name'] ?? 'Original Sound',
      likeCount: json['like_count']?.toString() ?? '0',
      commentCount: json['comment_count']?.toString() ?? '0',
      ingredients: json['ingredients'] != null ? List<dynamic>.from(json['ingredients']) : [],
      recipeSteps: json['recipe_steps'] != null ? List<dynamic>.from(json['recipe_steps']) : [],
    );
  }
}
