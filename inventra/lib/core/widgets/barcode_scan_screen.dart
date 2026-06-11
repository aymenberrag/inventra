import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';



class BarcodeScanScreen extends StatefulWidget {

  const BarcodeScanScreen({super.key});



  @override

  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();

}



class _BarcodeScanScreenState extends State<BarcodeScanScreen> {

  final _controller = MobileScannerController();

  bool _processing = false;

  String? _lastScanned;



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  void _onDetect(BarcodeCapture capture) {

    if (_processing) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;

    if (barcode == null || barcode == _lastScanned) return;



    setState(() {

      _processing = true;

      _lastScanned = barcode;

    });



    Navigator.pop(context, barcode);

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);



    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        backgroundColor: Colors.black,

        foregroundColor: Colors.white,

        title: Text(l10n.scanBarcode),

      ),

      body: Stack(

        children: [

          MobileScanner(

            controller: _controller,

            onDetect: _onDetect,

          ),

          Center(

            child: Container(

              width: 260,

              height: 160,

              decoration: BoxDecoration(

                border: Border.all(color: AppTheme.primary, width: 2),

                borderRadius: BorderRadius.circular(16),

              ),

            ),

          ),

          Positioned(

            bottom: 40,

            left: 0,

            right: 0,

            child: Text(

              l10n.pointCamera,

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.white70, fontSize: 14),

            ),

          ),

        ],

      ),

    );

  }

}

