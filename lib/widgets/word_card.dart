import 'package:flutter/material.dart';
import '../models/word_model.dart';

class WordCard extends StatelessWidget {
  final WordModel word;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final Function(bool)? onLearnedToggle;

  const WordCard({
    Key? key,
    required this.word,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onLearnedToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: word.learned ? 1 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: word.learned ? Colors.green.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (onLearnedToggle != null)
                Checkbox(
                  value: word.learned,
                  onChanged: (value) {
                    if (value != null && onLearnedToggle != null) {
                      onLearnedToggle!(value);
                    }
                  },
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.word,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: word.learned
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        _buildDifficultyBadge(),
                      ],
                    ),
                    if (word.meaning != null && word.meaning!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          word.meaning!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            PartOfSpeech.fromApiValue(word.partOfSpeech)
                                .displayName,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (word.exampleCount > 0) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.format_quote, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            '${word.exampleCount}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
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
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge() {
    Color color;
    switch (word.difficulty) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        WordDifficulty.fromApiValue(word.difficulty).displayName,
        style: TextStyle(
          fontSize: 11,
          color: color.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
