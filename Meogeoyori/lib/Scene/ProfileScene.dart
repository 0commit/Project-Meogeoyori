import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileScene extends StatefulWidget {
  const ProfileScene({super.key});

  @override
  State<ProfileScene> createState() => _ProfileSceneState();
}

class _ProfileSceneState extends State<ProfileScene> {
  int _selectedTabIndex = 0;
  bool _isLoggedIn = false; // 임시 로그인 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoggedIn ? Colors.black : const Color(0xFF0F0F13),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isLoggedIn
              ? KeyedSubtree(key: const ValueKey('profile'), child: _buildProfileView())
              : KeyedSubtree(key: const ValueKey('login'), child: _buildLoginView()),
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF5722)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: Icon(Icons.soup_kitchen, size: 48, color: Colors.white),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0F0F13), width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "머거요리",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "1분 레시피부터 스마트 타이머까지",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                "요리가 즐거워지는 앱",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _buildLoginButton(
                title: "카카오로 계속하기",
                color: const Color(0xFFFEE500),
                textColor: Colors.black87,
                iconWidget: const Icon(Icons.chat_bubble, color: Colors.black87, size: 20),
              ),
              const SizedBox(height: 12),
              _buildLoginButton(
                title: "네이버로 계속하기",
                color: const Color(0xFF03C75A),
                textColor: Colors.white,
                iconWidget: const Text("N", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              _buildLoginButton(
                title: "Google로 계속하기",
                color: Colors.white,
                textColor: Colors.black87,
                iconWidget: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 28),
              ),
              if (defaultTargetPlatform == TargetPlatform.iOS) ...[
                const SizedBox(height: 12),
                _buildLoginButton(
                  title: "Apple로 계속하기",
                  color: const Color(0xFF222224),
                  textColor: Colors.white,
                  iconWidget: const Icon(Icons.apple, color: Colors.white, size: 22),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.white12)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("또는", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.white12)),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isLoggedIn = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.mail_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("이메일로 로그인", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "계속 진행하면 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 24),
            ],
          ),
    );
  }

  Widget _buildLoginButton({
    required String title,
    required Color color,
    required Color textColor,
    required Widget iconWidget,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isLoggedIn = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: iconWidget,
            ),
            Center(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
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
                      GestureDetector(
                        onTap: () {
                          // 로그아웃 (임시 테스트용)
                          setState(() {
                            _isLoggedIn = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C1C1E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout, color: Colors.white70, size: 20),
                        ),
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
                    style: const TextStyle(
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
    );
  }
}