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
  MobileScannerController controller = MobileScannerController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // needed for AutomaticKeepAliveClientMixin

    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (barcodeCapture) {
            final value = barcodeCapture.barcodes.first.rawValue;
            if (value != null) {
              widget.onScan(value);
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
                "Point your camera at a friend’s QR code",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
