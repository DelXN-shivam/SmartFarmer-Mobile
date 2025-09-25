import 'package:flutter/material.dart';
import '../constants/strings.dart';
import '../constants/app_constants.dart';
import '../models/crop.dart';
import '../services/shared_prefs_service.dart';
import 'dart:math';

class AIInsightsWidget extends StatelessWidget {
  final Crop crop;

  const AIInsightsWidget({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    final insights = _generateInsights();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  AppStrings.getString('ai_insights', langCode),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              title: AppStrings.getString('crop_age', langCode),
              value:
                  '${crop.cropAgeInDays} ${AppStrings.getString('days_old', langCode)}',
              icon: Icons.calendar_today,
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              title: AppStrings.getString('growth_stage', langCode),
              value: crop.growthStage,
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              title: 'Days to Harvest',
              value:
                  '${crop.daysToHarvest} ${AppStrings.getString('days_to_harvest', langCode)}',
              icon: Icons.agriculture,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('recommendations', langCode),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...insights.map((insight) => _buildRecommendation(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(recommendation, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  List<String> _generateInsights() {
    final insights = <String>[];
    final random = Random();

    // Add crop age based insights
    if (crop.cropAgeInDays < 30) {
      insights.add(
        'Crop is in early growth stage. Monitor soil moisture regularly.',
      );
    } else if (crop.cropAgeInDays < 60) {
      insights.add(
        'Optimal time for fertilizer application based on crop age.',
      );
    } else if (crop.cropAgeInDays < 90) {
      insights.add(
        'Consider pest control measures as crop enters flowering stage.',
      );
    } else {
      insights.add(
        'Prepare for harvesting activities. Monitor weather conditions.',
      );
    }

    return insights;
  }
}
