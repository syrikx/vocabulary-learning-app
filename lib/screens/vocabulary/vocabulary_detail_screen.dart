import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../providers/word_provider.dart';
import '../../models/vocabulary_model.dart';
import '../../widgets/word_card.dart';
import '../../widgets/progress_indicator_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../word/add_word_screen.dart';
import '../study/word_study_screen.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final int vocabularyId;

  const VocabularyDetailScreen({
    Key? key,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen> {
  String _learnedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordProvider>().fetchWords(widget.vocabularyId, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = context.watch<VocabularyProvider>();
    final vocabulary = vocabularyProvider.findById(widget.vocabularyId);

    return Scaffold(
      appBar: AppBar(
        title: Text(vocabulary?.title ?? '단어장'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WordProvider>().fetchWords(
                    widget.vocabularyId,
                    refresh: true,
                  );
            },
          ),
        ],
      ),
      body: Consumer<WordProvider>(
        builder: (context, wordProvider, child) {
          if (wordProvider.isLoading && wordProvider.getWords(widget.vocabularyId).isEmpty) {
            return const LoadingIndicator(message: '단어를 불러오는 중...');
          }

          final words = wordProvider.getWords(widget.vocabularyId);
          final stats = wordProvider.getStats(widget.vocabularyId);

          final filteredWords = _learnedFilter == 'all'
              ? words
              : words.where((w) => w.learned == (_learnedFilter == 'true')).toList();

          return Column(
            children: [
              if (stats != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProgressIndicatorWidget(
                    totalWords: stats['total_words'] ?? 0,
                    learnedWords: stats['learned_words'] ?? 0,
                    progressPercentage: stats['progress_percentage']?.toDouble() ?? 0.0,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('필터: '),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('전체'),
                      selected: _learnedFilter == 'all',
                      onSelected: (selected) {
                        if (selected) setState(() => _learnedFilter = 'all');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('학습중'),
                      selected: _learnedFilter == 'false',
                      onSelected: (selected) {
                        if (selected) setState(() => _learnedFilter = 'false');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('완료'),
                      selected: _learnedFilter == 'true',
                      onSelected: (selected) {
                        if (selected) setState(() => _learnedFilter = 'true');
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: filteredWords.isEmpty
                    ? EmptyState(
                        icon: Icons.abc,
                        title: '단어가 없습니다',
                        subtitle: '새로운 단어를 추가해보세요!',
                        action: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('단어 추가'),
                          onPressed: () => _navigateToAddWord(context),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<WordProvider>().fetchWords(
                                widget.vocabularyId,
                                refresh: true,
                              );
                        },
                        child: ListView.builder(
                          itemCount: filteredWords.length,
                          itemBuilder: (context, index) {
                            final word = filteredWords[index];
                            return WordCard(
                              word: word,
                              onTap: () => _navigateToWordStudy(context, word.id),
                              onLearnedToggle: (learned) {
                                context.read<WordProvider>().markAsLearned(
                                      widget.vocabularyId,
                                      word.id,
                                      learned,
                                    );
                              },
                              onDelete: () => _confirmDeleteWord(context, word.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddWord(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddWord(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWordScreen(vocabularyId: widget.vocabularyId),
      ),
    ).then((_) {
      context.read<WordProvider>().fetchWords(widget.vocabularyId, refresh: true);
    });
  }

  void _navigateToWordStudy(BuildContext context, int wordId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordStudyScreen(
          vocabularyId: widget.vocabularyId,
          wordId: wordId,
        ),
      ),
    );
  }

  void _confirmDeleteWord(BuildContext context, int wordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어 삭제'),
        content: const Text('이 단어를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<WordProvider>().deleteWord(
                    widget.vocabularyId,
                    wordId,
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('단어가 삭제되었습니다')),
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
