import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildRow('Subtotal', '\$3.50'),
          const SizedBox(height: 12),
          _buildPromoRow(),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, thickness: 1),
          const SizedBox(height: 16),
          _buildRow('Track My Delivery', '>', isAction: true),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool isAction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: isAction ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isAction ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: isAction ? const Color(0xFF00E5FF) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPromoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Apply Promo',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
        Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.6), size: 16),
      ],
    );
  }
}
