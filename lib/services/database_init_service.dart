import '../models/farmer.dart';
import '../models/crop.dart';
import 'database_service.dart';

class DatabaseInitService {
  static Future<void> initializeSampleData() async {
    try {
      // Add sample crops
      final sampleCrops = [
        Crop(
          id: 'crop_001',
          farmerId: 'farmer_001',
          cropName: 'Wheat',
          area: 5.5,
          sowingDate: DateTime.now().subtract(const Duration(days: 30)),
          expectedHarvestDate: DateTime.now().add(const Duration(days: 120)),
          expectedYield: 22.0,
          previousCrop: 'Rice',
          latitude: 19.0760,
          longitude: 72.8777,
          imagePaths: ['sample_wheat_1.jpg', 'sample_wheat_2.jpg'],
          imagePublicIds: [],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expectedFirstHarvestDate: DateTime.now(),
          expectedLastHarvestDate: DateTime.now(),
        ),
        Crop(
          id: 'crop_002',
          farmerId: 'farmer_002',
          cropName: 'Cotton',
          area: 3.2,
          sowingDate: DateTime.now().subtract(const Duration(days: 45)),
          expectedHarvestDate: DateTime.now().add(const Duration(days: 90)),
          expectedYield: 12.8,
          previousCrop: 'Soybean',
          latitude: 18.5204,
          longitude: 73.8567,
          imagePaths: ['sample_cotton_1.jpg'],
          imagePublicIds: [],
          status: 'verified',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expectedFirstHarvestDate: DateTime.now(),
          expectedLastHarvestDate: DateTime.now(),
        ),
        Crop(
          id: 'crop_003',
          farmerId: 'farmer_003',
          cropName: 'Sugarcane',
          area: 7.0,
          sowingDate: DateTime.now().subtract(const Duration(days: 60)),
          expectedHarvestDate: DateTime.now().add(const Duration(days: 300)),
          expectedYield: 350.0,
          previousCrop: 'Wheat',
          latitude: 21.1458,
          longitude: 79.0882,
          imagePaths: ['sample_sugarcane_1.jpg', 'sample_sugarcane_2.jpg'],
          imagePublicIds: [],
          status: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          expectedFirstHarvestDate: DateTime.now(),
          expectedLastHarvestDate: DateTime.now(),
        ),
      ];

      for (final crop in sampleCrops) {
        await DatabaseService.insertCrop(crop);
      }

      print('Sample data initialized successfully');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }
}
