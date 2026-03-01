import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'confirmation_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un QR Code'),
        actions: [
          // Bouton Flash (Torch)
          ValueListenableBuilder(
            valueListenable: cameraController,
            builder: (context, state, child) {
              final TorchState torchState = state.torchState;
              return IconButton(
                icon: Icon(
                  torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: torchState == TorchState.on ? Colors.yellow : Colors.grey,
                ),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          // Bouton Rotation Caméra
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              // On arrête le scanner temporairement pour éviter les scans multiples
              cameraController.stop();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmationScreen(qrData: code),
                ),
              ).then((_) {
                // On redémarre le scanner quand on revient sur cet écran
                cameraController.start();
              });
            }
          }
        },
      ),
    );
  }
}
