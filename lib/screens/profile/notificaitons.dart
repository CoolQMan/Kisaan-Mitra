import 'package:flutter/material.dart';

import '../../config/routes.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = false;
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _notifications = [
        NotificationItem(
          id: '1',
          title: 'Price Alert: Wheat',
          message: 'Wheat prices have increased by 5% in Punjab region',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: NotificationType.priceAlert,
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          title: 'Weather Alert',
          message:
              'Heavy rainfall expected in your region in the next 24 hours',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: NotificationType.weatherAlert,
          isRead: true,
        ),
        NotificationItem(
          id: '3',
          title: 'Irrigation Reminder',
          message:
              'It\'s time to irrigate your wheat field based on soil moisture levels',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: NotificationType.irrigationAlert,
          isRead: false,
        ),
        NotificationItem(
          id: '4',
          title: 'New Answer',
          message: 'Your question about pest control has received a new answer',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: NotificationType.questionAnswer,
          isRead: true,
        ),
        NotificationItem(
          id: '5',
          title: 'Crop Health Alert',
          message:
              'Possible disease detected in your rice crop. Check the analysis',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          type: NotificationType.cropHealthAlert,
          isRead: true,
        ),
      ];
      _isLoading = false;
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final index =
          _notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((notification) => notification.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.home, (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Notifications'),
          actions: [
            if (_notifications.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark all as read',
                onPressed: () {
                  setState(() {
                    _notifications = _notifications
                        .map((notification) =>
                            notification.copyWith(isRead: true))
                        .toList();
                  });
                },
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We\'ll notify you about important updates',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteNotification(notification.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification deleted'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: InkWell(
                            onTap: () {
                              if (!notification.isRead) {
                                _markAsRead(notification.id);
                              }
                              // Navigate to relevant screen based on notification type
                            },
                            child: Container(
                              color: notification.isRead
                                  ? null
                                  : Colors.blue.shade50,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildNotificationIcon(notification.type),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontWeight:
                                                      notification.isRead
                                                          ? FontWeight.normal
                                                          : FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              _formatTimestamp(
                                                  notification.timestamp),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.message,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        bottomNavigationBar: const CustomBottomNavBar(
          currentIndex: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.priceAlert:
        iconData = Icons.trending_up;
        iconColor = Colors.green;
        break;
      case NotificationType.weatherAlert:
        iconData = Icons.wb_cloudy;
        iconColor = Colors.blue;
        break;
      case NotificationType.irrigationAlert:
        iconData = Icons.water_drop;
        iconColor = Colors.lightBlue;
        break;
      case NotificationType.questionAnswer:
        iconData = Icons.question_answer;
        iconColor = Colors.orange;
        break;
      case NotificationType.cropHealthAlert:
        iconData = Icons.healing;
        iconColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum NotificationType {
  priceAlert,
  weatherAlert,
  irrigationAlert,
  questionAnswer,
  cropHealthAlert,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
