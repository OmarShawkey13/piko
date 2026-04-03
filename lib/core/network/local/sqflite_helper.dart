import 'package:piko/core/models/chat_model.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqfliteHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final String path = join(await getDatabasesPath(), 'piko_chat.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            senderId TEXT,
            receiverId TEXT,
            text TEXT,
            imageUrl TEXT,
            timestamp INTEGER,
            seen INTEGER,
            fileSize TEXT,
            replyToId TEXT,
            replyText TEXT,
            replySenderName TEXT,
            localPath TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE chats (
            uid TEXT PRIMARY KEY,
            displayName TEXT,
            username TEXT,
            photoUrl TEXT,
            lastMessage TEXT,
            timestamp INTEGER,
            unreadCount INTEGER,
            draft TEXT,
            imageUrl TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertMessage(MessageModel msg) async {
    final dbClient = await db;
    await dbClient.insert(
      'messages',
      {
        'id': msg.id,
        'senderId': msg.senderId,
        'receiverId': msg.receiverId,
        'text': msg.text,
        'imageUrl': msg.imageUrl,
        'timestamp': msg.timestamp,
        'seen': msg.seen ? 1 : 0,
        'fileSize': msg.fileSize,
        'replyToId': msg.replyToId,
        'replyText': msg.replyText,
        'replySenderName': msg.replySenderName,
        'localPath': msg.localPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<MessageModel>> getMessages(
    String myId,
    String otherId,
  ) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'messages',
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [myId, otherId, otherId, myId],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return MessageModel(
        id: maps[i]['id'],
        senderId: maps[i]['senderId'],
        receiverId: maps[i]['receiverId'],
        text: maps[i]['text'],
        imageUrl: maps[i]['imageUrl'],
        timestamp: maps[i]['timestamp'],
        seen: maps[i]['seen'] == 1,
        fileSize: maps[i]['fileSize'],
        replyToId: maps[i]['replyToId'],
        replyText: maps[i]['replyText'],
        replySenderName: maps[i]['replySenderName'],
        localPath: maps[i]['localPath'],
      );
    });
  }

  static Future<void> insertChat(ChatModel chat) async {
    final dbClient = await db;
    await dbClient.insert(
      'chats',
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<ChatModel>> getChats() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'chats',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatModel(
        uid: maps[i]['uid'],
        displayName: maps[i]['displayName'],
        username: maps[i]['username'],
        photoUrl: maps[i]['photoUrl'],
        lastMessage: maps[i]['lastMessage'],
        timestamp: maps[i]['timestamp'],
        unreadCount: maps[i]['unreadCount'] ?? 0,
        draft: maps[i]['draft'] ?? "",
        imageUrl: maps[i]['imageUrl'],
      );
    });
  }

  static Future<void> clearChat(String myId, String otherId) async {
    final dbClient = await db;
    await dbClient.delete(
      'messages',
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [myId, otherId, otherId, myId],
    );
  }
}
