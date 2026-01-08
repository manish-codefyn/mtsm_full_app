import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Events',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      body: const Center(
        child: Text('Event List - Coming Soon'),
      ),
    );
  }
}
