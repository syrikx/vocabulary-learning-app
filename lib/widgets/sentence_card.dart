import 'package:flutter/material.dart';
import '../models/sentence_model.dart';

class SentenceCard extends StatelessWidget {
  final SentenceModel sentence;
  final VoidCallback? onBookmark;
  final VoidCallback? onPlayAudio;
  final bool isBookmarked;

  const SentenceCard({
    Key? key,
    required this.sentence,
    this.onBookmark,
    this.onPlayAudio,
    this.isBookmarked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote,
                  size: 20,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sentence.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onPlayAudio != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: onPlayAudio,
                    color: Colors.blue,
                    tooltip: '발음 듣기',
                  ),
                if (onBookmark != null)
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    onPressed: onBookmark,
                    color: isBookmarked ? Colors.amber : Colors.grey,
                    tooltip: isBookmarked ? '북마크 해제' : '북마크',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
