import 'package:flutter/material.dart';

class ShortsModel {
  final Color backgroundColor;
  final String creatorName;
  final String title;
  final List<String> hashtags;
  final String musicName;
  final String likeCount;
  final String commentCount;

  ShortsModel({
    required this.backgroundColor,
    required this.creatorName,
    required this.title,
    required this.hashtags,
    required this.musicName,
    required this.likeCount,
    required this.commentCount,
  });
}

class ShortsDummyData {
  static final List<ShortsModel> shortsList = [
    ShortsModel(
      backgroundColor: Colors.black87,
      creatorName: "요리하는 백수",
      title: "매콤달콤 떡볶이 황금 레시피 공개! 🧑‍🍳\n이대로만 만들면 실패 없음",
      hashtags: ["떡볶이", "레시피"],
      musicName: "Original Sound - 달달떡볶이",
      likeCount: "1.2만",
      commentCount: "345",
    ),
    ShortsModel(
      backgroundColor: const Color(0xFF1C2833),
      creatorName: "건강식단 코치",
      title: "아침에 먹기 딱 좋은 닭가슴살 샐러드 🥗\n다이어트 식단 완성하기",
      hashtags: ["건강", "다이어트"],
      musicName: "Morning Sunshine - Workout Beat",
      likeCount: "8,300",
      commentCount: "128",
    ),
    ShortsModel(
      backgroundColor: const Color(0xFF3E2723),
      creatorName: "캠핑의 달인",
      title: "밤에 보면 큰일나는 캠핑장 삼겹살 바베큐 🥩\n숯불 향 가득한 고기파티",
      hashtags: ["캠핑", "바베큐"],
      musicName: "Camping Vibes - Acoustic",
      likeCount: "4.5만",
      commentCount: "892",
    ),
    ShortsModel(
      backgroundColor: const Color(0xFF1B5E20),
      creatorName: "비건 라이프",
      title: "고기 없이도 맛있는 단호박 파스타 🎃\n건강하고 배부르게 먹기",
      hashtags: ["비건", "파스타"],
      musicName: "Peaceful Piano - Nature",
      likeCount: "2.1만",
      commentCount: "560",
    ),
  ];
}
