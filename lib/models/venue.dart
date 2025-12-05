import 'package:cloud_firestore/cloud_firestore.dart';

class Venue {
  final String id;
  final String name;
  final String location;
  final String category;
  final int capacity;
  final bool isAvailable;
  final List<String> facilities;


  Venue({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.capacity,
    required this.facilities,
    required this.isAvailable,
  });

  // Factory untuk convert dari Firestore Document ke Object Venue
  factory Venue.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Logic safety untuk facilities (String atau List)
    List<String> parsedFacilities = [];
    if (data['facilities'] is List) {
      parsedFacilities = List<String>.from(data['facilities']);
    } else if (data['facilities'] is String) {
      parsedFacilities = [data['facilities']];
    }

    return Venue(
      id: doc.id, // ID Dokumen
      name: data['name'] ?? 'No Name',
      location: data['location'] ?? '-',
      category: data['category'] ?? 'General',
      capacity: data['capacity'] ?? 0,
      facilities: parsedFacilities,
      isAvailable: data['isAvailable'] ?? false,

    );
  }
}