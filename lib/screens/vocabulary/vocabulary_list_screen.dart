import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/vocabulary_card.dart';
import '../../widgets/loading_indicator.dart';
import 'create_vocabulary_screen.dart';
import 'vocabulary_detail_screen.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<VocabularyProvider>().fetchMyVocabularies(refresh: true);
      }
    });
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요합니다'),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.\n로그인 화면으로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 단어장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<VocabularyProvider>().fetchMyVocabularies(refresh: true);
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, VocabularyProvider>(
        builder: (context, authProvider, vocabProvider, child) {
          // 게스트 모드인 경우
          if (authProvider.isGuest) {
            return EmptyState(
              icon: Icons.login,
              title: '로그인이 필요합니다',
              subtitle: '내 단어장을 만들고 관리하려면 로그인하세요',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('로그인'),
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
            );
          }

          if (vocabProvider.isLoading && vocabProvider.vocabularies.isEmpty) {
            return const LoadingIndicator(message: '단어장을 불러오는 중...');
          }

          if (vocabProvider.vocabularies.isEmpty) {
            return EmptyState(
              icon: Icons.book,
              title: '단어장이 없습니다',
              subtitle: '새로운 단어장을 만들어보세요!',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('단어장 만들기'),
                onPressed: () => _navigateToCreateVocabulary(context),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<VocabularyProvider>().fetchMyVocabularies(refresh: true);
            },
            child: ListView.builder(
              itemCount: vocabProvider.vocabularies.length,
              itemBuilder: (context, index) {
                final vocabulary = vocabProvider.vocabularies[index];
                return VocabularyCard(
                  vocabulary: vocabulary,
                  onTap: () => _navigateToVocabularyDetail(context, vocabulary.id),
                  onDelete: () => _confirmDelete(context, vocabulary.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isGuest) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _navigateToCreateVocabulary(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _navigateToCreateVocabulary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateVocabularyScreen(),
      ),
    ).then((_) {
      // 생성 후 목록 새로고침
      context.read<VocabularyProvider>().fetchMyVocabularies(refresh: true);
    });
  }

  void _navigateToVocabularyDetail(BuildContext context, int vocabularyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyDetailScreen(vocabularyId: vocabularyId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int vocabularyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어장 삭제'),
        content: const Text('정말 이 단어장을 삭제하시겠습니까?\n모든 단어가 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<VocabularyProvider>().deleteVocabulary(vocabularyId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('단어장이 삭제되었습니다')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
