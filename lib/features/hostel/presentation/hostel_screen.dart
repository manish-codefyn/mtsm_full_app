import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_card.dart';
import '../data/hostel_repository.dart';
import '../data/models/hostel_room.dart';

final roomListProvider = FutureProvider<List<HostelRoom>>((ref) async {
  final repository = ref.watch(hostelRepositoryProvider);
  return repository.getRooms();
});

class HostelScreen extends ConsumerWidget {
  const HostelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hostel Rooms'), centerTitle: true),
      body: roomsAsync.when(
        data: (rooms) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final room = rooms[index];
            return AppCard(
              child: ListTile(
                leading: const Icon(Icons.bed, color: Colors.blueGrey),
                title: Text('${room.roomNumber} - ${room.hostelName}'),
                subtitle: LinearProgressIndicator(
                  value: room.capacity > 0 ? room.occupied / room.capacity : 0,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.blueGrey,
                ),
                trailing: Text('${room.occupied}/${room.capacity}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
