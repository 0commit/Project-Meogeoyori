import 'package:flutter/material.dart';

class SearchScene extends StatefulWidget {
  const SearchScene({super.key});

  @override
  State<SearchScene> createState() => _SearchSceneState();
}

class _SearchSceneState extends State<SearchScene> {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'$query' 레시피를 검색 중입니다..."),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _onTagTapped(String tag) {
    String query = tag.startsWith('#') ? tag.substring(1) : tag;
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "무엇을 만들어 볼까요?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: _performSearch,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: '재료나 요리명을 검색해보세요 (예: 계란, 임...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Icon(Icons.filter_alt_outlined, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "퀵 필터",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickFilterChip("#5분컷"),
                      const SizedBox(width: 8),
                      _buildQuickFilterChip("#가성비"),
                      const SizedBox(width: 8),
                      _buildQuickFilterChip("#다이어트"),
                      const SizedBox(width: 8),
                      _buildQuickFilterChip("#자취생"),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "실시간 인기 검색어",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    final trendingList = [
                      "계란", "돼지고기",
                      "5분컷", "전자레인지",
                      "다이어트", "볶음밥"
                    ];
                    final rank = index + 1;
                    final isTop3 = rank <= 3;
                    return GestureDetector(
                      onTap: () => _onTagTapped(trendingList[index]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              "$rank",
                              style: TextStyle(
                                color: isTop3 ? Colors.redAccent : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              trendingList[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label) {
    return GestureDetector(
      onTap: () => _onTagTapped(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}