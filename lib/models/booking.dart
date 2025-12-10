import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String activityType;
  final String bookingId;
  final DateTime date;
  final String status;
  final String studentId;
  final String studentName;
  final String venueId;
  final String venueName;
  final String timeId;
  final String timeSlot;


  Booking({
    required this.id,
    required this.activityType,
    required this.bookingId,
    required this.date,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.venueId,
    required this.venueName,
    required this.timeId,
    required this.timeSlot,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      activityType: map['activityType'] ?? 'Unknown Activity',
      status: map['status'] ?? 'Pending',
      bookingId: map['bookingid'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      studentId: map['userid'],
      studentName: map['username'],
      venueId: map['venueid'],
      venueName: map['venuename'],
      timeId: map['timeId'] ?? map['slotId'] ?? '', // Cek kedua kemungkinan nama field
      timeSlot: map['timeSlot'] ?? map['slotTime'] ?? '-',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activitytype': activityType,
      'bookingid': bookingId,
      'date': date,
      'status': status,
      'userid': studentId,
      'venueid': venueId,
      'username': studentName,
      'venuename': venueName,
      'timeid': timeId,
      'timeslot': timeSlot,
    };
  }
}
