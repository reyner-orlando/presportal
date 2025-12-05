import 'package:flutter/material.dart';
import '../../models/venue.dart';

class AdminVenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onEdit;   // Callback saat tombol Edit ditekan
  final VoidCallback onDelete; // Callback saat tombol Delete ditekan

  const AdminVenueCard({
    super.key,
    required this.venue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER: Nama, Lokasi, dan TOMBOL AKSI
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${venue.category} • ${venue.location}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // --- BAGIAN TOMBOL EDIT & DELETE ---
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Edit Venue',
                      onPressed: onEdit,
                      constraints: const BoxConstraints(), // Biar icon tidak makan tempat
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    // Tombol Delete
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Delete Venue',
                      onPressed: onDelete,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 8),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(),

            // BODY: Capacity & ID
            Row(
              children: [
                _buildInfoChip(Icons.groups, "${venue.capacity} Seats"),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.vpn_key, "ID: ${venue.id}"),
              ],
            ),

            const SizedBox(height: 12),

            // FOOTER: Facilities
            const Text("Facilities:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),

            venue.facilities.isEmpty
                ? const Text("-", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                : Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: venue.facilities.map((facility) {
                return Chip(
                  label: Text(facility, style: const TextStyle(fontSize: 11)),
                  backgroundColor: Colors.blue[50],
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper Kecil
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}