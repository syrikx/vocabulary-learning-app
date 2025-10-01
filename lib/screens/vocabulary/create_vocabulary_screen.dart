import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vocabulary_provider.dart';
import '../../models/vocabulary_model.dart';

class CreateVocabularyScreen extends StatefulWidget {
  const CreateVocabularyScreen({Key? key}) : super(key: key);

  @override
  State<CreateVocabularyScreen> createState() => _CreateVocabularyScreenState();
}

class _CreateVocabularyScreenState extends State<CreateVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPublic = false;
  VocabularyCategory _selectedCategory = VocabularyCategory.general;
  TargetLevel _selectedLevel = TargetLevel.intermediate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 단어장 만들기'),
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      hintText: '예: TOEFL 필수 단어',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '제목을 입력해주세요';
                      }
                      if (value.length > 100) {
                        return '제목은 100자 이내로 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '설명 (선택)',
                      hintText: '단어장에 대한 설명을 입력하세요',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<VocabularyCategory>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: VocabularyCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TargetLevel>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: '난이도',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    items: TargetLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLevel = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('공개 단어장'),
                    subtitle: const Text('다른 사용자가 검색하고 다운로드할 수 있습니다'),
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() => _isPublic = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: provider.isLoading ? null : _createVocabulary,
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
                            '단어장 만들기',
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

  Future<void> _createVocabulary() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<VocabularyProvider>();
    final vocabulary = await provider.createVocabulary(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isPublic: _isPublic,
      category: _selectedCategory.apiValue,
      targetLevel: _selectedLevel.apiValue,
    );

    if (vocabulary != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어장이 생성되었습니다')),
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
