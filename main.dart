import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerState(),
      child: const CubeTimerApp(),
    ),
  );
}

class CubeTimerApp extends StatelessWidget {
  const CubeTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cube Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// 상태 관리 (타이머 및 기록 데이터)
class TimerState extends ChangeNotifier {
  List<double> solves = [];
  
  void addSolve(double time) {
    solves.insert(0, time);
    notifyListeners();
  }

  double? get bestTime => solves.isEmpty ? null : solves.reduce((a, b) => a < b ? a : b);
  
  double? get averageTime {
    if (solves.isEmpty) return null;
    return solves.reduce((a, b) => a + b) / solves.length;
  }
}

// 메인 5탭 내비게이션
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TimerScreen(),
    SolvesScreen(),
    StatsScreen(),
    SessionScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '솔브'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '스탯'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '세션'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: '모어'),
        ],
      ),
    );
  }
}

// 1. 타이머 화면
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Stopwatch _stopwatch = Stopwatch();
  bool _isHolding = false;

  void _handleTapDown(TapDownDetails details) {
    if (!_stopwatch.isRunning) {
      setState(() => _isHolding = true);
    } else {
      _stopwatch.stop();
      context.read<TimerState>().addSolve(_stopwatch.elapsedMilliseconds / 1000.0);
      setState(() {});
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isHolding) {
      _stopwatch.reset();
      _stopwatch.start();
      setState(() => _isHolding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = (_stopwatch.elapsedMilliseconds / 1000.0).toStringAsFixed(2);
    final color = _isHolding
        ? Colors.green
        : (_stopwatch.isRunning ? Colors.white : Colors.blueAccent);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "R2 U' B2 L2 F2 U' L2 U R2 D' F2", // 스크램블 예시
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 80),
            Text(
              displayTime,
              style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              _stopwatch.isRunning ? "터치하여 정지" : "화면을 누르고 있다가 떼면 시작",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. 솔브 (기록) 화면
class SolvesScreen extends StatelessWidget {
  const SolvesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final solves = context.watch<TimerState>().solves;

    return Scaffold(
      appBar: AppBar(title: const Text('솔브 기록')),
      body: solves.isEmpty
          ? const Center(child: Text('기록이 없습니다.'))
          : ListView.builder(
              itemCount: solves.length,
              itemBuilder: (context, index) {
                final time = solves[index];
                return ListTile(
                  leading: Text('#${solves.length - index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  title: Text('${time.toStringAsFixed(2)}s', style: const TextStyle(fontSize: 18)),
                );
              },
            ),
    );
  }
}

// 3. 스탯 화면
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TimerState>();

    return Scaffold(
      appBar: AppBar(title: const Text('통계')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('총 솔브 횟수', '${state.solves.length}회'),
            _buildStatCard('최고 기록', state.bestTime != null ? '${state.bestTime!.toStringAsFixed(2)}s' : '-'),
            _buildStatCard('평균 기록', state.averageTime != null ? '${state.averageTime!.toStringAsFixed(2)}s' : '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 4. 세션 화면
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('세션 관리')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.blueAccent),
            title: Text('기본 세션 (3x3)'),
            subtitle: Text('현재 활성화됨'),
          ),
          ListTile(
            leading: Icon(Icons.circle_outlined),
            title: Text('2x2 세션'),
          ),
          ListTile(
            leading: Icon(Icons.circle_outlined),
            title: Text('4x4 세션'),
          ),
        ],
      ),
    );
  }
}

// 5. 모어 화면 (프로필 & 설정)
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('더보기')),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('큐버 프로필'),
            subtitle: const Text('내 정보 및 목표 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('설정'),
            subtitle: const Text('타이머, 스크램블, 테마 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

// 모어 하위 - 프로필 화면
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: const Center(child: Text('프로필 페이지')),
    );
  }
}

// 모어 하위 - 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('인스펙션 타임 (15초)'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('사운드 효과'),
            value: false,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
