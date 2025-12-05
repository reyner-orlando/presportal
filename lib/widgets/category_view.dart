import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../services/venue_service.dart';
import 'venue_card.dart';

class CategoryView extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final VenueService venueService;
  final List<String> categories;

  const CategoryView({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.venueService,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: (value) => onCategoryChanged(value!),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Venue>>(
            stream: venueService.getVenues(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              // LOGIKA BARU:
              final allVenues = snapshot.data!;

              final filtered = allVenues.where((v) {
                // 1. Pastikan field di Room model bernama 'category'
                // 2. Gunakan toLowerCase() agar aman dari huruf besar/kecil
                // 3. Atau gunakan '==' jika datanya sudah pasti sama persis

                // OPSI A: Jika ingin filter persis
                // return r.category == selectedCategory;

                // OPSI B: Jika ada opsi "All" (Semua)
                if (selectedCategory == 'All' || selectedCategory == 'Semua') {
                  return true;
                }

                // OPSI C (Perbaikan kode Anda): Filter by Category, bukan Location
                return v.category == selectedCategory;

              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("No rooms in this category"));
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: filtered.map((venue) => VenueCard(
                  venue: venue,
                  onBooking: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking ${venue.name} ...'))),
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
