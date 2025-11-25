class Room {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final List<String> facilities;
  final bool isAvailable;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.facilities,
    required this.isAvailable,
  });

  factory Room.fromMap(String id, Map<String, dynamic> data) {
    return Room(
      id: id,
      name: data['name'],
      location: data['location'],
      capacity: data['capacity'],
      facilities: List<String>.from(data['facilities']),
      isAvailable: data['isAvailable'] ?? false,
    );
  }
}
