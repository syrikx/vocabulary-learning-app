import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/word_provider.dart';
import '../../services/sentence_service.dart';
import '../../services/api_auth_service.dart';
import '../../models/word_model.dart';
import '../../models/sentence_model.dart';
import '../../widgets/sentence_card.dart';
import '../../widgets/loading_indicator.dart';

class WordStudyScreen extends StatefulWidget {
  final int vocabularyId;
  final int wordId;

  const WordStudyScreen({
    Key? key,
    required this.vocabularyId,
    required this.wordId,
  }) : super(key: key);

  @override
  State<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends State<WordStudyScreen> {
  late SentenceService _sentenceService;
  List<SentenceModel> _sentences = [];
  bool _isLoading = false;
  bool _showMeaning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sentenceService = SentenceService(context.read<ApiAuthService>());
    _loadSentences();
  }

  Future<void> _loadSentences() async {
    final wordProvider = context.read<WordProvider>();
    final word = wordProvider.findWordById(widget.vocabularyId, widget.wordId);

    if (word == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _sentenceService.getSentences(
        word: word.word,
        years: 15, // 기본 연령대
        count: 5,
      );

      setState(() {
        _sentences = response.sentences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordProvider = context.watch<WordProvider>();
    final word = wordProvider.findWordById(widget.vocabularyId, widget.wordId);

    if (word == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('단어 학습')),
        body: const Center(child: Text('단어를 찾을 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(word.word),
        actions: [
          IconButton(
            icon: Icon(_showMeaning ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() => _showMeaning = !_showMeaning);
            },
            tooltip: _showMeaning ? '뜻 숨기기' : '뜻 보기',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWordCard(word),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: '예문을 불러오는 중...')
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSentences,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        ),
                      )
                    : _sentences.isEmpty
                        ? const Center(
                            child: Text('예문이 없습니다'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  '예문',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _sentences.length,
                                  itemBuilder: (context, index) {
                                    return SentenceCard(
                                      sentence: _sentences[index],
                                      isBookmarked:
                                          _sentences[index].isBookmarked,
                                      onBookmark: () =>
                                          _toggleBookmark(_sentences[index]),
                                      onPlayAudio: () =>
                                          _playAudio(_sentences[index].text),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
          _buildBottomButtons(word),
        ],
      ),
    );
  }

  Widget _buildWordCard(WordModel word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PartOfSpeech.fromApiValue(word.partOfSpeech).displayName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            firstChild: const Text(
              '뜻을 확인하려면 눈 아이콘을 클릭하세요',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            secondChild: Text(
              word.meaning ?? '뜻이 없습니다',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            crossFadeState: _showMeaning
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (word.notes != null && word.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '메모: ${word.notes}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons(WordModel word) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('나가기'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _markAsLearned(word),
              style: ElevatedButton.styleFrom(
                backgroundColor: word.learned ? Colors.grey : Colors.green,
              ),
              child: Text(word.learned ? '학습 완료됨' : '학습 완료'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(SentenceModel sentence) {
    // TODO: 북마크 기능 구현 (API 연동 필요)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sentence.isBookmarked ? '북마크가 해제되었습니다' : '북마크되었습니다',
        ),
      ),
    );
  }

  void _playAudio(String text) {
    // TODO: TTS 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TTS 기능은 준비 중입니다')),
    );
  }

  Future<void> _markAsLearned(WordModel word) async {
    final success = await context.read<WordProvider>().markAsLearned(
          widget.vocabularyId,
          widget.wordId,
          !word.learned,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(word.learned ? '학습 완료 취소되었습니다' : '학습 완료!'),
        ),
      );
    }
  }
}
