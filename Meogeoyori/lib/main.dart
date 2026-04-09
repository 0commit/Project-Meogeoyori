import 'package:flutter/material.dart';
import 'package:meogeoyori/Scene/HomeScene.dart';
import 'package:meogeoyori/Scene/ProfileScene.dart';
import 'package:meogeoyori/Scene/SearchScene.dart';
import 'package:meogeoyori/Scene/TimerScene.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '머거요리',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  List<Widget> selectedScene = [
    const HomeScene(),
    const SearchScene(),
    const TimerScene(),
    const ProfileScene()
  ];

  @override
  Widget build(BuildContext context) {
    // 안쪽 Scaffold: 실제 모바일 앱 화면 (공통)
    Widget mobileApp = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Scaffold(
        body: selectedScene[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '탐색'),
            BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이')
          ],
        ),
      ),
    );

    // 바깥쪽 Scaffold: 웹/모바일 반응형 배경
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 화면의 가로 너비가 900px 이상이면(웹/PC 환경) 좌측에 멋진 소개 패널 추가!
          bool isWideScreen = constraints.maxWidth > 900;

          if (isWideScreen) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 좌측 영역: 고급스러운 앱 소개 UI
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 40, right: 120), // 중앙 앱 화면과의 간격(여백)을 확 넓힘
                    alignment: Alignment.centerRight, // 오른쪽 정렬 유지
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Meogeoyori\nApp",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "세상에서 가장 맛있는 1분을 경험하세요.\n당신의 미각을 깨울 최고의 요리 영상들이\n매일 새롭게 업데이트 됩니다.",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            height: 1.6,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildStoreButton(Icons.apple, "App Store"),
                            const SizedBox(width: 14),
                            _buildStoreButton(Icons.android, "Google Play"),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // 중앙 영역: 우리가 만든 실제 앱 (모바일 크기 450px)
                mobileApp,

                // 우측 영역: 여백 밸런스를 맞추기 위한 빈 공간
                Expanded(
                  child: Container(),
                ),
              ],
            );
          } else {
            // 화면이 좁은 모바일일 때: 기존처럼 중앙 정렬만 함
            return Center(child: mobileApp);
          }
        },
      ),
    );
  }

  // 간단한 스토어 다운로드 버튼 UI 만드는 함수
  Widget _buildStoreButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
