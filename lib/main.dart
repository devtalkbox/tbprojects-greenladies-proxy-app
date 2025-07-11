import 'package:GL_proxy/pos.dart';
import 'package:GL_proxy/test.dart';
import 'package:flutter/material.dart';

import 'deep_links.dart';


void main() {
  runApp(
    const POSConnectionScreen(),
  );
  DeepLink().initDeepLinks();
}

class POSConnectionScreen extends StatefulWidget {
  const POSConnectionScreen({super.key});
  @override
  State<StatefulWidget> createState() => _POSConnectionScreenState();

}

class _POSConnectionScreenState extends State<POSConnectionScreen> {
  final deeplink = DeepLink();
  bool isTestMode = false;

  @override
  void initState() {
    super.initState();
    deeplink.initDeepLinks();
  }

  @override
  void dispose() {
    deeplink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: deeplink.navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('GreenLadies POS 電子交易服務'),
              actions: [
                IconButton(
                    icon: Icon(Icons.build, size: 24, color: isTestMode ? Colors.greenAccent : Colors.grey,),
                    onPressed: () {
                      setState(() {
                        //isTestMode = !isTestMode;
                      });
                    })
              ],
            ),
            body: body()
          ),
          settings: settings,
          fullscreenDialog: true,
        );
      },
      title: 'GreenLadies POS 電子交易服務',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }

  Widget body() => isTestMode
      ? ConnectionStatusTestScreen(
      deeplink.extractTargetUrl(deeplink.payload?.query), 
      deeplink.extractPayload(deeplink.payload?.query),
      deeplink.extractHost(deeplink.payload?.query))
      : ConnectionStatusScreen(
      deeplink.extractTargetUrl(deeplink.payload?.query),
      deeplink.extractPayload(deeplink.payload?.query),
      deeplink.extractHost(deeplink.payload?.query));
}

class ConnectionStatusScreen extends StatefulWidget {
  final String targetAddress;
  final String payload;
  final String host;

  const ConnectionStatusScreen(this.targetAddress, this.payload, this.host, {super.key});

  @override
  State<StatefulWidget> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetAddress.isNotEmpty || widget.payload.isNotEmpty) {
        processPayment(context, widget.targetAddress, widget.payload);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("GreenLadies POS 電子交易服務"),
          const SizedBox(height: 20.0,),
          if (widget.targetAddress.isNotEmpty || widget.payload.isNotEmpty)
            ...[
              const Text("If there is no loading prompt, click the button below."),
              const SizedBox(height: 20.0,),
              _buildConnectionButtons(context)
            ]
        ],
      ),
    );
  }

  Widget _buildConnectionButtons(BuildContext context) =>
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => processPayment(context, widget.targetAddress, widget.payload),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Connect'),
        ),
        const SizedBox(width: 20),
      ],
    );

  void processPayment(BuildContext context, String targetAddress, String payload) async {
    final posService = PosTerminalService(host: targetAddress, port: 8080);
    showLoadingDialog();
    posService.sendTransaction(payload).then((value) {
      Navigator.pop(context);
      final status = posService.getResponseStatus(value);
      if (posService.checkSuccess(value)) {
        print('[Transaction successful] : $value');
        showSuccessDialog(context, value);
      } else {
        print('[Transaction failed] : $status');
        showFailureDialog(context, status);
      }

    }).catchError((e) {
      Navigator.pop(context);
      print('[Transaction error]: $e');
      showFailureDialog(context, "");
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
      DeepLink().routeToConsole(widget.host, successPayload, widget.payload);
    });
  }

  Future<void> showFailureDialog(BuildContext context, String message, {Map<String, dynamic>? failurePayload}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Transaction Failed\n\nReason: $message \n\nRouting back to Green Ladies console."),
        )
    );
    return Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      failurePayload == null ? DeepLink().routeToConsoleFailed(widget.host) : DeepLink().routeToConsoleFailedWithError(widget.host, failurePayload, widget.payload);
    });
  }

  Future<void> showLoadingDialog() =>
    showDialog(
      barrierDismissible: false, // Prevent dismiss on outside touch
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Transaction in progress\nPlease do not close or background the app.", maxLines: 2,),
            ],
          ),
        );
      },
    );
}