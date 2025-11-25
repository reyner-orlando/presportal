import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String activityType;
  final String bookingId;
  final DateTime date;
  final String status;

  final DocumentReference studentRef;
  final DocumentReference venueRef;

  // populated after attachDetails()
  String? studentName;
  String? venueName;

  Booking({
    required this.id,
    required this.activityType,
    required this.bookingId,
    required this.date,
    required this.status,
    required this.studentRef,
    required this.venueRef,
    this.studentName,
    this.venueName,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      activityType: map['activitytype'] ?? '',
      bookingId: map['bookingid'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: map['status'] ?? '',
      studentRef: map['userid'],     // sesuai Firestore
      venueRef: map['venueid'],      // sesuai Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activitytype': activityType,
      'bookingid': bookingId,
      'date': date,
      'status': status,
      'userid': studentRef,
      'venueid': venueRef,
    };
  }
}
