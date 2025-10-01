import 'package:flutter/material.dart';
import '../models/vocabulary_model.dart';

class VocabularyCard extends StatelessWidget {
  final VocabularyModel vocabulary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const VocabularyCard({
    Key? key,
    required this.vocabulary,
    this.onTap,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[ Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocabulary.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (vocabulary.description != null &&
                            vocabulary.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              vocabulary.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('수정'),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('삭제'),
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(
                    Icons.book,
                    '${vocabulary.wordCount} 단어',
                    Colors.blue,
                  ),
                  _buildChip(
                    Icons.signal_cellular_alt,
                    VocabularyCategory.fromApiValue(vocabulary.category)
                        .displayName,
                    Colors.green,
                  ),
                  _buildChip(
                    Icons.trending_up,
                    TargetLevel.fromApiValue(vocabulary.targetLevel).displayName,
                    Colors.orange,
                  ),
                  if (vocabulary.isPublic)
                    _buildChip(
                      Icons.public,
                      '공개',
                      Colors.purple,
                    ),
                  if (vocabulary.downloadCount > 0)
                    _buildChip(
                      Icons.download,
                      '${vocabulary.downloadCount}',
                      Colors.grey,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
