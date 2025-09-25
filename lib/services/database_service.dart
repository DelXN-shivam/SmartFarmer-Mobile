import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import '../constants/app_constants.dart';
import '../models/farmer.dart';
import '../models/crop.dart';
import '../models/verification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/api_constants.dart';

const String BASE_URL = DatabaseUrl.BASE_URL;

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE crops ADD COLUMN expected_first_harvest_date TEXT",
          );
          await db.execute(
            "ALTER TABLE crops ADD COLUMN expected_last_harvest_date TEXT",
          );
          await db.execute(
            "ALTER TABLE crops ADD COLUMN image_public_ids TEXT DEFAULT '[]'",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            "ALTER TABLE crops ADD COLUMN area_unit TEXT DEFAULT 'acre'",
          );
          await db.execute(
            "ALTER TABLE crops ADD COLUMN expected_yield_unit TEXT DEFAULT 'kg'",
          );
        }
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create farmers table
    await db.execute('''
      CREATE TABLE farmers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        aadhaar_number TEXT NOT NULL,
        village TEXT NOT NULL,
        landmark TEXT NOT NULL,
        taluka TEXT NOT NULL,
        district TEXT NOT NULL,
        pincode TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create crops table
    await db.execute('''
      CREATE TABLE crops (
        id TEXT PRIMARY KEY,
        farmer_id TEXT NOT NULL,
        crop_name TEXT NOT NULL,
        area REAL NOT NULL,
        area_unit TEXT DEFAULT 'acre',
        sowing_date TEXT NOT NULL,
        expected_harvest_date TEXT NOT NULL,
        expected_first_harvest_date TEXT,
        expected_last_harvest_date TEXT,
        expected_yield REAL NOT NULL,
        expected_yield_unit TEXT DEFAULT 'kg',
        previous_crop TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        image_paths TEXT NOT NULL,
        image_public_ids TEXT DEFAULT '[]',
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES farmers (id)
      )
    ''');

    // Create verifications table
    await db.execute('''
      CREATE TABLE verifications (
        id TEXT PRIMARY KEY,
        crop_id TEXT NOT NULL,
        farmer_id TEXT NOT NULL,
        verifier_id TEXT NOT NULL,
        status TEXT NOT NULL,
        comments TEXT NOT NULL,
        verification_images TEXT NOT NULL,
        verification_latitude REAL NOT NULL,
        verification_longitude REAL NOT NULL,
        verification_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (crop_id) REFERENCES crops (id),
        FOREIGN KEY (farmer_id) REFERENCES farmers (id)
      )
    ''');
  }

  // Farmer operations
  static Future<int> insertFarmer(Farmer farmer) async {
    try {
      developer.log(
        'DatabaseService.insertFarmer called',
        name: 'DatabaseService',
      );
      developer.log(
        'Inserting farmer with ID: ${farmer.id}',
        name: 'DatabaseService',
      );

      final db = await database;
      final farmerMap = farmer.toMap();
      developer.log(
        'Farmer data to insert: $farmerMap',
        name: 'DatabaseService',
      );

      final result = await db.insert('farmers', farmerMap);
      developer.log('Database insert result: $result', name: 'DatabaseService');

      if (result > 0) {
        developer.log(
          'Farmer successfully inserted with row ID: $result',
          name: 'DatabaseService',
        );
      } else {
        developer.log('Failed to insert farmer', name: 'DatabaseService');
      }

      return result;
    } catch (e) {
      developer.log('Error inserting farmer: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  static Future<Farmer?> getFarmerById(String id) async {
    try {
      developer.log(
        'DatabaseService.getFarmerById called with ID: $id',
        name: 'DatabaseService',
      );
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'farmers',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        final farmer = Farmer.fromMap(maps.first);
        developer.log(
          'Found farmer: ${farmer.name} (ID: ${farmer.id})',
          name: 'DatabaseService',
        );
        return farmer;
      } else {
        developer.log('No farmer found with ID: $id', name: 'DatabaseService');
        return null;
      }
    } catch (e) {
      developer.log('Error getting farmer by ID: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  static Future<Farmer?> fetchFarmerByIdFromApi(String farmerId) async {
    final url = '${BASE_URL}/api/farmer/$farmerId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['farmer'] != null) {
        // Map API fields to Farmer model fields
        final apiFarmer = data['farmer'];
        return Farmer(
          id: apiFarmer['_id'] ?? '',
          name: apiFarmer['name'] ?? '',
          contactNumber: apiFarmer['contact'] ?? '',
          aadhaarNumber: apiFarmer['aadhaarNumber'] ?? '',
          village: apiFarmer['village'] ?? '',
          landmark: apiFarmer['landMark'] ?? '',
          taluka: apiFarmer['taluka'] ?? '',
          district: apiFarmer['district'] ?? '',
          pincode: apiFarmer['pincode'] ?? '',
          createdAt:
              DateTime.tryParse(apiFarmer['createdAt'] ?? '') ?? DateTime.now(),
          updatedAt:
              DateTime.tryParse(apiFarmer['updatedAt'] ?? '') ?? DateTime.now(),
        );
      }
    }
    return null;
  }

  static Future<bool> updateFarmerInApi(Farmer farmer) async {
    final url = '$BASE_URL/api/farmer/update/${farmer.id}';
    final body = jsonEncode({
      'name': farmer.name,
      'contact': farmer.contactNumber,
      'aadhaarNumber': farmer.aadhaarNumber,
      'village': farmer.village,
      'landMark': farmer.landmark,
      'taluka': farmer.taluka,
      'district': farmer.district,
      'pincode': farmer.pincode,
    });
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'Error updating farmer in API: $e',
        name: 'DatabaseService',
      );
      return false;
    }
  }

  static Future<int> updateFarmer(Farmer farmer) async {
    final db = await database;
    return await db.update(
      'farmers',
      farmer.toMap(),
      where: 'id = ?',
      whereArgs: [farmer.id],
    );
  }

  static Future<int> deleteFarmer(String id) async {
    final db = await database;
    return await db.delete('farmers', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all farmers
  static Future<void> deleteAllFarmers() async {
    final db = await database;
    await db.delete('farmers');
  }

  // Crop operations
  static Future<int> insertCrop(Crop crop) async {
    final db = await database;
    return await db.insert('crops', crop.toMap());
  }

  static Future<List<Crop>> getAllCrops() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('crops');
    return List.generate(maps.length, (i) => Crop.fromMap(maps[i]));
  }

  static Future<List<Crop>> getCropsByFarmerId(String farmerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'crops',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
    );
    return List.generate(maps.length, (i) => Crop.fromMap(maps[i]));
  }

  static Future<Crop?> getCropById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'crops',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Crop.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Crop>> getCropsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'crops',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Crop.fromMap(maps[i]));
  }

  static Future<int> updateCrop(Crop crop) async {
    final db = await database;
    return await db.update(
      'crops',
      crop.toMap(),
      where: 'id = ?',
      whereArgs: [crop.id],
    );
  }

  static Future<int> deleteCrop(String id) async {
    final db = await database;
    return await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }

  // Verification operations
  static Future<int> insertVerification(Verification verification) async {
    final db = await database;
    return await db.insert('verifications', verification.toMap());
  }

  static Future<List<Verification>> getAllVerifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('verifications');
    return List.generate(maps.length, (i) => Verification.fromMap(maps[i]));
  }

  static Future<Verification?> getVerificationByCropId(String cropId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verifications',
      where: 'crop_id = ?',
      whereArgs: [cropId],
    );
    if (maps.isNotEmpty) {
      return Verification.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<Verification>> getVerificationsByStatus(
    String status,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'verifications',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Verification.fromMap(maps[i]));
  }

  static Future<int> updateVerification(Verification verification) async {
    final db = await database;
    return await db.update(
      'verifications',
      verification.toMap(),
      where: 'id = ?',
      whereArgs: [verification.id],
    );
  }

  // Statistics
  static Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final farmersCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM farmers'),
        ) ??
        0;

    final cropsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM crops'),
        ) ??
        0;

    final pendingVerifications =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM verifications WHERE status = ?',
            ['pending'],
          ),
        ) ??
        0;

    final verifiedCrops =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM verifications WHERE status = ?',
            ['verified'],
          ),
        ) ??
        0;

    return {
      'total_farmers': farmersCount,
      'total_crops': cropsCount,
      'pending_verifications': pendingVerifications,
      'verified_crops': verifiedCrops,
    };
  }
}
