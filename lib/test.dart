import 'package:GL_proxy/pos.dart';
import 'package:flutter/material.dart';

import 'deep_links.dart';

class ConnectionStatusTestScreen extends StatelessWidget {
  final String targetAddress;
  final String payload;
  final String host;
  const ConnectionStatusTestScreen(this.targetAddress, this.payload, this.host, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Received IP : [ $targetAddress ]"),
          const SizedBox(height: 20),
          Text("Payload : [ $payload ]"),
          const SizedBox(height: 20),
          _buildConnectionButtons(context),
        ],
      ),
    );
  }

  Widget _buildConnectionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => processPayment(context, targetAddress, payload),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Connect'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildSuccessButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => showSuccessDialog(context, {}),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Test Success'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildFailureButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => showFailureDialog(context, "Test error"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Test Failed'),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  void processPayment(BuildContext context, String targetAddress, String payload) async {
    final posService = PosTerminalService(host: targetAddress, port: 8080);

    posService.sendTransaction(payload).then((value) {
      final status = posService.getResponseStatus(value);
      if (posService.checkSuccess(value)) {
        print('[Transaction successful] : $value');
        showSuccessDialog(context, value);
      } else {
        print('[Transaction failed] : $status');
        showFailureDialog(context, status, responsePayload: value);
      }

    }).catchError((e) {
      print('[Transaction failed]: $e');
      showFailureDialog(context, e);
    });
  }

  Future<void> showSuccessDialog(BuildContext context, Map<String, dynamic> successPayload) {
    showDialog(context: context,
        builder: (context) =>
        const AlertDialog(
          title: Text("Transaction Success\n\nRouting back to Green Ladies console."),
        )
    );
    return Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
      DeepLink().routeToConsole(host, successPayload, payload);
    });
  }

  Future<void> showFailureDialog(
      BuildContext context,
      String message,
      { Map<String, dynamic>? responsePayload }) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Transaction Failed\n\nReason: $message \n\nRouting back to Green Ladies console."),
        )
    );
    return Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      if (responsePayload == null) {
        DeepLink().routeToConsoleFailed(host);
      } else {
        DeepLink().routeToConsole(host, responsePayload, payload);
      }
    });
  }
}