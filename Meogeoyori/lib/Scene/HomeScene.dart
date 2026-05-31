import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meogeoyori/Model/ShortsModel.dart';
import 'package:meogeoyori/Scene/CreatorProfileScene.dart';
import 'package:meogeoyori/Scene/HashtagResultScene.dart';
import 'package:meogeoyori/Widget/LoginModal.dart';
import 'package:meogeoyori/Model/CommentModel.dart';

class HomeScene extends StatefulWidget {
  const HomeScene({super.key});

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

class _HomeSceneState extends State<HomeScene> {
  final PageController _pageController = PageController();
  List<ShortsModel> _shortsList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final data = await Supabase.instance.client
          .from('shorts')
          .select()
          .order('created_at', ascending: true);
          
      final List<ShortsModel> fetchedList = (data as List)
          .map<ShortsModel>((e) => ShortsModel.fromJson(e as Map<String, dynamic>))
          .toList();
          
      if (mounted) {
        setState(() {
          _shortsList = fetchedList;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      print("Supabase Fetch Error: $e\n$stack");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("서버 에러:\n$_errorMessage", style: const TextStyle(color: Colors.redAccent)),
                ))
              : _shortsList.isEmpty 
                  ? const Center(child: Text("등록된 영상이 없습니다.", style: TextStyle(color: Colors.white)))
                  : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _shortsList.length,
                  itemBuilder: (context, index) {
                    final data = _shortsList[index];
                    return _ShortsItemWidget(data: data);
                  },
                ),
    );
  }
}

class _ShortsItemWidget extends StatefulWidget {
  final ShortsModel data;

  const _ShortsItemWidget({required this.data});

  @override
  State<_ShortsItemWidget> createState() => _ShortsItemWidgetState();
}

class _ShortsItemWidgetState extends State<_ShortsItemWidget> {
  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = int.tryParse(widget.data.likeCount) ?? 0;
    _commentCount = int.tryParse(widget.data.commentCount) ?? 0;
    _fetchVideoStats();
  }

  Future<void> _fetchVideoStats() async {
    if (widget.data.id.isEmpty) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      
      // Fetch comment count
      final commentRes = await Supabase.instance.client
          .from('comments')
          .select('id')
          .eq('short_id', widget.data.id);
      
      // Fetch like count
      final likeRes = await Supabase.instance.client
          .from('likes')
          .select('user_id')
          .eq('short_id', widget.data.id);
          
      bool isLiked = false;
      if (user != null) {
        isLiked = (likeRes as List).any((e) => e['user_id'] == user.id);
      }

      if (mounted) {
        setState(() { 
          _commentCount = (commentRes as List).length;
          _likeCount = (likeRes as List).length;
          _isLiked = isLiked;
        });
      }
    } catch (e) {
      print("Stat fetch error: $e");
    }
  }

  bool _checkLogin() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      showLoginModal(context);
      return false;
    }
    return true;
  }

  Future<void> _toggleLike() async {
    if (!_checkLogin()) return;
    if (widget.data.id.isEmpty) return;
    
    final user = Supabase.instance.client.auth.currentUser!;
    final previousLiked = _isLiked;
    
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _likeCount++ : _likeCount--;
    });
    
    try {
      if (_isLiked) {
        await Supabase.instance.client.from('likes').insert({
          'short_id': widget.data.id,
          'user_id': user.id,
        });
      } else {
        await Supabase.instance.client.from('likes').delete()
            .eq('short_id', widget.data.id)
            .eq('user_id', user.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = previousLiked;
          _isLiked ? _likeCount++ : _likeCount--;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _CommentSheetWidget(
          shortId: widget.data.id,
          onCommentAdded: () {
            if (mounted) {
              setState(() { _commentCount++; });
            }
          },
        );
      },
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildShareSheet();
      },
    );
  }

  void _showMoreBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _buildMoreSheet();
      },
    );
  }

  void _showRecipeDetailBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildRecipeDetailSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          // child: _VideoPlayerWidget(url: widget.data.videoUrl),
          child: Container(
            color: Colors.grey[900],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.white54, size: 50),
                  SizedBox(height: 8),
                  Text("데이터 절약을 위해\n비디오 임시 차단됨", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
        
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: _buildActionButton(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  _likeCount > 0 ? _likeCount.toString() : "0",
                  iconColor: _isLiked ? Colors.redAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showCommentBottomSheet,
                child: _buildActionButton(Icons.comment, _commentCount > 0 ? _commentCount.toString() : "0"),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showShareBottomSheet,
                child: _buildActionButton(Icons.share, "공유"),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showMoreBottomSheet,
                child: _buildActionButton(Icons.more_horiz, ""),
              ),
            ],
          ),
        ),

        Positioned(
          left: 16,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _showRecipeDetailBottomSheet,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, right: 20.0),
                  child: Text(
                    widget.data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => CreatorProfileScene(creatorName: widget.data.creatorName),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOutQuart;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "@${widget.data.creatorName}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.data.hashtags.map((tag) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => HashtagResultScene(hashtag: tag),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeOutQuart;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "#$tag",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, {Color iconColor = Colors.white}) {
    return Column(
      children: [
        ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3), 
                    Colors.white.withOpacity(0.05), 
                  ],
                ),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        ]
      ],
    );
  }

  // --- Bottom Sheets UI ---

  Widget _buildShareSheet() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("공유하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(Icons.link, "링크 복사", Colors.blue),
              _buildShareOption(Icons.chat_bubble, "카카오톡", Colors.yellow.shade700),
              _buildShareOption(Icons.camera_alt, "인스타그램", Colors.pinkAccent),
              _buildShareOption(Icons.more_horiz, "더보기", Colors.white54),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label 선택됨"), duration: const Duration(seconds: 1)));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMoreSheet() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          _buildMoreOption(Icons.bookmark_border, "영상 저장"),
          _buildMoreOption(Icons.visibility_off_outlined, "관심 없음"),
          _buildMoreOption(Icons.report_outlined, "신고하기", color: Colors.redAccent),
        ],
        ),
      ),
    );
  }

  Widget _buildMoreOption(IconData icon, String label, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label 처리되었습니다."), duration: const Duration(seconds: 1)));
      },
    );
  }

  Widget _buildRecipeDetailSheet() {
    List<Widget> ingredientWidgets = [];
    if (widget.data.ingredients.isNotEmpty) {
      for (var item in widget.data.ingredients) {
        if (item is Map) {
          ingredientWidgets.add(_buildIngredientRow(item['name']?.toString() ?? '', item['amount']?.toString() ?? ''));
        } else {
          ingredientWidgets.add(_buildIngredientRow(item.toString(), ""));
        }
      }
    } else {
      ingredientWidgets.add(const Text("등록된 재료 정보가 없습니다.", style: TextStyle(color: Colors.white70)));
    }

    List<Widget> stepWidgets = [];
    if (widget.data.recipeSteps.isNotEmpty) {
      for (int i = 0; i < widget.data.recipeSteps.length; i++) {
        var step = widget.data.recipeSteps[i];
        String desc = step is Map ? (step['desc']?.toString() ?? '') : step.toString();
        stepWidgets.add(_buildStepRow("${i+1}", desc));
      }
    } else {
      stepWidgets.add(const Text("등록된 레시피 정보가 없습니다.", style: TextStyle(color: Colors.white70)));
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("레시피 상세", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.data.title,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text("🛒 준비 재료", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...ingredientWidgets,
                  
                  const SizedBox(height: 32),
                  const Text("🍳 조리 순서", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...stepWidgets,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStepRow(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(step, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSheetWidget extends StatefulWidget {
  final String shortId;
  final VoidCallback onCommentAdded;
  const _CommentSheetWidget({required this.shortId, required this.onCommentAdded});
  @override
  State<_CommentSheetWidget> createState() => _CommentSheetWidgetState();
}

class _CommentSheetWidgetState extends State<_CommentSheetWidget> {
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    if (widget.shortId.isEmpty) {
      print("Error: shortId is empty");
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('영상 ID가 없어 댓글을 불러올 수 없습니다.')));
      }
      return;
    }
    try {
      // profiles 테이블의 컬럼이 name이 아니라 nickname 입니다. avatar_url은 없을 수도 있지만 일단 남겨둡니다.
      final data = await Supabase.instance.client
          .from('comments')
          .select('*, profiles(nickname)')
          .eq('short_id', widget.shortId)
          .order('created_at', ascending: false);
      final fetched = (data as List).map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) {
        setState(() {
          _comments = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Comment fetch error: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        // 에러 원인을 파악하기 위해 화면에 띄움
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('불러오기 에러: $e')));
      }
    }
  }

  Future<void> _postComment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Navigator.pop(context);
      showLoginModal(context);
      return;
    }
    final text = _commentController.text.trim();
    if (widget.shortId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('영상 ID가 누락되었습니다. DB에 id 컬럼이 있는지 확인하세요.')));
      return;
    }
    if (text.isEmpty) return;
    
    _commentController.clear();
    FocusScope.of(context).unfocus();
    
    try {
      // insert와 동시에 생성된 데이터(프로필 포함)를 반환받아 화면에 즉각 추가합니다.
      final insertedData = await Supabase.instance.client.from('comments').insert({
        'short_id': widget.shortId,
        'user_id': user.id,
        'content': text,
      }).select('*, profiles(nickname)').single();
      
      final newComment = CommentModel.fromJson(insertedData as Map<String, dynamic>);
      
      if (mounted) {
        setState(() {
          _comments.insert(0, newComment); // 리스트 맨 앞에 새 댓글 즉시 추가
        });
      }
      
      widget.onCommentAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 에러: $e')));
        // 실패 시 다시 전체 목록을 불러와 동기화
        _fetchComments();
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("댓글", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty 
                      ? const Center(child: Text("가장 먼저 댓글을 남겨보세요!", style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final c = _comments[index];
                            return _buildCommentRow(c.userName, c.content, c.profileImageUrl);
                          },
                        ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 16, right: 16, top: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2C2C2E),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "따뜻한 댓글을 남겨주세요...",
                        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1C1C1E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _postComment,
                    child: const Icon(Icons.send, color: Colors.orangeAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentRow(String name, String text, String avatarUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white24, 
            radius: 18, 
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const Icon(Icons.favorite_border, color: Colors.white54, size: 16),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.url.isEmpty) return;

    _controller = widget.url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(widget.url))
        : VideoPlayerController.asset(widget.url);
        
    _controller?.initialize().then((_) {
      if (mounted) setState(() {});
      _controller?.setVolume(0.0);
      _controller?.setLooping(true);
      _controller?.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return const Center(child: Text("영상을 등록해주세요", style: TextStyle(color: Colors.white54, fontSize: 16)));
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
  }
}