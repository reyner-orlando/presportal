import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart'; // Pastikan import file model Venue kamu
class VenueService {
  final CollectionReference _venuesRef = FirebaseFirestore.instance.collection('venues');

  // Stream untuk list venue
  Stream<List<Venue>> getVenues() {
    return _venuesRef.snapshots().map((querySnapshot) {
      // 1. Ambil list dokumen (querySnapshot.docs)
      // 2. Lakukan looping (.map)
      // 3. Ubah setiap dokumen menjadi object Venue menggunakan factory kamu
      return querySnapshot.docs.map((doc) {
        return Venue.fromFirestore(doc); // <--- INI KUNCINYA
      }).toList();
    });
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

  Future<void> updateVenue({
    required String id,
    required String name,
    required String location,
    required String category,
    required int capacity,
    required List<String> facilities,
  }) async {
    await _venuesRef.doc(id).update({
      'name': name,
      'location': location,
      'category': category,
      'capacity': capacity,
      'facilities': facilities,
      'updatedAt': FieldValue.serverTimestamp(), // Opsional
    });
  }

}