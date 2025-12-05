import 'package:flutter/material.dart';
import '../models/venue.dart';
import 'facility_tag.dart';

const Color primaryColor = Color(0xFF1e40af);
const Color secondaryColor = Color(0xFF8b5cf6);
const Color cardColor = Colors.white;

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onBooking;

  const VenueCard({super.key, required this.venue, this.onBooking});

  @override
  Widget build(BuildContext context) {
    double opacity = venue.isAvailable ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(venue.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(venue.location,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text('Capacity: ${venue.capacity} people',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: venue.facilities.map((f) => FacilityTag(text: f)).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
