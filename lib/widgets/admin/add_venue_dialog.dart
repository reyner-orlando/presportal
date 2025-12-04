import 'package:flutter/material.dart';
import '../../services/venue_service.dart';

class AddVenueDialog extends StatelessWidget {
  const AddVenueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers
    final idController = TextEditingController(); // Controller ID Baru
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();
    final facilitiesController = TextEditingController();

    final List<String> categories = ['Classroom', 'Laboratory', 'Auditorium', 'Meeting Room'];
    String? selectedCategory;
    final venueService = VenueService();

    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text("Add New Venue"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. INPUT ID MANUAL
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: "Venue ID (Unique)",
                    hintText: "e.g. LAB-001",
                    prefixIcon: Icon(Icons.vpn_key),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Venue Name", prefixIcon: Icon(Icons.meeting_room)),
                ),
                const SizedBox(height: 10),

                // 3. Location
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: "Location", prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 10),

                // 4. Category & Capacity
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: "Category", contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                        value: selectedCategory,
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) => setStateDialog(() => selectedCategory = val),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Cap.", hintText: "40"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 5. Facilities
                TextField(
                  controller: facilitiesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Facilities",
                    hintText: "AC, WiFi",
                    helperText: "Separate by comma",
                    prefixIcon: Icon(Icons.settings_input_component),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (idController.text.isNotEmpty &&
                    nameController.text.isNotEmpty &&
                    selectedCategory != null) {

                  // Convert String to List
                  List<String> facilitiesList = facilitiesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  // Panggil Service
                  venueService.addVenue(
                    id: idController.text.trim(), // Pakai ID Input
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    category: selectedCategory!,
                    capacity: int.tryParse(capacityController.text) ?? 0,
                    facilities: facilitiesList,
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill ID, Name, and Category")));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}