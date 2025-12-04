import 'package:cloud_firestore/cloud_firestore.dart';

class VenueService {
  final CollectionReference _venuesRef = FirebaseFirestore.instance.collection('venues');

  // Stream untuk list venue
  Stream<QuerySnapshot> getVenues() {
    return _venuesRef.orderBy('name').snapshots();
  }

  // Add Venue dengan Custom ID
  Future<void> addVenue({
    required String id, // ID Manual dari user
    required String name,
    required String location,
    required String category,
    required int capacity,
    required List<String> facilities,
  }) async {
    // Gunakan .doc(id).set() untuk membuat dokumen dengan ID sendiri
    // Kalau pakai .add(), ID-nya acak.
    await _venuesRef.doc(id).set({
      'name': name,
      'location': location,
      'category': category,
      'capacity': capacity,
      'facilities': facilities,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteVenue(String id) async {
    await _venuesRef.doc(id).delete();
  }
}