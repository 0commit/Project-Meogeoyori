import 'package:flutter/material.dart';

class CreatorProfileScene extends StatelessWidget {
  final String creatorName;

  const CreatorProfileScene({super.key, required this.creatorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(creatorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile Info
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1C1C1E),
              child: Icon(Icons.person, size: 40, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            Text(
              "@$creatorName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "맛있는 레시피를 공유합니다 🍳",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Follow Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "팔로우",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 32),
            
            // Videos Grid
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 9 / 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    color: const Color(0xFF1C1C1E),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white24, size: 32),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
