import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  Stream<List<Room>> getRooms() {
    return FirebaseFirestore.instance
        .collection('venues')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<Room>((doc) {
        return Room.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
}
