import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:meogeoyori/Scene/EmailLoginScene.dart';

void showLoginModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Login Modal",
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _LoginModalWidget();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

class _LoginModalWidget extends StatefulWidget {
  const _LoginModalWidget();

  @override
  State<_LoginModalWidget> createState() => _LoginModalWidgetState();
}

class _LoginModalWidgetState extends State<_LoginModalWidget> {
  bool _isLoading = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('Media/Video/LoginBG.mp4')
      ..initialize().then((_) {
        _videoController!.setVolume(0.0);
        _videoController!.setLooping(true);
        _videoController!.play();
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; });
    try {
      final String webClientId = '660036666717-4b9djjcl1e4snq3uqq0hmbgt1mgb5r7s.apps.googleusercontent.com';
      final String iosClientId = '660036666717-99e715r4prau03cm92na40nu66u65ftp.apps.googleusercontent.com';
      
      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
        clientId: iosClientId,
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        if (mounted) setState(() { _isLoading = false; });
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'ID 토큰을 찾을 수 없습니다.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Google 로그인 실패: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  Future<void> _signInWithKakao() async {
    setState(() { _isLoading = true; });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: 'com.project.meogeoyori://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Kakao 로그인 실패: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F0F13),
      child: Stack(
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF5722)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Icon(Icons.soup_kitchen, size: 40, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "머거요리 시작하기",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "레시피 저장과 타이머를 이용해 보세요",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Colors.orange))
              else ...[
                _buildLoginButton(
                  title: "Google로 시작하기",
                  color: Colors.white,
                  textColor: Colors.black87,
                  iconWidget: const Icon(Icons.g_mobiledata, color: Colors.black87, size: 32),
                  onTap: _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  title: "카카오로 계속하기",
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                  iconWidget: const Icon(Icons.chat_bubble, color: Colors.black87, size: 24),
                  onTap: _signInWithKakao,
                ),
                const SizedBox(height: 12),
                if (!kIsWeb && Platform.isIOS) ...[
                  _buildLoginButton(
                    title: "Apple로 계속하기",
                    color: Colors.white,
                    textColor: Colors.black87,
                    iconWidget: const Icon(Icons.apple, color: Colors.black87, size: 28),
                    onTap: () {
                      _showSnackBar('업데이트 예정입니다.', isError: false);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                _buildLoginButton(
                  title: "네이버로 계속하기",
                  color: const Color(0xFF03C75A),
                  textColor: Colors.white,
                  iconWidget: const Text("N", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  onTap: () {
                    _showSnackBar('업데이트 예정입니다.', isError: false);
                  },
                ),
                const SizedBox(height: 12),
                _buildLoginButton(
                  title: "이메일로 계속하기",
                  color: const Color(0xFF2C2C2E),
                  textColor: Colors.white,
                  iconWidget: const Icon(Icons.email_outlined, color: Colors.white, size: 24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EmailLoginScene()),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  ),
),
          ),
        ],
      ),
    );
  }
}
