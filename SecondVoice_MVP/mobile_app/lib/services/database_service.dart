import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/conversation_message.dart';

/// Service for local SQLite database management.
/// Handles persistence for conversations and their messages.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('second_voice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const nullableIntType = 'INTEGER';

    // Conversations table
    await db.execute('''
CREATE TABLE conversations (
  id $idType,
  title $textType,
  timestamp $intType,
  speaker_names_json $textType
)
''');

    // Messages table
    await db.execute('''
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  conversation_id $textType,
  speaker_id $textType,
  speaker_name $textType,
  text $textType,
  timestamp $intType,
  start_time_ms $nullableIntType,
  color_name $textType,
  FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE
)
''');
  }

  // ── Conversation Operations ────────────────────────────────────────

  Future<void> saveConversation({
    required String id,
    required String title,
    required DateTime timestamp,
    required Map<String, String> speakerNames,
    required List<ConversationMessage> messages,
  }) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Insert/Update conversation
      await txn.insert(
        'conversations',
        {
          'id': id,
          'title': title,
          'timestamp': timestamp.millisecondsSinceEpoch,
          'speaker_names_json': jsonEncode(speakerNames),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Delete old messages if overwriting
      await txn.delete(
        'messages',
        where: 'conversation_id = ?',
        whereArgs: [id],
      );

      // 3. Insert new messages
      for (final msg in messages) {
        await txn.insert('messages', {
          'conversation_id': id,
          'speaker_id': msg.speakerId,
          'speaker_name': msg.speakerName,
          'text': msg.text,
          'timestamp': msg.timestamp.millisecondsSinceEpoch,
          'start_time_ms': msg.startTime?.inMilliseconds,
          'color_name': msg.color.name,
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await instance.database;
    return await db.query('conversations', orderBy: 'timestamp DESC');
  }

  Future<List<ConversationMessage>> getMessages(String conversationId) async {
    final db = await instance.database;
    final maps = await db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'id ASC',
    );

    return maps.map((map) {
      return ConversationMessage(
        id: map['id'].toString(),
        speakerId: map['speaker_id'] as String,
        speakerName: map['speaker_name'] as String,
        text: map['text'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        startTime: map['start_time_ms'] != null 
            ? Duration(milliseconds: map['start_time_ms'] as int)
            : null,
        color: SpeakerColor.values.firstWhere(
          (e) => e.name == map['color_name'],
          orElse: () => SpeakerColor.neonBlue,
        ),
      );
    }).toList();
  }

  Future<void> deleteConversation(String id) async {
    final db = await instance.database;
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
