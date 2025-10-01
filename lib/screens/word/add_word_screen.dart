import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/word_provider.dart';
import '../../models/word_model.dart';

class AddWordScreen extends StatefulWidget {
  final int vocabularyId;

  const AddWordScreen({
    Key? key,
    required this.vocabularyId,
  }) : super(key: key);

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _notesController = TextEditingController();

  PartOfSpeech _selectedPartOfSpeech = PartOfSpeech.noun;
  WordDifficulty _selectedDifficulty = WordDifficulty.intermediate;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어 추가'),
      ),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _wordController,
                    decoration: const InputDecoration(
                      labelText: '영어 단어',
                      hintText: '예: ephemeral',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.abc),
                    ),
                    textCapitalization: TextCapitalization.none,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '단어를 입력해주세요';
                      }
                      if (!RegExp(r'^[a-zA-Z\s-]+$').hasMatch(value)) {
                        return '영문자만 입력 가능합니다';
                      }
                      if (value.length > 50) {
                        return '단어는 50자 이내로 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _meaningController,
                    decoration: const InputDecoration(
                      labelText: '뜻 (선택)',
                      hintText: '예: 일시적인, 덧없는',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.translate),
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PartOfSpeech>(
                    value: _selectedPartOfSpeech,
                    decoration: const InputDecoration(
                      labelText: '품사',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: PartOfSpeech.values.map((pos) {
                      return DropdownMenuItem(
                        value: pos,
                        child: Text(pos.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPartOfSpeech = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WordDifficulty>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: '난이도',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    items: WordDifficulty.values.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedDifficulty = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: '메모 (선택)',
                      hintText: '단어에 대한 메모를 입력하세요',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _addWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            '단어 추가',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addWord() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<WordProvider>();
    final word = await provider.addWord(
      widget.vocabularyId,
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim().isEmpty
          ? null
          : _meaningController.text.trim(),
      partOfSpeech: _selectedPartOfSpeech.apiValue,
      difficulty: _selectedDifficulty.apiValue,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (word != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어가 추가되었습니다')),
      );
      Navigator.pop(context);
    } else if (provider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
