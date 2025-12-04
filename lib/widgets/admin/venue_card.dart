import 'package:flutter/material.dart';
import '../../models/venue.dart';
import '../../services/venue_service.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(venue.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      Text("${venue.category} • ${venue.location}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteConfirm(context, venue.id);
                  },
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                _buildInfoChip(Icons.groups, "${venue.capacity} Seats"),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.vpn_key, "ID: ${venue.id}"), // Tampilkan ID asli
              ],
            ),
            const SizedBox(height: 8),
            const Text("Facilities:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            venue.facilities.isEmpty
                ? const Text("-", style: TextStyle(color: Colors.grey))
                : Wrap(
              spacing: 6.0,
              children: venue.facilities.map((f) => Chip(
                label: Text(f, style: const TextStyle(fontSize: 11)),
                backgroundColor: Colors.blue[50],
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Venue?"),
        content: const Text("Action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              VenueService().deleteVenue(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
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