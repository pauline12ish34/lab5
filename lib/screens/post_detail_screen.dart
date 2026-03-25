import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import 'add_edit_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Post _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  // Refresh post data from database
  Future<void> _refreshPost() async {
    try {
      final updated = await _dbHelper.getPostById(_currentPost.id!);
      if (updated != null && mounted) {
        setState(() {
          _currentPost = updated;
        });
      }
    } catch (e) {
      // If fetch fails, keep showing current data
      print('Error refreshing post: $e');
    }
  }

  // Navigate to Edit screen
  Future<void> _editPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPostScreen(post: _currentPost),
      ),
    );
    if (result == true) {
      await _refreshPost();
      widget.onEdit();
    }
  }

  // Delete post with confirmation
  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content:
            Text('Are you sure you want to delete "${_currentPost.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deletePost(_currentPost.id!);
        widget.onDelete();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${_currentPost.title}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting post: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        actions: [
          // Edit button in app bar
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPost,
            tooltip: 'Edit Post',
          ),
          // Delete button in app bar
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePost,
            tooltip: 'Delete Post',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _currentPost.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Author and Date info card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Author
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _currentPost.author,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // Date
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _currentPost.createdAt,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content label
            Text(
              'Content',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Content body
            Text(
              _currentPost.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons at the bottom
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editPost,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Post'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deletePost,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
