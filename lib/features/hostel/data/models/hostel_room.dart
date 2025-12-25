class HostelRoom {
  final String id;
  final String roomNumber;
  final String hostelName;
  final int capacity;
  final int occupied;

  HostelRoom({
    required this.id,
    required this.roomNumber,
    required this.hostelName,
    required this.capacity,
    required this.occupied,
  });

  factory HostelRoom.fromJson(Map<String, dynamic> json) {
    return HostelRoom(
      id: json['id']?.toString() ?? '',
      roomNumber: json['room_number'] ?? '',
      hostelName: json['hostel']?['name'] ?? json['hostel_name'] ?? 'Main Hostel',
      capacity: json['capacity'] ?? 0,
      occupied: json['occupied'] ?? 0,
    );
  }
}
