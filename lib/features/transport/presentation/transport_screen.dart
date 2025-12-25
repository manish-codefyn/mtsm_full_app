import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_card.dart';
import '../data/transport_repository.dart';
import '../data/models/route.dart';

final routeListProvider = FutureProvider<List<TransportRoute>>((ref) async {
  final repository = ref.watch(transportRepositoryProvider);
  return repository.getRoutes();
});

class TransportScreen extends ConsumerWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transport Routes'), centerTitle: true),
      body: routesAsync.when(
        data: (routes) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final route = routes[index];
            return AppCard(
              child: ListTile(
                leading: const Icon(Icons.directions_bus, color: Colors.amber),
                title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${route.startPoint} ➔ ${route.endPoint}'),
                trailing: Text('\$${route.fare}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
