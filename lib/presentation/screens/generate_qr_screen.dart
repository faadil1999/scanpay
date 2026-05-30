import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/qr_code_provider.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/qr_code_model.dart';

class GenerateQRScreen extends ConsumerStatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  ConsumerState<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends ConsumerState<GenerateQRScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(QrCodeModel qr) {
    _remaining = qr.remainingTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final rem = qr.expiresAt.difference(DateTime.now());
      if (mounted) {
        setState(() => _remaining = rem.isNegative ? Duration.zero : rem);
      }
      if (rem.isNegative) _timer?.cancel();
    });
  }

  Future<void> _generate() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final walletId = ref.read(defaultWalletProvider).valueOrNull?.id;

    await ref.read(qrCodeNotifierProvider.notifier).generate(
      amount: amount,
      description: _descController.text.trim(),
      walletId: walletId,
    );

    final qr = ref.read(qrCodeNotifierProvider).valueOrNull;
    if (qr != null) _startTimer(qr);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrCodeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Générer un QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          if (state.valueOrNull != null)
            TextButton.icon(
              onPressed: () {
                _timer?.cancel();
                ref.read(qrCodeNotifierProvider.notifier).reset();
              },
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Nouveau'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFF59E0B)),
            ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.alertCircle, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(qrCodeNotifierProvider.notifier).reset(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        data: (qr) => qr == null ? _buildForm() : _buildQRDisplay(qr),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Montant (XOF)',
                    prefixIcon: const Icon(LucideIcons.banknote, color: Color(0xFFF59E0B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optionnel)',
                    prefixIcon: const Icon(LucideIcons.fileText, color: Color(0xFF64748B)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _generate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Générer le QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildQRDisplay(QrCodeModel qr) {
    final isExpired = _remaining == Duration.zero && qr.isExpired;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                if (qr.qrImage != null && !isExpired)
                  Image.memory(
                    base64Decode(qr.qrImage!.split(',').last),
                    width: 250,
                    height: 250,
                  )
                else
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.clock, size: 48, color: Color(0xFF64748B)),
                        SizedBox(height: 8),
                        Text('QR Code expiré', style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  qr.formattedAmount,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                if (qr.description != null && qr.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(qr.description!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Réf: ${qr.reference}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(height: 16),
                if (!isExpired)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.clock, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        'Expire dans ${_formatDuration(_remaining)}',
                        style: TextStyle(
                          color: _remaining.inSeconds < 60 ? Colors.red : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'QR Code expiré',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              _timer?.cancel();
              ref.read(qrCodeNotifierProvider.notifier).reset();
            },
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Nouveau QR Code'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: const BorderSide(color: Color(0xFFF59E0B)),
              foregroundColor: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}
