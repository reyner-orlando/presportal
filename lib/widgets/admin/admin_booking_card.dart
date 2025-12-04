import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class AdminBookingCard extends StatelessWidget {
  final DocumentSnapshot doc;

  const AdminBookingCard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final date = (data['date'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEE, dd MMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(4)),
                  child: const Text("Pending", style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              ],
            ),
            const Divider(),
            Text("Student: ${data['username'] ?? 'Unknown'}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Venue: ${data['venuename'] ?? '-'}"),
            Text("Time: ${data['timeslot'] ?? '-'}"),
            Text("Activity: ${data['activitytype'] ?? '-'}"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => AdminService().updateBookingStatus(doc.id, 'Rejected'),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text("Reject", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => AdminService().updateBookingStatus(doc.id, 'Approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}