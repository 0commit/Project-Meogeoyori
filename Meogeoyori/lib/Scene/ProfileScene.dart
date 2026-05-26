import 'package:flutter/material.dart';

class ProfileScene extends StatefulWidget {
  const ProfileScene({super.key});

  @override
  State<ProfileScene> createState() => _ProfileSceneState();
}

class _ProfileSceneState extends State<ProfileScene> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orangeAccent, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.5),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2C2C2E),
                            ),
                            child: const Icon(Icons.person, color: Colors.white54, size: 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "요리초보 김자취",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "@cooking_kim",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1C1C1E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "0",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "찜한 레시피",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "최근 본 레시피",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Column(
                        children: [
                          Text(
                            "찜한 레시피",
                            style: TextStyle(
                              color: _selectedTabIndex == 0 ? Colors.white : Colors.white54,
                              fontSize: 15,
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 2,
                            color: _selectedTabIndex == 0 ? Colors.orange : Colors.white.withOpacity(0.1),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Column(
                        children: [
                          Text(
                            "최근 본 레시피",
                            style: TextStyle(
                              color: _selectedTabIndex == 1 ? Colors.white : Colors.white54,
                              fontSize: 15,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 2,
                            color: _selectedTabIndex == 1 ? Colors.orange : Colors.white.withOpacity(0.1),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedTabIndex == 0 ? Icons.favorite_border : Icons.history,
                    color: Colors.white.withOpacity(0.05),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _selectedTabIndex == 0 
                        ? "아직 찜한 레시피가 없어요.\n마음에 드는 레시피에 하트를 눌러보세요!"
                        : "최근 본 레시피가 없습니다.\n다양한 요리를 탐색해보세요!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      "레시피 보러가기",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}