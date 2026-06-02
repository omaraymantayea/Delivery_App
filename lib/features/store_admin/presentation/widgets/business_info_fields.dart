import 'package:flutter/material.dart';

class BusinessInfoFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController taxCtrl;

  const BusinessInfoFields({
    super.key,
    required this.nameCtrl,
    required this.addressCtrl,
    required this.taxCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('1. Business Info', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildField(nameCtrl, 'Name'),
        const SizedBox(height: 12),
        _buildField(addressCtrl, 'Address'),
        const SizedBox(height: 12),
        _buildField(taxCtrl, 'Tax ID'),
      ],
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: const Color(0xFF00E5FF).withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
      ),
    );
  }
}