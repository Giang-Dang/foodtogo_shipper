import 'dart:developer';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

class AcceptedOrderServices {
  static const kAcceptedOrderTbName = 'accepted_order';
  static Database? db;

  Future<bool> insert(int userId, int orderId) async {
    try {
      db ??= await _getDatabase();

      db!.insert(kAcceptedOrderTbName, {
        'userId': userId,
        'orderId': orderId,
      });
      return true;
    } catch (e) {
      log('AcceptedOrderServices.insert $e');
      return false;
    }
  }

  Future<bool> delete(int userId) async {
    try {
      db ??= await _getDatabase();

      int rowCount = await db!.delete(
        kAcceptedOrderTbName,
        where: 'userId = ?',
        whereArgs: [userId],
      );
      log('AcceptedOrderServices.delete affects $rowCount row(s).');
      return true;
    } catch (e) {
      log('AcceptedOrderServices.delete $e');
      return false;
    }
  }

  Future<int> getCurrentOrderId(int userId) async {
    db ??= await _getDatabase();
    final table = await db!.query(
      kAcceptedOrderTbName,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (table.isEmpty) {
      return 0;
    }

    final orderId = table[0]['orderId'] as int;
    return orderId;
  }

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, '$kAcceptedOrderTbName.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE $kAcceptedOrderTbName(userId INTEGER, orderId INTEGER, PRIMARY KEY(userId))');
      },
      version: 1,
    );
    return db;
  }

  closeDb() async {
    await db?.close();
  }
}
