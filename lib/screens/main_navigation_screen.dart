import 'package:flutter/material.dart';
import 'vocabulary/vocabulary_list_screen.dart';
import 'explore/explore_screen.dart';
import 'study/study_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VocabularyListScreen(),
    ExploreScreen(),
    StudyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '단어장',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: '탐색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: '학습',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}
