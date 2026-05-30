import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/wallet_provider.dart';
import '../../data/models/qr_code_model.dart';
import '../../data/services/api_service.dart';
import '../providers/auth_provider.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  final QrCodeModel qrCode;
  const ConfirmationScreen({super.key, required this.qrCode});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _isLoading = false;

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final senderWalletId = ref.read(defaultWalletProvider).valueOrNull?.id;

      if (senderWalletId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun wallet disponible. Ajoutez un wallet d\'abord.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await api.post('/transactions', {
        'qrReference': widget.qrCode.reference,
        'senderWalletId': senderWalletId,
      });

      if (mounted) _showSuccessDialog();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.displayMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = widget.qrCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Confirmation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(LucideIcons.shieldCheck, size: 64, color: Color(0xFF059669)),
            const SizedBox(height: 16),
            const Text(
              'QR Code Validé',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF059669), letterSpacing: 1),
            ),
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
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
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Text(
                          'MONTANT À PAYER',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          qr.formattedAmount,
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        if (qr.description != null && qr.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(qr.description!, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      20,
                      (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 1,
                          color: i.isEven ? Colors.transparent : Colors.grey[100],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        _infoRow(LucideIcons.hash, "RÉFÉRENCE", qr.reference),
                        const SizedBox(height: 24),
                        _infoRow(
                          LucideIcons.clock,
                          "EXPIRE À",
                          '${qr.expiresAt.hour.toString().padLeft(2, '0')}:${qr.expiresAt.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (qr.isExpired)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Ce QR code a expiré', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: _isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Confirmer le paiement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          Icon(LucideIcons.arrowRight, size: 20),
                        ],
                      ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Icon(LucideIcons.checkCircle2, size: 80, color: Color(0xFF059669)),
            const SizedBox(height: 24),
            const Text('Paiement Réussi !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Votre transaction a été initiée avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Retour à l\'accueil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
