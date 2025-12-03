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


  const DateView({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.bookService,
  });

  @override
  State<DateView> createState() => _DateViewState();
}

class _DateViewState extends State<DateView> {
  String? selectedVenueId;
  String? selectedActivity;
  String? selectedVenueName;
  final bookingService = BookingService();
  // Map<String, String> venueMap = {
  //   "Lab A216": "0001",
  //   "B204": "0002",
  //   "Lab 402": "0003",
  //   "Meeting Room": "0004",
  // };

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
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('venues').orderBy('name').snapshots(),

                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return const Center(child:CircularProgressIndicator());
                    }

                    if(snapshot.data!.docs.isEmpty) {
                      return const Text("No venues yet");
                    }

                    List<DropdownMenuItem<String>> venueItems = snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(data['name']),
                      );
                    }).toList();

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Choose venue/room'),
                      value: selectedVenueId,
                      items: venueItems,
                      hint: const Text("Choose one"),

                      onChanged: (String? newId) {
                        setState(() {
                          selectedVenueId = newId;

                          final selectedDoc = snapshot.data!.docs.firstWhere((doc) => doc.id == newId);
                          selectedVenueName = selectedDoc['name'];

                          print("User choose: $selectedVenueName (ID: $selectedVenueId)");
                        });
                      },
                    );
                  },
                ),

                // ------------ ACTIVITY RADIO ------------
                const Text("Activity Type"),
                const SizedBox(height: 6),

                RadioListTile<String>(
                  title: const Text("Presentation"),
                  value: "Presentation",
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

                const SizedBox(height: 12),

                // ------------ REASON ------------
                TextField(
                  decoration: const InputDecoration(labelText: "Reason"),
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
                      studentId: "001202400087", // isi sesuai user login
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
