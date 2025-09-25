import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/strings.dart';
import '../models/crop.dart';
import '../services/shared_prefs_service.dart';
import '../constants/app_constants.dart';
import 'ai_insights_widget.dart';

class CropCardWidget extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;
  final bool showActions;
  final int index;

  const CropCardWidget({
    super.key,
    required this.crop,
    this.onTap,
    this.showActions = true,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final langCode = SharedPrefsService.getLanguage() ?? 'en';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: colorScheme.primary.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isDarkMode
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[900]!, Colors.grey[850]!],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey[50]!],
                      ),
              ),
              constraints: const BoxConstraints(minHeight: 140, maxHeight: 240),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row with Animated Crop Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(
                                    _getCropIcon(),
                                    color: _getStatusColor(),
                                    size: 22,
                                  )
                                  .animate(delay: (100 * index).ms)
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1, 1),
                                    curve: Curves.elasticOut,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crop.cropName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${AppStrings.getString('sowing_date', langCode)}: ${_formatDate(crop.sowingDate)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(langCode),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Animated Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),

                    // Crop Details with Staggered Animation
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.landscape,
                              '${AppStrings.getString('area', langCode)}:',
                              '${crop.area} acres',
                              context,
                            ).animate(delay: (150 + 50 * 0).ms).fadeIn(),
                            _buildInfoRow(
                              Icons.calendar_today,
                              '${AppStrings.getString('sowing_date', langCode)}:',
                              _formatDate(crop.sowingDate),
                              context,
                            ).animate(delay: (150 + 50 * 1).ms).fadeIn(),
                            _buildInfoRow(
                              Icons.timelapse,
                              '${AppStrings.getString('crop_age', langCode)}:',
                              '${crop.cropAgeInDays} ${AppStrings.getString('days_old', langCode)}',
                              context,
                            ).animate(delay: (150 + 50 * 2).ms).fadeIn(),
                            _buildInfoRow(
                              Icons.timeline,
                              '${AppStrings.getString('growth_stage', langCode)}:',
                              crop.growthStage,
                              context,
                            ).animate(delay: (150 + 50 * 3).ms).fadeIn(),
                            if (crop.daysToHarvest > 0)
                              _buildInfoRow(
                                Icons.agriculture,
                                'Days to Harvest:',
                                '${crop.daysToHarvest} ${AppStrings.getString('days_to_harvest', langCode)}',
                                context,
                              ).animate(delay: (150 + 50 * 4).ms).fadeIn(),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons with Colorful Themes
                    if (showActions) ...[
                      const SizedBox(height: 12),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      ).animate().fadeIn(),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildActionButton(
                                  icon: Icons.visibility_outlined,
                                  label: AppStrings.getString('view', langCode),
                                  onPressed: onTap,
                                  context: context,
                                  buttonType: 'view',
                                )
                                .animate(delay: 300.ms)
                                .slideX(
                                  begin: -0.5,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                ),
                            if (crop.status == AppConstants.statusPending)
                              _buildActionButton(
                                    icon: Icons.edit_outlined,
                                    label: AppStrings.getString(
                                      'edit',
                                      langCode,
                                    ),
                                    onPressed: () {
                                      // TODO: Navigate to edit crop form
                                    },
                                    context: context,
                                    buttonType: 'edit',
                                  )
                                  .animate(delay: 350.ms)
                                  .slideX(
                                    begin: -0.5,
                                    end: 0,
                                    curve: Curves.easeOutCubic,
                                  ),
                            _buildActionButton(
                                  icon: Icons.psychology_outlined,
                                  label: AppStrings.getString(
                                    'ai_insights',
                                    langCode,
                                  ),
                                  onPressed: () {
                                    _showAIInsights(context);
                                  },
                                  context: context,
                                  buttonType: 'insights',
                                )
                                .animate(delay: 400.ms)
                                .slideX(
                                  begin: -0.5,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                ),
                          ].animate(interval: 50.ms),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (50 * index).ms)
        .fadeIn()
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[100]!,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String langCode) {
    Color chipColor;
    String statusText;

    switch (crop.status) {
      case AppConstants.statusVerified:
        chipColor = Colors.green;
        statusText = AppStrings.getString('verified', langCode);
        break;
      case AppConstants.statusRejected:
        chipColor = Colors.red;
        statusText = AppStrings.getString('rejected', langCode);
        break;
      default:
        chipColor = Colors.orange;
        statusText = AppStrings.getString('pending', langCode);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [chipColor.withOpacity(0.1), chipColor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required BuildContext context,
    required String buttonType,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define colors for each button type
    late Color backgroundColor;
    late Color foregroundColor;
    late Color borderColor;

    switch (buttonType) {
      case 'view':
        backgroundColor = isDarkMode
            ? Colors.blue[900]!.withOpacity(0.3)
            : Colors.blue[50]!;
        foregroundColor = isDarkMode ? Colors.blue[200]! : Colors.blue[800]!;
        borderColor = isDarkMode
            ? Colors.blue[700]!.withOpacity(0.5)
            : Colors.blue[200]!;
        break;
      case 'edit':
        backgroundColor = isDarkMode
            ? Colors.orange[900]!.withOpacity(0.3)
            : Colors.orange[50]!;
        foregroundColor = isDarkMode
            ? Colors.orange[200]!
            : Colors.orange[800]!;
        borderColor = isDarkMode
            ? Colors.orange[700]!.withOpacity(0.5)
            : Colors.orange[200]!;
        break;
      case 'insights':
        backgroundColor = isDarkMode
            ? Colors.purple[900]!.withOpacity(0.3)
            : Colors.purple[50]!;
        foregroundColor = isDarkMode
            ? Colors.purple[200]!
            : Colors.purple[800]!;
        borderColor = isDarkMode
            ? Colors.purple[700]!.withOpacity(0.5)
            : Colors.purple[200]!;
        break;
      default:
        backgroundColor = isDarkMode ? Colors.grey[800]! : Colors.grey[50]!;
        foregroundColor = isDarkMode ? Colors.grey[200]! : Colors.grey[800]!;
        borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[200]!;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          animationDuration: const Duration(milliseconds: 200),
          enableFeedback: true,
        ),
      ),
    );
  }

  IconData _getCropIcon() {
    return Icons.agriculture;
  }

  Color _getStatusColor() {
    switch (crop.status) {
      case AppConstants.statusVerified:
        return Colors.green;
      case AppConstants.statusRejected:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAIInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AI Insights for ${crop.cropName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AIInsightsWidget(crop: crop),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
