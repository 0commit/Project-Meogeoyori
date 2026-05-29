import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meogeoyori/Scene/HomeScene.dart';
import 'package:meogeoyori/main.dart';

class LoginScene extends StatefulWidget {
  const LoginScene({super.key});

  @override
  State<LoginScene> createState() => _LoginSceneState();
}

class _LoginSceneState extends State<LoginScene> {
  bool _isLoading = false;

  // 구글 클라우드 콘솔에서 발급받은 클라이언트 ID
  final String _webClientId = '660036666717-4b9djjcl1e4snq3uqq0hmbgt1mgb5r7s.apps.googleusercontent.com';
  final String _iosClientId = '660036666717-99e715r4prau03cm92na40nu66u65ftp.apps.googleusercontent.com';

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
        // 사용자가 로그인을 취소함
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'ID 토큰을 찾을 수 없습니다.';
      }

      // Supabase 인증 수행
      final AuthResponse response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.session != null && mounted) {
        // 로그인 성공 시 메인 네비게이션 화면으로 재시작
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MyHomePage(title: '')),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.redAccent,
          ),
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // 로고 또는 타이틀 영역
              const Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Colors.orangeAccent,
              ),
              const SizedBox(height: 24),
              const Text(
                '먹어보리',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '나만의 숏폼 레시피를 만나보세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              
              // 로그인 버튼
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orangeAccent,
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 구글 아이콘 대신 기본 아이콘 사용 (에셋이 없을 수 있으므로)
                      const Icon(Icons.g_mobiledata, size: 32, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Google로 계속하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
