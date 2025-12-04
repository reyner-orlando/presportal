import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';
import 'booking_card.dart';

class DateView extends StatefulWidget {
  final DateTime selectedDay;
  final BookingService bookService;
  final ValueChanged<DateTime> onDaySelected;
  final String userId;

  const DateView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.bookService,
    required this.userId,
  });

  @override
  State<DateView> createState() => _DateViewState();
}

class _DateViewState extends State<DateView> {
  String? selectedVenueId;
  String? selectedActivity;
  String? selectedVenueName;
  String? selectedSlotId;
  String? selectedSlotTime;
  final bookingService = BookingService();
  final List<Map<String, String>> timeSlot = [
    {
      'id': '1',
      'time': '18:00 - 20:00',
    },
    {
      'id': '2',
      'time': '20:00 - 22:00',
    },
  ];

  // gunakan selectedDay dari parent
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ------------ CALENDAR ------------
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),

            onDaySelected: (selected, focused) {
              setState(() => _selectedDay = selected);

              // ❗ notify parent
              widget.onDaySelected(selected);
            },
          ),

          const SizedBox(height: 10),

          // ------------ BOOKINGS LIST ------------
          StreamBuilder<List<Booking>>(
            stream: widget.bookService.getBookingsByDate(_selectedDay),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = snapshot.data!;

              if (bookings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No bookings on this day."),
                );
              }

              return Column(
                children: bookings.map((b) => BookingCard(booking: b)).toList(),
              );
            },
          ),

          // ------------ BOOKING FORM ------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Booking Form",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // ------------ VENUE DROPDOWN ------------
                StreamBuilder<List<Booking>>(
                  stream: widget.bookService.getBookingsByDate(_selectedDay),

                  builder: (context, bookingSnapshot) {
                    if(!bookingSnapshot.hasData){
                      return const Center(child:CircularProgressIndicator());
                    }

                    final bookedVenueIds = bookingSnapshot.data!
                        .map((b) => b.venueId)
                        .toSet();

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('venues').orderBy('name').snapshots(),
                      builder: (context, venueSnapshot) {
                        if (!venueSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (venueSnapshot.data!.docs.isEmpty) {
                          return const Text("No venues available in database");
                        }

                        // --- INI LOGIKA FILTERNYA ---
                        // Kita filter docs: Hanya ambil venue yang ID-nya TIDAK ADA di bookedVenueIds
                        final availableVenues = venueSnapshot.data!.docs.where((doc) {
                          return !bookedVenueIds.contains(doc.id);
                        }).toList();

                        // Cek jika setelah difilter ternyata habis (semua ruangan penuh)
                        if (availableVenues.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!)
                            ),
                            child: const Text("All venues are fully booked for this date!"),
                          );
                        }

                        // Mapping data venue yang tersisa ke DropdownMenuItem
                        List<DropdownMenuItem<String>> venueItems = availableVenues.map((doc) {
                          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(data['name']), // Tampilkan nama, tapi value-nya ID
                          );
                        }).toList();

                        // ---------------------------------------------
                        // VALIDASI NILAI TERPILIH (PENTING!)
                        // Jika user ganti tanggal, dan venue yang tadinya dipilih ternyata penuh di tanggal baru,
                        // kita harus reset selectedVenueId jadi null agar tidak error.
                        if (selectedVenueId != null && !bookedVenueIds.contains(selectedVenueId)) {
                          // Aman, venue yang dipilih masih available
                        } else if (selectedVenueId != null && bookedVenueIds.contains(selectedVenueId)) {
                          // Venue yang dipilih ternyata sudah dibooking orang lain/tanggal lain
                          // Kita reset visualnya (walaupun setState idealnya tidak di dalam build,
                          // untuk dropdown biasanya value akan otomatis null jika tidak ada di items,
                          // tapi lebih aman kita handle logic UI-nya)
                          selectedVenueId = null;
                        }
                        // ---------------------------------------------

                        return DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Choose available venue'),
                          value: selectedVenueId, // Pastikan value ini ada di list items
                          items: venueItems,
                          hint: const Text("Choose one"),
                          onChanged: (String? newId) {
                            setState(() {
                              selectedVenueId = newId;

                              // Cari nama venue berdasarkan ID yang dipilih dari list yang sudah difilter
                              final selectedDoc = availableVenues.firstWhere((doc) => doc.id == newId);
                              selectedVenueName = selectedDoc['name'];
                            });
                          },
                        );
                      },
                    );
                  },
                ),

                // ------------ ACTIVITY RADIO ------------
                const SizedBox(height: 20),
                const Text("Activity Type", style: TextStyle(fontSize: 14)),


                RadioListTile<String>(
                  title: const Text("Event"),
                  value: "Event",
                  groupValue: selectedActivity,
                  onChanged: (value) {
                    setState(() => selectedActivity = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Meeting"),
                  value: "Meeting",
                  groupValue: selectedActivity,
                  onChanged: (value) {
                    setState(() => selectedActivity = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Class"),
                  value: "Class",
                  groupValue: selectedActivity,
                  onChanged: (value) {
                    setState(() => selectedActivity = value);
                  },
                ),


                // ------------ REASON ------------
                TextField(
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 20),
                const Text("Choose Time Slot", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

// Logic StreamBuilder untuk Cek Ketersediaan Slot
                selectedVenueId == null
                    ? const Text("Please select a venue first.", style: TextStyle(color: Colors.grey))
                    : StreamBuilder<List<Booking>>(
                  stream: widget.bookService.getBookingsByDate(_selectedDay),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }

                    // Filter booking: Ambil booking HANYA untuk Venue yang dipilih saat ini
                    final bookingsForVenue = snapshot.data!.where((b) => b.venueId == selectedVenueId).toList();

                    // Kumpulkan ID slot yang SUDAH diambil orang
                    final bookedSlotIds = bookingsForVenue.map((b) => b.timeId).toSet(); // Asumsi di model Booking ada field slotId

                    return Wrap(
                      spacing: 10.0, // Jarak antar tombol
                      children: timeSlot.map((slot) {
                        final isBooked = bookedSlotIds.contains(slot['id']);
                        final isSelected = selectedSlotId == slot['id'];

                        return ChoiceChip(
                          label: Text(
                            slot['time']!,
                            style: TextStyle(
                              color: isBooked
                                  ? Colors.grey // Teks abu jika penuh
                                  : (isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                          // Kalau selected, warna biru. Kalau penuh, warna abu muda. Kalau kosong, putih/abu tipis.
                          selectedColor: Colors.blue,
                          backgroundColor: isBooked ? Colors.grey[200] : Colors.grey[100],
                          disabledColor: Colors.grey[300],

                          selected: isSelected,

                          // INI LOGIC KUNCINYA:
                          // Jika isBooked = true, onSelected kita buat null (tombol mati/disable)
                          onSelected: isBooked
                              ? null
                              : (bool selected) {
                            setState(() {
                              // Jika user klik tombol yang sama, batalkan pilihan (opsional)
                              // atau set value baru
                              selectedSlotId = selected ? slot['id'] : null;

                              // Simpan juga string waktunya buat dikirim ke database
                              if (selected) {
                                selectedSlotTime = slot['time'];
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // ------------ CONFIRM BUTTON ------------
                ElevatedButton(
                  onPressed: () async {
                    if (selectedVenueId == null || selectedActivity == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please complete all fields"),
                        ),
                      );
                      return;
                    }

                    await widget.bookService.addBooking(
                      activityType: selectedActivity!,
                      venueId: selectedVenueId!,  // pakai ID venue
                      venueName: selectedVenueName!,
                      date: _selectedDay,
                      studentId: widget.userId, // isi sesuai user login
                      timeId: selectedSlotId!,
                      timeSlot: selectedSlotTime!,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Booking added successfully")),
                    );
                  },
                  child: Text(
                    "Confirm Booking for ${_selectedDay.toString().split(' ')[0]}",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
