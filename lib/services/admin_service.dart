import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final CollectionReference _bookingsRef = FirebaseFirestore.instance.collection('bookings');

  Stream<QuerySnapshot> getPendingBookings() {
    return _bookingsRef
        .where('status', isEqualTo: 'Pending')
        .orderBy('date')
        .snapshots();
  }

  Future<void> updateBookingStatus(String docId, String newStatus) async {
    await _bookingsRef.doc(docId).update({'status': newStatus});
  }
}