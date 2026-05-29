import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meogeoyori/Scene/SearchScene.dart';
import 'package:meogeoyori/Scene/TimerScene.dart';
import 'package:meogeoyori/Scene/ProfileSettingsScene.dart';
import 'package:meogeoyori/Scene/SignUpProfileScene.dart';
import 'package:meogeoyori/Scene/ResetPasswordScene.dart';

class ProfileScene extends StatefulWidget {
  const ProfileScene({super.key});

  @override
  State<ProfileScene> createState() => _ProfileSceneState();
}

class _ProfileSceneState extends State<ProfileScene> {
  bool _isLoadingProfile = false;
  Map<String, dynamic>? _userProfile;

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

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("로그인이 필요합니다.", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : _buildProfileView(),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildStatItem("0", "나의 레시피"),
                  Container(height: 40, width: 1, color: Colors.white.withOpacity(0.1)),
                  _buildStatItem("0", "팔로워"),
                  Container(height: 40, width: 1, color: Colors.white.withOpacity(0.1)),
                  _buildStatItem("0", "받은 하트"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}