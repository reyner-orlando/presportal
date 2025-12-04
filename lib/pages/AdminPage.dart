import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final List<String> categories = ['Classroom', 'Laboratory', 'Auditorium', 'Meeting Room'];
  String? selectedCategory;

  void _showAddVenueDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController facilitiesController = TextEditingController();

    selectedCategory = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New Venue"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Venue Name",
                        hintText: "E.g. Lab Programming A",
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: "Location/Building",
                        hintText: "E.g. Building B, 2nd Floor",
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Category",
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            ),
                            value: selectedCategory,
                            items: categories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 14)));
                            }).toList(),
                            onChanged: (val) {
                              setStateDialog(() => selectedCategory = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: capacityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Cap.",
                              hintText: "40",
                              prefixIcon: Icon(Icons.people),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: facilitiesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Facilities (Separate by comma)", // Update hint
                        hintText: "AC, Projector, WiFi",
                        helperText: "Pisahkan dengan koma",
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
                    if (nameController.text.isNotEmpty &&
                        selectedCategory != null &&
                        capacityController.text.isNotEmpty) {

                      // 1. UBAH TEXT JADI LIST AGAR TERSIMPAN SEBAGAI ARRAY
                      List<String> facilitiesList = facilitiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      FirebaseFirestore.instance.collection('venues').add({
                        'name': nameController.text.trim(),
                        'location': locationController.text.trim(),
                        'category': selectedCategory,
                        'capacity': int.tryParse(capacityController.text) ?? 0,
                        'facilities': facilitiesList, // Simpan List
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(ctx);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill Name, Category, and Capacity"))
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteVenue(String id) {
    FirebaseFirestore.instance.collection('venues').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVenueDialog(context),
        icon: const Icon(Icons.add),
        label: const Text("Add Venue"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('venues').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final venues = snapshot.data!.docs;

          if (venues.isEmpty) {
            return const Center(child: Text("No venues yet. Click + to add."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final doc = venues[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'No Name';
              final location = data['location'] ?? '-';
              final category = data['category'] ?? 'General';
              final capacity = data['capacity']?.toString() ?? '0';
              final id = doc.id;

              // 2. LOGIC AMBIL DATA AGAR AMAN (List atau String)
              List<dynamic> facilitiesList = [];
              if (data['facilities'] is List) {
                facilitiesList = data['facilities'];
              } else if (data['facilities'] is String) {
                facilitiesList = [data['facilities']];
              }

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
                                Text(
                                  name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                                Text(
                                  "$category • $location",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete Venue?"),
                                  content: const Text("This action cannot be undone."),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () {
                                        _deleteVenue(id);
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
                      const Divider(),
                      Row(
                        children: [
                          _buildInfoChip(Icons.groups, "$capacity Seats"),
                          const SizedBox(width: 12),
                          _buildInfoChip(Icons.fingerprint, "ID: ...${id.length > 4 ? id.substring(id.length - 4) : id}"),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. TAMPILKAN FACILITIES PAKAI WRAP & CHIP
                      const Text("Facilities:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),

                      facilitiesList.isEmpty
                          ? const Text("-", style: TextStyle(color: Colors.grey))
                          : Wrap(
                        spacing: 6.0,
                        runSpacing: 0.0,
                        children: facilitiesList.map((facility) {
                          return Chip(
                            label: Text(facility.toString(), style: const TextStyle(fontSize: 11)),
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