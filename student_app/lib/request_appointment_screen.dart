import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

class RequestAppointmentScreen extends StatefulWidget {
  const RequestAppointmentScreen({super.key});

  @override
  State<RequestAppointmentScreen> createState() => _RequestAppointmentScreenState();
}

class _RequestAppointmentScreenState extends State<RequestAppointmentScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  // ignore: unused_field
  String _reason = '';
  String _urgency = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Request Appointment',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 28,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _datePicker(context),
            const SizedBox(height: 16),
            _timePicker(context),
            const SizedBox(height: 16),
            _reasonField(),
            const SizedBox(height: 16),
            _urgencyToggle(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // TODO: Submit appointment request
                },
                child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Appointment Request', style: TextStyle(color: Color(0xFF6B7280), fontFamily: 'Nunito Sans', fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, onTap: (i) {}),
    );
  }

  Widget _datePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF1F2937)),
            const SizedBox(width: 12),
            Text(_selectedDate == null ? 'Preferred Date' : '${_selectedDate!.toLocal()}'.split(' ')[0], style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 16, color: Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _timePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (picked != null) setState(() => _selectedTime = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1F2937)),
            const SizedBox(width: 12),
            Text(_selectedTime == null ? 'Preferred Time' : _selectedTime!.format(context), style: const TextStyle(fontFamily: 'Nunito Sans', fontSize: 16, color: Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _reasonField() {
    return TextField(
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Reason for Appointment',
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        labelStyle: TextStyle(fontFamily: 'Nunito Sans', color: Color(0xFF1F2937)),
      ),
      onChanged: (val) => setState(() => _reason = val),
    );
  }

  Widget _urgencyToggle() {
    final levels = ['Low', 'Medium', 'High'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: levels.map((level) {
        final isSelected = _urgency == level;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ChoiceChip(
            label: Text(level, style: TextStyle(fontFamily: 'Nunito Sans', color: isSelected ? Colors.white : Color(0xFF1F2937))),
            selected: isSelected,
            selectedColor: const Color(0xFF0F766E),
            backgroundColor: const Color(0xFF6B7280),
            onSelected: (_) => setState(() => _urgency = level),
          ),
        );
      }).toList(),
    );
  }
}
