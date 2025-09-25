import 'package:flutter/material.dart';
import '../../constants/strings.dart';
import '../../services/shared_prefs_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late String langCode;
  bool _showUnreadOnly = false;
  NotificationFilter _currentFilter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    langCode = SharedPrefsService.getLanguage() ?? 'en';
  }

  // Define colors matching your profile screen
  final Color primaryColor = Colors.green;
  final Color primaryTextColor = Colors.green[900]!;
  final Color unreadBackgroundColor = Colors.green[50]!;
  final Color cardBorderColor = Colors.green[100]!;

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: '1',
      title: 'Weather Alert',
      message: 'Heavy rain expected tomorrow in your region',
      time: '2 hours ago',
      isRead: false,
      type: NotificationType.weather,
    ),
    NotificationItem(
      id: '2',
      title: 'Market Update',
      message: 'Wheat prices increased by 5% in local market',
      time: '5 hours ago',
      isRead: true,
      type: NotificationType.market,
    ),
    NotificationItem(
      id: '3',
      title: 'New Government Scheme',
      message: 'New fertilizer subsidy announced for your region',
      time: '1 day ago',
      isRead: false,
      type: NotificationType.government,
    ),
    NotificationItem(
      id: '4',
      title: 'Pest Alert',
      message: 'Locust sightings reported in nearby districts',
      time: '2 days ago',
      isRead: true,
      type: NotificationType.alert,
    ),
    NotificationItem(
      id: '5',
      title: 'Irrigation Reminder',
      message: 'Time to water your soybean crops in field B',
      time: '3 days ago',
      isRead: true,
      type: NotificationType.reminder,
    ),
    NotificationItem(
      id: '6',
      title: 'Payment Received',
      message: '₹15,200 received for your wheat harvest',
      time: '1 week ago',
      isRead: false,
      type: NotificationType.payment,
    ),
    NotificationItem(
      id: '7',
      title: 'Equipment Maintenance',
      message: 'Your tractor service is due next week',
      time: '1 week ago',
      isRead: true,
      type: NotificationType.equipment,
    ),
    NotificationItem(
      id: '8',
      title: 'New Farming Technique',
      message: 'Learn about vertical farming methods in your area',
      time: '2 weeks ago',
      isRead: true,
      type: NotificationType.education,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    return _allNotifications.where((notification) {
      final matchesFilter =
          _currentFilter == NotificationFilter.all ||
          notification.type.name == _currentFilter.name;
      final matchesUnreadFilter = !_showUnreadOnly || !notification.isRead;
      return matchesFilter && matchesUnreadFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getString('notifications', langCode)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.mark_as_unread),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chip Bar
          _buildFilterChips(),

          // Notifications List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshNotifications,
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        onPressed: _addSampleNotification,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: Text(AppStrings.getString('unread_only', langCode)),
            selected: _showUnreadOnly,
            onSelected: (selected) {
              setState(() => _showUnreadOnly = selected);
            },
            selectedColor: primaryColor.withOpacity(0.2),
            checkmarkColor: primaryColor,
          ),
          const SizedBox(width: 8),
          ...NotificationFilter.values.map((filter) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(_getFilterName(filter)),
                selected: _currentFilter == filter,
                onSelected: (selected) {
                  setState(() => _currentFilter = filter);
                },
                selectedColor: primaryColor.withOpacity(0.2),
                checkmarkColor: primaryColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final (icon, iconColor) = _getNotificationIconData(notification.type);

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red[100],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.getString('delete_notification', langCode)),
            content: Text(
              AppStrings.getString('delete_confirmation', langCode),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.getString('cancel', langCode)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppStrings.getString('delete', langCode),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        setState(() {
          _allNotifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.getString('notification_deleted', langCode),
              overflow: TextOverflow.ellipsis,
            ),
            action: SnackBarAction(
              label: AppStrings.getString('undo', langCode),
              textColor: Colors.white,
              onPressed: () {
                setState(() => _allNotifications.add(notification));
              },
            ),
          ),
        );
      },
      child: _buildNotificationItem(notification, icon, iconColor),
    );
  }

  Widget _buildNotificationItem(
    NotificationItem notification,
    IconData icon,
    Color iconColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      color: notification.isRead ? Colors.white : unreadBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardBorderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleNotificationTap(notification),
        onLongPress: () => _showNotificationOptions(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 16),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: primaryTextColor,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),

                    const SizedBox(height: 10),

                    // Time and Read Indicator
                    Row(
                      children: [
                        // Time
                        Text(
                          notification.time,
                          style: TextStyle(color: primaryColor, fontSize: 12),
                        ),

                        const Spacer(),

                        // Unread Indicator
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString('no_notifications', langCode),
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('no_notifications_desc', langCode),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getNotificationIconData(NotificationType type) {
    switch (type) {
      case NotificationType.weather:
        return (Icons.cloud, Colors.lightBlue[400]!);
      case NotificationType.market:
        return (Icons.attach_money, Colors.orange[400]!);
      case NotificationType.government:
        return (Icons.assignment, Colors.purple[400]!);
      case NotificationType.alert:
        return (Icons.warning, Colors.red[400]!);
      case NotificationType.reminder:
        return (Icons.notifications, Colors.blue[400]!);
      case NotificationType.payment:
        return (Icons.payment, Colors.green[600]!);
      case NotificationType.equipment:
        return (Icons.build, Colors.brown[400]!);
      case NotificationType.education:
        return (Icons.school, Colors.indigo[400]!);
      default:
        return (Icons.info, primaryColor);
    }
  }

  String _getFilterName(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return AppStrings.getString('all', langCode);
      case NotificationFilter.weather:
        return AppStrings.getString('weather', langCode);
      case NotificationFilter.market:
        return AppStrings.getString('market', langCode);
      case NotificationFilter.government:
        return AppStrings.getString('government', langCode);
      case NotificationFilter.alert:
        return AppStrings.getString('alerts', langCode);
      case NotificationFilter.payment:
        return AppStrings.getString('payments', langCode);
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.getString('filter_notifications', langCode),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(AppStrings.getString('unread_only', langCode)),
                value: _showUnreadOnly,
                onChanged: (value) {
                  setState(() => _showUnreadOnly = value);
                  Navigator.pop(context);
                },
                activeColor: primaryColor,
              ),
              const Divider(),
              ...NotificationFilter.values.map((filter) {
                return ListTile(
                  leading: Icon(_getFilterIcon(filter), color: primaryColor),
                  title: Text(_getFilterName(filter)),
                  trailing: _currentFilter == filter
                      ? Icon(Icons.check, color: primaryColor)
                      : null,
                  onTap: () {
                    setState(() => _currentFilter = filter);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  IconData _getFilterIcon(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        return Icons.filter_alt;
      case NotificationFilter.weather:
        return Icons.cloud;
      case NotificationFilter.market:
        return Icons.attach_money;
      case NotificationFilter.government:
        return Icons.assignment;
      case NotificationFilter.alert:
        return Icons.warning;
      case NotificationFilter.payment:
        return Icons.payment;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      setState(() => notification.isRead = true);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.weather:
        _showWeatherAlertDetails(notification);
        break;
      case NotificationType.market:
        _showMarketDetails(notification);
        break;
      // Add cases for other notification types
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '${notification.title} tapped',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
    }
  }

  void _showNotificationOptions(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.mark_as_unread, color: primaryColor),
                title: Text(
                  AppStrings.getString(
                    notification.isRead ? 'mark_as_unread' : 'mark_as_read',
                    langCode,
                  ),
                ),
                onTap: () {
                  setState(() => notification.isRead = !notification.isRead);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  AppStrings.getString('delete', langCode),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteNotification(notification);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteNotification(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('delete_notification', langCode)),
        content: Text(AppStrings.getString('delete_confirmation', langCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getString('cancel', langCode)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _allNotifications.remove(notification));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.getString('notification_deleted', langCode),
                    overflow: TextOverflow.ellipsis,
                  ),
                  action: SnackBarAction(
                    label: AppStrings.getString('undo', langCode),
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() => _allNotifications.add(notification));
                    },
                  ),
                ),
              );
            },
            child: Text(
              AppStrings.getString('delete', langCode),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.getString('all_marked_read', langCode),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  void _addSampleNotification() {
    final newNotification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Notification',
      message: 'This is a sample notification added for testing',
      time: 'Just now',
      isRead: false,
      type: NotificationType
          .values[DateTime.now().millisecond % NotificationType.values.length],
    );

    setState(() => _allNotifications.insert(0, newNotification));

    // Auto-scroll to top
    if (_filteredNotifications.isNotEmpty) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _showWeatherAlertDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            const Text('Recommended actions:'),
            const SizedBox(height: 8),
            const Text('• Cover sensitive crops'),
            const Text('• Check drainage systems'),
            const Text('• Postpone pesticide application'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getString('close', langCode)),
          ),
        ],
      ),
    );
  }

  void _showMarketDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            const Text('Current prices:'),
            const SizedBox(height: 8),
            const Text('• Wheat: ₹2,150 per quintal'),
            const Text('• Rice: ₹1,890 per quintal'),
            const Text('• Soybean: ₹3,240 per quintal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getString('close', langCode)),
          ),
        ],
      ),
    );
  }
}

enum NotificationType {
  weather,
  market,
  government,
  alert,
  reminder,
  payment,
  equipment,
  education,
}

enum NotificationFilter { all, weather, market, government, alert, payment }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
// enum NotificationType { weather, market, government, alert, reminder, other }
// import 'package:flutter/material.dart';
// import '../../constants/strings.dart';
// import '../../services/shared_prefs_service.dart';

// class NotificationScreen extends StatelessWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final langCode = SharedPrefsService.getLanguage() ?? 'en';

//     // Define colors matching your profile screen
//     final primaryColor = Colors.green;
//     final primaryTextColor = Colors.green[900];
//     final unreadBackgroundColor = Colors.green[50];
//     final cardBorderColor = Colors.green[100];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppStrings.getString('notifications', langCode)),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             onPressed: () => _showFilterOptions(context, langCode),
//           ),
//         ],
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         children: [
//           _buildNotificationCard(
//             context: context,
//             title: 'Weather Alert',
//             message: 'Heavy rain expected tomorrow in your region',
//             time: '2 hours ago',
//             isRead: false,
//             icon: Icons.cloud,
//             iconColor: Colors.lightBlue[400]!,
//             primaryColor: primaryColor,
//             primaryTextColor: primaryTextColor!,
//             unreadBackgroundColor: unreadBackgroundColor!,
//             cardBorderColor: cardBorderColor!,
//           ),
//           _buildNotificationCard(
//             context: context,
//             title: 'Market Update',
//             message: 'Wheat prices increased by 5% in local market',
//             time: '5 hours ago',
//             isRead: true,
//             icon: Icons.attach_money,
//             iconColor: Colors.orange[400]!,
//             primaryColor: primaryColor,
//             primaryTextColor: primaryTextColor,
//             unreadBackgroundColor: unreadBackgroundColor,
//             cardBorderColor: cardBorderColor,
//           ),
//           // Add more notification cards as needed
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationCard({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required String time,
//     required bool isRead,
//     required IconData icon,
//     required Color iconColor,
//     required Color primaryColor,
//     required Color primaryTextColor,
//     required Color unreadBackgroundColor,
//     required Color cardBorderColor,
//   }) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       elevation: 0,
//       color: isRead ? Colors.white : unreadBackgroundColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: cardBorderColor, width: 1),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () => _handleNotificationTap(context, title),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Notification Icon
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(icon, color: iconColor, size: 24),
//               ),

//               const SizedBox(width: 16),

//               // Notification Content
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontWeight: isRead
//                             ? FontWeight.normal
//                             : FontWeight.bold,
//                         color: primaryTextColor,
//                         fontSize: 16,
//                       ),
//                     ),

//                     const SizedBox(height: 6),

//                     // Message
//                     Text(
//                       message,
//                       style: TextStyle(color: Colors.grey[700], fontSize: 14),
//                     ),

//                     const SizedBox(height: 10),

//                     // Time and Read Indicator
//                     Row(
//                       children: [
//                         // Time
//                         Text(
//                           time,
//                           style: TextStyle(color: primaryColor, fontSize: 12),
//                         ),

//                         const Spacer(),

//                         // Unread Indicator
//                         if (!isRead)
//                           Container(
//                             width: 10,
//                             height: 10,
//                             decoration: BoxDecoration(
//                               color: primaryColor,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleNotificationTap(BuildContext context, String title) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Tapped on $title')));
//     // Add your navigation or other tap handling logic here
//   }

//   void _showFilterOptions(BuildContext context, String langCode) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 AppStrings.getString('filter_notifications', langCode),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add your filter options here
//               ListTile(
//                 leading: const Icon(Icons.filter_alt),
//                 title: Text(
//                   AppStrings.getString('all_notifications', langCode),
//                 ),
//                 onTap: () => Navigator.pop(context),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.cloud),
//                 title: Text(AppStrings.getString('weather_alerts', langCode)),
//                 onTap: () => Navigator.pop(context),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.attach_money),
//                 title: Text(AppStrings.getString('market_updates', langCode)),
//                 onTap: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
