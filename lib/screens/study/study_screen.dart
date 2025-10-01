import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
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
        title: const Text('학습 대시보드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<StatsProvider>().refreshStats();
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, StatsProvider>(
        builder: (context, authProvider, provider, child) {
          // 게스트 모드인 경우
          if (authProvider.isGuest) {
            return EmptyState(
              icon: Icons.login,
              title: '로그인이 필요합니다',
              subtitle: '학습 통계를 확인하려면 로그인하세요',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('로그인'),
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            );
          }

          if (provider.isLoading && provider.userStats == null) {
            return const LoadingIndicator(message: '통계를 불러오는 중...');
          }

          final stats = provider.userStats;

          if (stats == null) {
            return const EmptyState(
              icon: Icons.bar_chart,
              title: '통계를 불러올 수 없습니다',
              subtitle: '다시 시도해주세요',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<StatsProvider>().refreshStats();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(stats),
                  const SizedBox(height: 16),
                  _buildStreakCard(stats),
                  const SizedBox(height: 16),
                  _buildProgressCard(stats),
                  const SizedBox(height: 24),
                  const Text(
                    '최근 활동',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRecentActivity(stats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '단어장',
                  '${stats.totalVocabularies}',
                  Icons.book,
                  Colors.blue,
                ),
                _buildStatItem(
                  '총 단어',
                  '${stats.totalWords}',
                  Icons.abc,
                  Colors.green,
                ),
                _buildStatItem(
                  '학습 완료',
                  '${stats.learnedWords}',
                  Icons.check_circle,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildStreakCard(stats) {
    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 48,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '연속 학습 ${stats.currentStreak}일',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '최고 기록: ${stats.longestStreak}일',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '전체 학습 진행도',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.overallProgress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: stats.overallProgress / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '총 ${stats.totalStudyDays}일 학습',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(stats) {
    if (stats.recentActivity.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('최근 활동이 없습니다'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.recentActivity.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = stats.recentActivity[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text('${activity.wordsLearned}'),
            ),
            title: Text(activity.date),
            subtitle: Text('${activity.studyTimeMinutes}분 학습'),
            trailing: Icon(
              Icons.check_circle,
              color: Colors.green.shade400,
            ),
          );
        },
      ),
    );
  }
}
