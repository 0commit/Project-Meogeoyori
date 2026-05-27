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
}

class ShortsDummyData {
  static final List<ShortsModel> shortsList = [
    ShortsModel(
      videoUrl: "https://prnlzgxgbmlfhvykuffp.supabase.co/storage/v1/object/public/Video/SampleVideo1.mp4",
      creatorName: "수파베이스 셰프",
      title: "첫 번째 클라우드 스트리밍 테스트 ☁️\n로딩 없이 바로 재생되는지 확인해보세요!",
      hashtags: ["클라우드", "스트리밍", "수파베이스"],
      musicName: "Cloud Vibe - Streaming",
      likeCount: "1.5만",
      commentCount: "256",
    ),
    ShortsModel(
      videoUrl: "https://prnlzgxgbmlfhvykuffp.supabase.co/storage/v1/object/public/Video/SampleVideo2.mp4",
      creatorName: "방구석 요리사",
      title: "두 번째 테스트 영상 🎬\n위아래로 스와이프해서 다음 영상이 잘 넘어가나 볼까요?",
      hashtags: ["테스트", "스와이프", "영상"],
      musicName: "Smooth Transition - Beat",
      likeCount: "8,900",
      commentCount: "123",
    ),
    ShortsModel(
      videoUrl: "https://prnlzgxgbmlfhvykuffp.supabase.co/storage/v1/object/public/Video/SampleVideo3.mp4",
      creatorName: "다이어터의 식단",
      title: "세 번째 영상 도착! 🥗\n클라우드에서 가져오는 고화질 영상 테스트 중입니다.",
      hashtags: ["건강", "샐러드", "클라우드"],
      musicName: "Healthy Vibe - Acoustic",
      likeCount: "3,200",
      commentCount: "88",
    ),
    ShortsModel(
      videoUrl: "https://prnlzgxgbmlfhvykuffp.supabase.co/storage/v1/object/public/Video/SampleVideo4.mp4",
      creatorName: "캠핑 마스터",
      title: "네 번째 영상 🏕️\n이 정도면 스크롤 할 때 끊김 없이 아주 훌륭하네요!",
      hashtags: ["캠핑", "바베큐", "수파베이스"],
      musicName: "Campfire Song - Relaxing",
      likeCount: "2.1만",
      commentCount: "412",
    ),
    ShortsModel(
      videoUrl: "https://prnlzgxgbmlfhvykuffp.supabase.co/storage/v1/object/public/Video/SampleVideo5.mp4",
      creatorName: "디저트 굽는 사람",
      title: "다섯 번째 테스트 영상 🧁\n달콤한 디저트 레시피도 스트리밍으로 만나보세요!",
      hashtags: ["디저트", "홈베이킹", "달달"],
      musicName: "Sweet Baking Time - Piano",
      likeCount: "4.8천",
      commentCount: "159",
    ),
  ];
}
