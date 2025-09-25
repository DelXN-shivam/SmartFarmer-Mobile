import '../constants/app_constants.dart';
import '../models/crop.dart';
import 'dart:math';

class AIService {
  static final Random _random = Random();

  /// Generate AI insights based on crop data
  static List<String> generateInsights(Crop crop) {
    final insights = <String>[];

    // Crop age based insights
    insights.addAll(_getAgeBasedInsights(crop));

    // Weather and seasonal insights
    insights.addAll(_getSeasonalInsights(crop));

    // Random AI insights
    insights.add(_getRandomInsight());

    return insights.take(5).toList(); // Limit to 5 insights
  }

  /// Get insights based on crop age
  static List<String> _getAgeBasedInsights(Crop crop) {
    final insights = <String>[];
    final age = crop.cropAgeInDays;

    if (age < 15) {
      insights.add(
        'Crop is in germination stage. Ensure proper soil moisture.',
      );
      insights.add('Monitor for early pest infestation and disease symptoms.');
    } else if (age < 45) {
      insights.add('Vegetative growth phase. Apply nitrogen-rich fertilizers.');
      insights.add('Optimal time for weed control and irrigation management.');
    } else if (age < 90) {
      insights.add(
        'Flowering stage approaching. Monitor pollination conditions.',
      );
      insights.add('Consider micronutrient application for better yield.');
    } else if (age < 120) {
      insights.add('Fruiting stage. Protect crops from birds and pests.');
      insights.add('Reduce irrigation frequency to prevent lodging.');
    } else {
      insights.add(
        'Harvesting stage. Monitor weather for optimal harvest timing.',
      );
      insights.add('Prepare storage facilities and post-harvest management.');
    }

    return insights;
  }

  /// Get seasonal and weather based insights
  static List<String> _getSeasonalInsights(Crop crop) {
    final insights = <String>[];
    final month = DateTime.now().month;

    if (month >= 3 && month <= 5) {
      insights.add('Summer season. Increase irrigation frequency.');
      insights.add('Monitor for heat stress and pest outbreaks.');
    } else if (month >= 6 && month <= 9) {
      insights.add('Monsoon season. Ensure proper drainage.');
      insights.add('Monitor for fungal diseases due to high humidity.');
    } else if (month >= 10 && month <= 11) {
      insights.add('Post-monsoon season. Reduce irrigation gradually.');
      insights.add('Prepare for winter crop planning.');
    } else {
      insights.add('Winter season. Protect crops from cold stress.');
      insights.add('Monitor for frost damage in sensitive crops.');
    }

    return insights;
  }

  /// Get a random AI insight
  static String _getRandomInsight() {
    return AppConstants.aiInsights[_random.nextInt(
      AppConstants.aiInsights.length,
    )];
  }

  /// Predict crop yield based on current conditions
  static double predictYield(Crop crop) {
    final baseYield = crop.expectedYield;
    final age = crop.cropAgeInDays;
    final lifespan = 120; // Default value, since cropType is removed

    // Simple prediction model
    double multiplier = 1.0;

    // Age factor
    if (age < lifespan * 0.3) {
      multiplier *= 0.8; // Early stage
    } else if (age < lifespan * 0.7) {
      multiplier *= 1.0; // Mid stage
    } else {
      multiplier *= 1.2; // Late stage
    }

    // Random variation (±10%)
    final variation = 0.9 + (_random.nextDouble() * 0.2);
    multiplier *= variation;

    return (baseYield * multiplier).roundToDouble();
  }

  /// Get growth stage recommendations
  static Map<String, String> getGrowthRecommendations(Crop crop) {
    final recommendations = <String, String>{};
    final age = crop.cropAgeInDays;
    final lifespan = 120; // Default value, since cropType is removed

    if (age < lifespan * 0.1) {
      recommendations['stage'] = 'Germination';
      recommendations['action'] = 'Ensure proper soil moisture and temperature';
      recommendations['fertilizer'] = 'Apply starter fertilizer';
    } else if (age < lifespan * 0.3) {
      recommendations['stage'] = 'Vegetative';
      recommendations['action'] = 'Apply nitrogen-rich fertilizers';
      recommendations['fertilizer'] = 'Urea or NPK 20:20:20';
    } else if (age < lifespan * 0.6) {
      recommendations['stage'] = 'Flowering';
      recommendations['action'] =
          'Monitor pollination and apply micronutrients';
      recommendations['fertilizer'] = 'Micronutrient mix';
    } else if (age < lifespan * 0.8) {
      recommendations['stage'] = 'Fruiting';
      recommendations['action'] = 'Protect from pests and reduce irrigation';
      recommendations['fertilizer'] = 'Potassium-rich fertilizer';
    } else {
      recommendations['stage'] = 'Harvesting';
      recommendations['action'] = 'Prepare for harvest and storage';
      recommendations['fertilizer'] = 'No additional fertilizer needed';
    }

    return recommendations;
  }
}
