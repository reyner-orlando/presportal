import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;


  /// Simpan booking baru
  Future<void> addBooking({
    required String activityType,
    required String venueName,
    required DateTime date,
    required String studentId,
  }) async {
    final docRef = _firestore.collection('bookings').doc();

    final booking = Booking(
      id: docRef.id,
      bookingId: "book-${DateTime.now().millisecondsSinceEpoch}",
      activityType: activityType,
      status: "Pending",
      date: date,
      studentRef: _firestore.doc("students/$studentId"),
      venueRef: _firestore.doc("venues/$venueName"),
    );

    await docRef.set(booking.toMap());
  }


  /// Ambil studentName & venueName dari reference
  Future<Booking> attachDetails(Booking booking) async {
    final studentSnap = await booking.studentRef.get();
    final venueSnap   = await booking.venueRef.get();

    booking.studentName = studentSnap['name'];
    booking.venueName   = venueSnap['name'];

    return booking;
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
        .asyncMap((snapshot) async {

      // Convert Firestore → Booking
      final bookings = snapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .toList();

      // Fetch detail studentName & venueName
      for (var b in bookings) {
        await attachDetails(b);
      }

      return bookings;
    });
  }
}
