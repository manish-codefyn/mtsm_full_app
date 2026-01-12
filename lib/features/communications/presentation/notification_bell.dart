import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the FutureProvider for data
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      data: (notifications) {
        final unreadCount = notifications.where((n) => n['is_read'] == false).length;
        
        return Stack(
          children: [
            IconButton(
              onPressed: () => _showNotifications(context, ref, notifications),
              icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 28),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const IconButton(onPressed: null, icon: Icon(Icons.notifications_outlined, color: Colors.grey)),
      error: (_, __) => const IconButton(onPressed: null, icon: Icon(Icons.notifications_off_outlined, color: Colors.grey)),
    );
  }

  void _showNotifications(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> notifications) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Notifications", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                       // Use Controller for ACTIONS
                       ref.read(notificationControllerProvider).markAllAsRead();
                    },
                    child: Text("Mark all read", style: GoogleFonts.outfit(color: Colors.blue)),
                  )
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                ? Center(child: Text("No notifications", style: GoogleFonts.outfit(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final isRead = item['is_read'] == true;
                      return ListTile(
                        onTap: () {
                           if (!isRead) {
                             // Use Controller for ACTIONS
                             ref.read(notificationControllerProvider).markAsRead(item['id'].toString());
                           }
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isRead ? Colors.grey.shade100 : Colors.blue.withOpacity(0.1),
                          child: Icon(Icons.info_outline, color: isRead ? Colors.grey : Colors.blue, size: 20),
                        ),
                        title: Text(
                          item['title'] ?? 'Notification', 
                          style: GoogleFonts.outfit(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            color: isRead ? Colors.grey.shade700 : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(DateTime.tryParse(item['created_at']) ?? DateTime.now()), 
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
