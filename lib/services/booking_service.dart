import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;


  /// Simpan booking baru
  Future<void> addBooking({
    required String activityType,
    required String venueId,
    required DateTime date,
    required String studentId,
    required String venueName,
  }) async {
    final docRef = _firestore.collection('bookings').doc();
    final studentSnap = await _firestore.collection('users').doc(studentId).get();
    String fetchedStudentName = studentSnap.exists
        ? (studentSnap.data()?['full_name'] ?? 'Unknown Student')
        : 'Unknown ID' ;

    final booking = Booking(
      id: docRef.id,
      bookingId: "book-${DateTime.now().millisecondsSinceEpoch}",
      activityType: activityType,
      status: "Pending",
      date: date,
      studentId: studentId,
      studentName: fetchedStudentName,
      venueId: venueId,
      venueName: venueName,
    );

    await docRef.set(booking.toMap());
  }


  /// Ambil booking berdasarkan tanggal dan otomatis fetch nama student + venue
  Stream<List<Booking>> getBookingsByDate(DateTime date) {
    DateTime start = DateTime(date.year, date.month, date.day, 0, 0);
    DateTime end   = DateTime(date.year, date.month, date.day, 23, 59);

    return _firestore
        .collection('bookings')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date')
        .snapshots()
        .asyncMap((snapshot) {

      // Convert Firestore → Booking
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .toList();

    });
  }
}
