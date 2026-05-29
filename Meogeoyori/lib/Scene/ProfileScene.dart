import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meogeoyori/Scene/SearchScene.dart';
import 'package:meogeoyori/Scene/TimerScene.dart';
import 'package:meogeoyori/Scene/ProfileSettingsScene.dart';
import 'package:meogeoyori/Scene/SignUpProfileScene.dart';
import 'package:meogeoyori/Scene/EmailLoginScene.dart';
import 'package:meogeoyori/Scene/ResetPasswordScene.dart';

class ProfileScene extends StatefulWidget {
  const ProfileScene({super.key});

  @override
  State<ProfileScene> createState() => _ProfileSceneState();
}

class _ProfileSceneState extends State<ProfileScene> {
  bool _isLoading = false;
  bool _isLoadingProfile = false;
  Map<String, dynamic>? _userProfile;

  final String _webClientId = '660036666717-4b9djjcl1e4snq3uqq0hmbgt1mgb5r7s.apps.googleusercontent.com';
  final String _iosClientId = '660036666717-99e715r4prau03cm92na40nu66u65ftp.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();
    if (_isLoggedIn) {
      _checkProfile();
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ResetPasswordScene()),
          );
          return;
        }

        if (data.session != null) {
          _checkProfile();
        } else {
          setState(() {
            _userProfile = null;
          });
        }
      }
    });
  }

  Future<void> _checkProfile() async {
    if (!_isLoggedIn) return;
    
    setState(() { _isLoadingProfile = true; });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        if (mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignUpProfileScene()),
          );
          _checkProfile();
        }
      } else {
        if (mounted) {
          setState(() {
            _userProfile = data;
          });
        }
      }
    } catch (e) {
      debugPrint('Profile check error: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoadingProfile = false; });
      }
    }
  }

  bool get _isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  Future<void> _signInWithKakao() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Supabase OAuth 딥링크 방식으로 카카오 로그인 수행
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: 'com.project.meogeoyori://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
      // 참고: signInWithOAuth는 웹뷰를 띄운 후 딥링크를 통해 앱으로 돌아옵니다.
      // 딥링크 콜백 처리는 Supabase SDK가 내부적으로 알아서 처리하며, 
      // Session 상태가 변경되면 onAuthStateChange 이벤트에 의해 알 수 있지만
      // 여기서는 버튼 로딩 상태만 해제합니다. 앱 재진입 시 상태가 갱신됩니다.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _webClientId,
        clientId: _iosClientId,
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        setState(() { _isLoading = false; });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'ID 토큰을 찾을 수 없습니다.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (mounted) {
        setState(() {}); // UI 갱신하여 프로필 뷰로 전환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
              ? KeyedSubtree(key: const ValueKey('profile'), child: _isLoadingProfile ? const Center(child: CircularProgressIndicator(color: Colors.orange)) : _buildProfileView())
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
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.orange))
              else
                _buildLoginButton(
                  title: "Google로 시작하기",
                  color: Colors.white,
                  textColor: Colors.black87,
                  iconWidget: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 32),
                  onTap: _signInWithGoogle,
                ),
              const SizedBox(height: 16),
                _buildLoginButton(
                  title: "카카오로 계속하기",
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                  iconWidget: const Icon(Icons.chat_bubble, color: Colors.black87, size: 24),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('업데이트 예정입니다.'), backgroundColor: Colors.orange),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  title: "네이버로 계속하기",
                  color: const Color(0xFF03C75A),
                  textColor: Colors.white,
                  iconWidget: const Text("N", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('업데이트 예정입니다.'), backgroundColor: Colors.orange),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  title: "이메일로 계속하기",
                  color: const Color(0xFF1C1C1E),
                  textColor: Colors.white,
                  iconWidget: const Icon(Icons.email_outlined, color: Colors.white, size: 24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EmailLoginScene()),
                    );
                  },
                ),
                const SizedBox(height: 48),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Row(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?['nickname'] ?? '이름 없음',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userProfile?['cooking_level'] ?? '레벨 미상',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final bool? shouldRefresh = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileSettingsScene(),
                      ),
                    );
                    
                    if (shouldRefresh == true && mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings, color: Colors.white70, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: "찜한 레시피"),
              Tab(text: "최근 본 레시피"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildEmptyState(true),
                _buildEmptyState(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSaved) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSaved ? Icons.favorite_border : Icons.history,
          color: Colors.white.withOpacity(0.05),
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          isSaved 
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
    );
  }
}