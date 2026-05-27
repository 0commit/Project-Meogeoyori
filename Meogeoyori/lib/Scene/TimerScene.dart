import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPreset {
  final String name;
  final int seconds;
  final IconData icon;

  TimerPreset(this.name, this.seconds, this.icon);

  Map<String, dynamic> toJson() => {
    'name': name,
    'seconds': seconds,
    'iconCode': icon.codePoint,
    'iconFamily': icon.fontFamily,
  };

  factory TimerPreset.fromJson(Map<String, dynamic> json) {
    return TimerPreset(
      json['name'],
      json['seconds'],
      IconData(json['iconCode'], fontFamily: json['iconFamily']),
    );
  }
}

class TimerScene extends StatefulWidget {
  const TimerScene({super.key});

  @override
  State<TimerScene> createState() => _TimerSceneState();
}

class _TimerSceneState extends State<TimerScene> {
  Timer? _timer;
  int _remainingSeconds = 0;
  String? _activeTimerName;
  int _totalSeconds = 0;
  
  Duration _selectedDuration = const Duration(minutes: 5);

  List<TimerPreset> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? presetsJson = prefs.getString('timer_presets');
    if (presetsJson != null) {
      final List<dynamic> decoded = json.decode(presetsJson);
      setState(() {
        _presets = decoded.map((item) => TimerPreset.fromJson(item)).toList();
      });
    } else {
      setState(() {
        _presets = [
          TimerPreset("계란 반숙", 7 * 60, Icons.egg_outlined),
          TimerPreset("계란 완숙", 10 * 60, Icons.egg),
          TimerPreset("파스타 면", 8 * 60, Icons.restaurant),
          TimerPreset("스테이크", 3 * 60, Icons.local_fire_department),
          TimerPreset("라면", 4 * 60 + 30, Icons.ramen_dining),
        ];
      });
      _savePresets();
    }
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_presets.map((p) => p.toJson()).toList());
    await prefs.setString('timer_presets', encoded);
  }

  void _startTimer(String name, int seconds) {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _activeTimerName = name;
      _totalSeconds = seconds;
      _remainingSeconds = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer!.cancel();
          _activeTimerName = null;
        }
      });
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _activeTimerName = null;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _showAddPresetBottomSheet() {
    String newName = "";
    IconData selectedIcon = Icons.timer;
    Duration newDuration = const Duration(minutes: 5);
    
    final List<Map<String, dynamic>> iconCategories = [
      {
        "title": "기본/단백질",
        "icons": [Icons.egg_outlined, Icons.set_meal, Icons.kebab_dining]
      },
      {
        "title": "탄수화물",
        "icons": [Icons.ramen_dining, Icons.rice_bowl, Icons.bakery_dining]
      },
      {
        "title": "도구/방식",
        "icons": [Icons.soup_kitchen, Icons.microwave, Icons.timer]
      }
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("새 타이머 등록", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const Divider(color: Colors.white10, height: 1),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            const Text("타이머 이름", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "예) 나만의 비법 소스 끓이기",
                                hintStyle: const TextStyle(color: Colors.white24),
                                filled: true,
                                fillColor: Colors.black26,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              onChanged: (val) => newName = val,
                            ),
                            const SizedBox(height: 24),
                            const Text("타이머 시간", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 120,
                              child: CupertinoTheme(
                                data: const CupertinoThemeData(
                                  textTheme: CupertinoTextThemeData(
                                    pickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                ),
                                child: CupertinoTimerPicker(
                                  mode: CupertinoTimerPickerMode.ms,
                                  initialTimerDuration: newDuration,
                                  onTimerDurationChanged: (Duration duration) {
                                    setModalState(() {
                                      newDuration = duration;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text("아이콘 선택", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 16),
                            ...iconCategories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(category["title"], style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: (category["icons"] as List<IconData>).map((icon) {
                                        bool isSelected = selectedIcon == icon;
                                        return GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedIcon = icon;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                              border: Border.all(
                                                color: isSelected ? Colors.orange : Colors.transparent,
                                                width: 2,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(icon, color: isSelected ? Colors.orange : Colors.white70, size: 32),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {
                            if (newName.trim().isEmpty) newName = "나만의 타이머";
                            setState(() {
                              _presets.insert(0, TimerPreset(newName, newDuration.inSeconds, selectedIcon));
                            });
                            _savePresets();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("새 타이머가 등록되었습니다!")));
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                "등록하기",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                  "스마트 타이머",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "진행 중인 요리 시간을 관리하세요",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text(
                  "진행 중인 타이머",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_activeTimerName != null)
                  _buildActiveTimer()
                else
                  _buildManualInputTimer(),
                
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "자주 쓰는 타이머",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showAddPresetBottomSheet,
                      child: const Icon(Icons.add_circle_outline, color: Colors.orangeAccent, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    itemBuilder: (context, index) {
                      final preset = _presets[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: GestureDetector(
                          onTap: () => _startTimer(preset.name, preset.seconds),
                          child: _buildPresetCard(preset),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualInputTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms,
                initialTimerDuration: _selectedDuration,
                onTimerDurationChanged: (Duration newDuration) {
                  setState(() {
                    _selectedDuration = newDuration;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              if (_selectedDuration.inSeconds > 0) {
                _startTimer("직접 설정 타이머", _selectedDuration.inSeconds);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                "시작",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimer() {
    double progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            _activeTimerName!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _cancelTimer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "타이머 취소",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard(TimerPreset preset) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(preset.icon, color: Colors.white70, size: 28),
          ),
          const Spacer(),
          Text(
            preset.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(preset.seconds),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }
}