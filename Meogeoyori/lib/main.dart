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

    return Scaffold(
      body: selectedScene[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.search),label: '탐색'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이')
        ],
      ),
    );
  }
}
