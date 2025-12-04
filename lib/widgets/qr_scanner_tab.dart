import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerTab extends StatefulWidget {
  final void Function(String friendId) onScan;
  final void Function(String error) errorCallback;

  const QRScannerTab({
    super.key,
    required this.onScan,
    required this.errorCallback,
  });

  @override
  State<QRScannerTab> createState() => _QRScannerTabState();
}

class _QRScannerTabState extends State<QRScannerTab>
    with AutomaticKeepAliveClientMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String value) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);
    controller.stop(); // Stop scanner to prevent multiple detections

    try {
      widget.onScan(value);
    } catch (_) {
      widget.errorCallback("Failed to process QR code");
    }

    // Give time for dialog animations
    await Future.delayed(const Duration(milliseconds: 300));

    // Resume scanning
    if (mounted) {
      await controller.start();
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (barcodeCapture) {
            final raw = barcodeCapture.barcodes.first.rawValue;
            if (raw != null) {
              _handleScan(raw);
            } else {
              widget.errorCallback("Failed to scan QR code");
            }
          },
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: const Text(
                "Point your camera at a friend's QR code",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
