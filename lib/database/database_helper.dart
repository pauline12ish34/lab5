import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post.dart';

class DatabaseHelper {
  // Singleton pattern - ensures only one instance of DatabaseHelper exists
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter for the database, initializes it if not yet created
  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('posts.db');
      return _database!;
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  // Initialize the database file and create the table
  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onOpen: (db) {
          print('Database opened successfully at: $path');
        },
      );
    } catch (e) {
      throw Exception('Error opening database: $e');
    }
  }

  // Create the posts table
  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE posts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          author TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      print('Posts table created successfully');
    } catch (e) {
      throw Exception('Error creating posts table: $e');
    }
  }

  // ===================== CREATE =====================
  // Insert a new post into the database
  Future<int> createPost(Post post) async {
    try {
      // Validate data before inserting
      if (post.title.isEmpty || post.content.isEmpty || post.author.isEmpty) {
        throw Exception('Invalid data: title, content, and author cannot be empty');
      }

      final db = await database;
      final id = await db.insert(
        'posts',
        post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Post inserted with id: $id');
      return id;
    } catch (e) {
      print('Error inserting post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  // ===================== READ (All) =====================
  // Retrieve all posts from the database
  Future<List<Post>> getAllPosts() async {
    try {
      final db = await database;
      final result = await db.query(
        'posts',
        orderBy: 'createdAt DESC', // Most recent posts first
      );

      return result.map((map) {
        try {
          return Post.fromMap(map);
        } catch (e) {
          print('Warning: Skipping corrupted record: $map - Error: $e');
          return null;
        }
      }).whereType<Post>().toList(); // Filter out null entries from corrupted data
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  // ===================== READ (Single) =====================
  // Retrieve a single post by its ID
  Future<Post?> getPostById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return Post.fromMap(result.first);
      }
      return null; // Post not found
    } catch (e) {
      print('Error fetching post with id $id: $e');
      throw Exception('Failed to fetch post: $e');
    }
  }

  // ===================== UPDATE =====================
  // Update an existing post in the database
  Future<int> updatePost(Post post) async {
    try {
      // Validate data before updating
      if (post.id == null) {
        throw Exception('Cannot update post without an id');
      }
      if (post.title.isEmpty || post.content.isEmpty || post.author.isEmpty) {
        throw Exception('Invalid data: title, content, and author cannot be empty');
      }

      final db = await database;
      final rowsAffected = await db.update(
        'posts',
        post.toMap(),
        where: 'id = ?',
        whereArgs: [post.id],
      );

      if (rowsAffected == 0) {
        throw Exception('No post found with id ${post.id} to update');
      }

      print('Post updated: ${post.id}, rows affected: $rowsAffected');
      return rowsAffected;
    } catch (e) {
      print('Error updating post: $e');
      throw Exception('Failed to update post: $e');
    }
  }

  // ===================== DELETE =====================
  // Delete a post from the database by its ID
  Future<int> deletePost(int id) async {
    try {
      final db = await database;
      final rowsDeleted = await db.delete(
        'posts',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted == 0) {
        throw Exception('No post found with id $id to delete');
      }

      print('Post deleted: id $id, rows deleted: $rowsDeleted');
      return rowsDeleted;
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }

  // ===================== SEARCH =====================
  // Search posts by title or content
  Future<List<Post>> searchPosts(String query) async {
    try {
      final db = await database;
      final result = await db.query(
        'posts',
        where: 'title LIKE ? OR content LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );

      return result.map((map) => Post.fromMap(map)).toList();
    } catch (e) {
      print('Error searching posts: $e');
      throw Exception('Failed to search posts: $e');
    }
  }

  // ===================== COUNT =====================
  // Get the total number of posts
  Future<int> getPostCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM posts');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error counting posts: $e');
      return 0;
    }
  }

  // ===================== CLOSE =====================
  // Close the database connection
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _database = null;
      print('Database closed successfully');
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}
