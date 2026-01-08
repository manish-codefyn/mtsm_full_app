import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../data/communication_repository.dart';
import '../../../shared/widgets/dashboard_error_widget.dart';
import 'widgets/communication_stat_card.dart';
import 'widgets/message_thread_card.dart';

final communicationStatsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(communicationRepositoryProvider).getDashboardStats();
});

final threadsProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(communicationRepositoryProvider).getThreads();
});

final usersProvider = FutureProvider.autoDispose((ref) async {
  return ref.read(communicationRepositoryProvider).getUsers();
});

class CommunicationScreen extends ConsumerStatefulWidget {
  const CommunicationScreen({super.key});

  @override
  ConsumerState<CommunicationScreen> createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends ConsumerState<CommunicationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        ref.refresh(threadsProvider);
        ref.refresh(communicationStatsProvider);
        ref.refresh(notificationsProvider);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(communicationStatsProvider);
    final threadsAsync = ref.watch(threadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern Light Grey Background
      appBar: AppBar(
        title: Text(
          'Messages', 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 24,
          )
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {}, // Search Search Placeholder
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: () {
               ref.refresh(communicationStatsProvider);
               ref.refresh(threadsProvider);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeDialog(context, ref), 
        label: Text('New Message', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.edit_outlined),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 4,
      ),
      body: CustomScrollView(
        slivers: [
          // Stats Row
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (data) {
                 final statsList = data['stats'] as List<dynamic>? ?? [];
                 
                 String getValue(String label) {
                    try {
                      final item = statsList.firstWhere(
                        (e) => e['label'] == label, 
                        orElse: () => {'value': '0'}
                      );
                      return item['value'].toString();
                    } catch (e) {
                      return '0';
                    }
                 }

                 final sent = getValue('Sent Messages');
                 final failed = getValue('Failed');
                 final campaigns = getValue('Active Campaigns');

                 return Padding(
                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                   child: Row(
                     children: [
                       CommunicationStatCard(
                         label: 'Sent', 
                         value: sent, 
                         color: Colors.blue, 
                         icon: Icons.send_rounded
                       ),
                       const SizedBox(width: 12),
                       CommunicationStatCard(
                         label: 'Failed', 
                         value: failed, 
                         color: Colors.red, 
                         icon: Icons.error_outline_rounded
                       ),
                       const SizedBox(width: 12),
                       CommunicationStatCard(
                         label: 'Campaigns', 
                         value: campaigns, 
                         color: Colors.orange, 
                         icon: Icons.campaign_rounded
                       ),
                     ],
                   ),
                 );
              },
              loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
              error: (_,__) => const SizedBox(),
            ),
          ),
          
          // Header
          SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     "Recent Conversations", 
                     style: GoogleFonts.outfit(
                       fontSize: 18, 
                       fontWeight: FontWeight.bold,
                       color: Colors.black87
                     )
                   ),
                   Icon(Icons.filter_list, size: 20, color: Colors.grey.shade500),
                 ],
               ),
             ),
          ),

          // Message List
          threadsAsync.when(
            data: (threads) {
              if (threads.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text("No messages yet", style: GoogleFonts.outfit(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final thread = threads[index];
                    final subject = thread['title'] ?? 'No Subject';
                    final lastMsgObj = thread['last_message'];
                    final lastMsg = lastMsgObj != null ? (lastMsgObj['body'] ?? 'Attachment') : 'No messages yet';
                    
                    final participants = thread['participants_detail'] as List<dynamic>? ?? [];
                    final title = participants.isNotEmpty 
                        ? (participants[0]['full_name'] ?? 'Unknown') 
                        : 'Unknown';
                    
                    final bool hasUnread = thread['has_unread'] ?? false;
                    final String time = thread['last_message_at'] != null 
                        ? thread['last_message_at'].toString().split('T')[0] 
                        : 'Now';

                    return MessageThreadCard(
                      title: title,
                      subtitle: "$subject: $lastMsg",
                      time: time,
                      isUnread: hasUnread,
                      avatarLabel: title,
                      onTap: () {},
                    );
                  },
                  childCount: threads.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  void _showComposeDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String? selectedUserId; // Changed to String
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("New Message", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // User Dropdown
                Consumer(
                  builder: (context, ref, _) {
                    final usersAsync = ref.watch(usersProvider);
                    return usersAsync.when(
                      data: (users) {
                        // Filter out users without valid IDs or Names
                        final validUsers = users.where((u) => u['id'] != null).toList();
                        
                        // Using String because Backend uses UUID
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "To (Recipient)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: validUsers.map<DropdownMenuItem<String>>((user) {
                             final String id = user['id'].toString();
                             final String name = user['full_name'] ?? user['email'] ?? 'User';
                             
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) => selectedUserId = val,
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text("Error loading users: $err"),
                    );
                  }
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: titleController, 
                  decoration: InputDecoration(
                    labelText: "Subject",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  )
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: bodyController, 
                  decoration: InputDecoration(
                    labelText: "Message",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ), 
                  maxLines: 4
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: Text("Cancel", style: GoogleFonts.outfit(fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () async {
                         if (selectedUserId == null || titleController.text.isEmpty || bodyController.text.isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
                           return;
                         }

                         try {
                           Navigator.pop(context); 
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending...")));
                           
                           // Repository createThread now expects List<dynamic> or List<String>, let's update repo signature if needed
                           // But repo takes List<int> in previous step definition. Need to update repo too.
                           // Actually repo in dart is untyped dynamic in plain HTTP but I typed it as List<int>.
                           // I need to change repo to accept List<String>.
                           
                           await ref.read(communicationRepositoryProvider).createThread(
                             titleController.text,
                             [selectedUserId!],
                             bodyController.text
                           );
                           
                           ref.refresh(threadsProvider); 
                           if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message sent!")));
                           }
                         } catch (e) {
                           if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                           }
                         }
                      },
                      child: const Text("Send"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
