import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/vocabulary_model.dart';
import '../../widgets/vocabulary_card.dart';
import '../../widgets/loading_indicator.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLevel;
  String _sortBy = 'popular';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchVocabularies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchVocabularies() {
    context.read<VocabularyProvider>().searchPublicVocabularies(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          category: _selectedCategory,
          targetLevel: _selectedLevel,
          sort: _sortBy,
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어장 탐색'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '단어장 검색',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchVocabularies();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _searchVocabularies(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: Consumer<VocabularyProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.publicVocabularies.isEmpty) {
                  return const LoadingIndicator(message: '단어장을 검색하는 중...');
                }

                if (provider.publicVocabularies.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: '검색 결과가 없습니다',
                    subtitle: '다른 검색어로 시도해보세요',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _searchVocabularies();
                  },
                  child: ListView.builder(
                    itemCount: provider.publicVocabularies.length,
                    itemBuilder: (context, index) {
                      final vocabulary = provider.publicVocabularies[index];
                      return VocabularyCard(
                        vocabulary: vocabulary,
                        onTap: () => _showVocabularyDetail(context, vocabulary),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('정렬: '),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('인기순'),
            selected: _sortBy == 'popular',
            onSelected: (selected) {
              if (selected) {
                setState(() => _sortBy = 'popular');
                _searchVocabularies();
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('최신순'),
            selected: _sortBy == 'recent',
            onSelected: (selected) {
              if (selected) {
                setState(() => _sortBy = 'recent');
                _searchVocabularies();
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('단어 많은순'),
            selected: _sortBy == 'word_count',
            onSelected: (selected) {
              if (selected) {
                setState(() => _sortBy = 'word_count');
                _searchVocabularies();
              }
            },
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            child: Chip(
              label: Text(_selectedCategory != null
                  ? VocabularyCategory.fromApiValue(_selectedCategory!)
                      .displayName
                  : '카테고리'),
              avatar: const Icon(Icons.filter_list, size: 18),
            ),
            onSelected: (value) {
              setState(() {
                _selectedCategory = value == 'all' ? null : value;
              });
              _searchVocabularies();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('전체')),
              ...VocabularyCategory.values.map(
                (cat) => PopupMenuItem(
                  value: cat.apiValue,
                  child: Text(cat.displayName),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVocabularyDetail(BuildContext context, VocabularyModel vocabulary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocabulary.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (vocabulary.description != null)
                          Text(
                            vocabulary.description!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text('${vocabulary.wordCount} 단어'),
                              avatar: const Icon(Icons.book, size: 16),
                            ),
                            Chip(
                              label: Text(VocabularyCategory.fromApiValue(
                                      vocabulary.category)
                                  .displayName),
                              avatar: const Icon(Icons.category, size: 16),
                            ),
                            Chip(
                              label: Text(TargetLevel.fromApiValue(
                                      vocabulary.targetLevel)
                                  .displayName),
                              avatar: const Icon(Icons.trending_up, size: 16),
                            ),
                            Chip(
                              label: Text('${vocabulary.downloadCount} 다운로드'),
                              avatar: const Icon(Icons.download, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '제작자: ${vocabulary.username ?? '익명'}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('이 단어장 다운로드'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => _downloadVocabulary(context, vocabulary.id),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadVocabulary(BuildContext context, int vocabularyId) async {
    final authProvider = context.read<AuthProvider>();

    // 게스트 모드인 경우 로그인 요구
    if (authProvider.isGuest) {
      Navigator.pop(context); // 바텀시트 닫기
      _showLoginPrompt(context);
      return;
    }

    Navigator.pop(context); // 바텀시트 닫기

    final provider = context.read<VocabularyProvider>();
    final downloaded = await provider.downloadVocabulary(vocabularyId);

    if (downloaded != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('단어장이 다운로드되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인이 필요합니다'),
        content: const Text('단어장을 다운로드하려면 로그인이 필요합니다.\n로그인 화면으로 이동하시겠습니까?'),
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
}
