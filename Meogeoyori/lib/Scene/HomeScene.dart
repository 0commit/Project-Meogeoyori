import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meogeoyori/Model/ShortsModel.dart';
import 'package:meogeoyori/Scene/CreatorProfileScene.dart';
import 'package:meogeoyori/Scene/HashtagResultScene.dart';

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

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _showCommentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _buildCommentSheet();
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
                  widget.data.likeCount,
                  iconColor: _isLiked ? Colors.redAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _showCommentBottomSheet,
                child: _buildActionButton(Icons.comment, widget.data.commentCount),
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

  Widget _buildCommentSheet() {
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDummyComment("요리초보", "진짜 5분만에 완성되나요? 퇴근하고 해봐야겠어요!"),
                _buildDummyComment("자취마스터", "계란 대신 두부 넣어도 맛있습니다 강추👍"),
                _buildDummyComment("다이어터", "소스 비율 조금 줄이면 다이어트 식단으로도 좋겠네요."),
              ],
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
                const Icon(Icons.send, color: Colors.orangeAccent),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDummyComment(String name, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: Colors.white24, radius: 18, child: const Icon(Icons.person, color: Colors.white, size: 20)),
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
                  _buildIngredientRow("계란", "2개"),
                  _buildIngredientRow("대파", "1/2대"),
                  _buildIngredientRow("간장", "1 큰술"),
                  _buildIngredientRow("참기름", "1 큰술"),
                  _buildIngredientRow("통깨", "약간"),
                  
                  const SizedBox(height: 32),
                  const Text("🍳 조리 순서", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStepRow("1", "대파를 송송 썰어 준비합니다. 너무 두껍지 않게 써는 것이 포인트입니다."),
                  _buildStepRow("2", "기름을 두른 팬에 대파를 넣고 약불에서 파기름을 냅니다."),
                  _buildStepRow("3", "파 향이 올라오면 계란을 넣고 빠르게 스크램블 해줍니다."),
                  _buildStepRow("4", "밥을 넣고 간장, 참기름으로 간을 한 뒤 통깨를 뿌려 마무리합니다."),
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