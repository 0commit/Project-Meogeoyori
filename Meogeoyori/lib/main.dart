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
      title: '',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
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
    HomeScene(),
    SearchScene(),
    TimerScene(),
    ProfileScene()
  ];

  @override
  Widget build(BuildContext context) {
    // 바깥쪽 Scaffold: 웹 환경에서 보이는 회색/검정색 여백
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450), // 모바일 가로 사이즈 제한
          // 안쪽 Scaffold: 실제 모바일 앱 화면
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
                BottomNavigationBarItem(icon: Icon(Icons.search),label: '탐색'),
                BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
