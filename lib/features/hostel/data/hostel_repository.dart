import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import 'models/hostel_room.dart';

final hostelRepositoryProvider = Provider((ref) => HostelRepository(ref));

class HostelRepository {
  final Ref _ref;

  HostelRepository(this._ref);

  Future<List<HostelRoom>> getRooms() async {
    final dio = _ref.read(apiClientProvider).client;
    final response = await dio.get('hostel/rooms/'); // Adjust endpoint
    
    final data = response.data;
    final List<dynamic> results = (data is Map && data.containsKey('results')) 
        ? data['results'] 
        : (data is List ? data : []);

    return results.map((json) => HostelRoom.fromJson(json)).toList();
  }
}
