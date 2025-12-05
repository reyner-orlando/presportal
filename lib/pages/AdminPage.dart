import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/venue_service.dart';
import '../models/venue.dart';
import '../widgets/admin/add_venue_dialog.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.verified_user), text: "Requests"),
              Tab(icon: Icon(Icons.meeting_room), text: "Manage Venues"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookingRequestsTab(),
            _VenueManagementTab(),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// TAB 1: BOOKING REQUESTS (APPROVE / REJECT)
// =========================================================
class _BookingRequestsTab extends StatelessWidget {
  const _BookingRequestsTab();

  Future<void> _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(docId)
        .update({'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'Pending')
          .orderBy('date')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 10),
                Text("All requests handled!", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();

            final studentName = data['username'] ?? 'Unknown';
            final venueName = data['venuename'] ?? 'Unknown Venue';
            final timeSlot = data['timeslot'] ?? '-';
            final reason = data['activitytype'] ?? '-';

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
                        Text(
                          DateFormat('EEE, dd MMM yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("Pending", style: TextStyle(color: Colors.orange, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text("Student: $studentName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Venue: $venueName"),
                    Text("Time: $timeSlot"),
                    Text("Activity: $reason"),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _updateStatus(doc.id, 'Rejected'),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text("Reject", style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(doc.id, 'Approved'),
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
          },
        );
      },
    );
  }
}

// =========================================================
// TAB 2: MANAGE VENUES (ADD / DELETE) - UPDATED
// =========================================================
class _VenueManagementTab extends StatefulWidget {
  const _VenueManagementTab();

  @override
  State<_VenueManagementTab> createState() => _VenueManagementTabState();
}

class _VenueManagementTabState extends State<_VenueManagementTab> {
  final VenueService _venueService = VenueService();
  final List<String> categories = ['Classroom', 'Laboratory', 'Auditorium', 'Meeting Room'];

  // --- 1. LOGIKA DELETE ---
  void _deleteVenue(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Venue?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _venueService.deleteVenue(id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  // --- 2. LOGIKA EDIT (DIALOG) ---
  void _showEditVenueDialog(BuildContext context, Venue venue) {
    // Isi controller dengan data LAMA (Pre-fill)
    final nameController = TextEditingController(text: venue.name);
    final locationController = TextEditingController(text: venue.location);
    final capacityController = TextEditingController(text: venue.capacity.toString());

    // Gabungkan list fasilitas jadi string koma untuk ditampilkan
    final facilitiesController = TextEditingController(text: venue.facilities.join(', '));

    String? selectedCategory = venue.category;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Edit Venue: ${venue.name}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.meeting_room)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: "Location", prefixIcon: Icon(Icons.location_on)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: "Category", contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                            value: categories.contains(selectedCategory) ? selectedCategory : null,
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
                            decoration: const InputDecoration(labelText: "Cap."),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: facilitiesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Facilities",
                        helperText: "Separate by comma",
                        prefixIcon: Icon(Icons.settings_input_component),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && selectedCategory != null) {
                      // Logic Split String ke List
                      List<String> facilitiesList = facilitiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      // Panggil Service Update
                      _venueService.updateVenue(
                        id: venue.id,
                        name: nameController.text.trim(),
                        location: locationController.text.trim(),
                        category: selectedCategory!,
                        capacity: int.tryParse(capacityController.text) ?? 0,
                        facilities: facilitiesList,
                      );

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Venue updated successfully")));
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Solusi Error AddVenueDialog context: Gunakan showDialog
          showDialog(
            context: context,
            builder: (context) {
              return const AddVenueDialog();
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Venue"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('venues').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No venues yet. Click + to add."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              // [PENTING] Convert Doc ke Object Venue agar bisa dikirim ke Edit Dialog
              final venue = Venue.fromFirestore(doc);

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
                                Text(
                                  "${venue.category} • ${venue.location}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // [BARU] Tombol Edit dan Delete
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _showEditVenueDialog(context, venue),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  // Konfirmasi hapus
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Delete Venue?"),
                                      content: const Text("This action cannot be undone."),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                        TextButton(
                                          onPressed: () {
                                            _deleteVenue(venue.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          _buildInfoChip(Icons.groups, "${venue.capacity} Seats"),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.fingerprint, "ID: ${venue.id}"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tampilkan Facilities
                      const Text("Facilities:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),

                      venue.facilities.isEmpty
                          ? const Text("-", style: TextStyle(color: Colors.grey))
                          : Wrap(
                        spacing: 6.0,
                        runSpacing: 0.0,
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
            },
          );
        },
      ),
    );
  }

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