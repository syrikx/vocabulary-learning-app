import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stats_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<StatsProvider>().fetchUserStats();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: Consumer2<AuthProvider, StatsProvider>(
        builder: (context, authProvider, statsProvider, child) {
          final user = authProvider.user;
          final stats = statsProvider.userStats;
          final isGuest = authProvider.isGuest;

          return ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: isGuest
                          ? Icon(
                              Icons.person_outline,
                              size: 50,
                              color: Colors.blue.shade600,
                            )
                          : Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isGuest ? '게스트' : (user?.name ?? 'User'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isGuest)
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    if (isGuest) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade600,
                        ),
                        child: const Text('로그인'),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isGuest && stats != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '학습 요약',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickStat(
                                '단어장',
                                '${stats.totalVocabularies}',
                                Icons.book,
                              ),
                              _buildQuickStat(
                                '학습 완료',
                                '${stats.learnedWords}',
                                Icons.check_circle,
                              ),
                              _buildQuickStat(
                                '연속',
                                '${stats.currentStreak}일',
                                Icons.local_fire_department,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (!isGuest)
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: const Text('학습 통계'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // 학습 통계 화면으로 이동 (Study 탭)
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('설정'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('설정 화면은 준비 중입니다')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('도움말'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showHelpDialog(context);
                },
              ),
              const Divider(),
              if (!isGuest)
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => _confirmLogout(context),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('도움말'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '앱 사용 방법',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. 단어장 탭에서 새 단어장을 만듭니다'),
              Text('2. 단어장에 단어를 추가합니다'),
              Text('3. 단어를 클릭하여 예문을 학습합니다'),
              Text('4. 학습이 완료되면 체크박스를 선택합니다'),
              Text('5. 탐색 탭에서 다른 사용자의 단어장을 다운로드할 수 있습니다'),
              SizedBox(height: 16),
              Text(
                '문의사항',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('이메일: support@vocabulary-app.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
