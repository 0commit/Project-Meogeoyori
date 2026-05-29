import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileSettingsScene extends StatefulWidget {
  const ProfileSettingsScene({Key? key}) : super(key: key);

  @override
  State<ProfileSettingsScene> createState() => _ProfileSettingsSceneState();
}

class _ProfileSettingsSceneState extends State<ProfileSettingsScene> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('로그아웃', style: TextStyle(color: Colors.white)),
        content: const Text('정말 로그아웃 하시겠습니까?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('Logout Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text('회원 탈퇴', style: TextStyle(color: Colors.redAccent)),
        content: const Text('정말 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.rpc('delete_user');
      await Supabase.instance.client.auth.signOut();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴 실패: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F13),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "설정",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              _buildSectionHeader("계정 관리"),
              _buildListTile(
                title: "로그아웃",
                textColor: Colors.redAccent,
                icon: Icons.logout,
                iconColor: Colors.redAccent,
                onTap: _handleLogout,
              ),
              _buildDivider(),
              _buildListTile(
                title: "회원 탈퇴",
                textColor: Colors.white54,
                icon: Icons.person_remove,
                iconColor: Colors.white54,
                onTap: _handleDeleteAccount,
              ),
              const SizedBox(height: 40),
              _buildSectionHeader("앱 정보"),
              _buildListTile(
                title: "버전 정보",
                textColor: Colors.white,
                trailing: const Text("1.0.0", style: TextStyle(color: Colors.white54)),
                onTap: () {},
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    Color textColor = Colors.white,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
      leading: icon != null ? Icon(icon, color: iconColor ?? Colors.white, size: 24) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white24, size: 24),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
    );
  }
}
