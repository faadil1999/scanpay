import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _qrData;

  void _generateQR() {
    if (_amountController.text.isEmpty) return;

    final data = {
      'merchantId': 'merchant_456', // ID réel du marchand
      'amount': double.parse(_amountController.text),
      'description': _descController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _qrData = jsonEncode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Générer un QR Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_qrData == null) ...[
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _generateQR,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: const Color(0xFFFFCC00),
                ),
                child: const Text('Générer le QR Code', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              Center(
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 280.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${_amountController.text} FCFA',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () => setState(() => _qrData = null),
                child: const Text('Nouveau QR Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
