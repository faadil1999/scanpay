import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Historique des transactions'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Simulation de 10 transactions
        itemBuilder: (context, index) {
          final bool isIncome = index % 3 == 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                  color: isIncome ? const Color(0xFF059669) : const Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              title: Text(
                isIncome ? "Reçu de Jean D." : "Paiement Erevan",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now().subtract(Duration(hours: index * 2))),
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              trailing: Text(
                "${isIncome ? '+' : '-'}${2500 * (index + 1)} F",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? const Color(0xFF059669) : const Color(0xFF0F172A),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
