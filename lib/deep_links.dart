import 'dart:async';

import 'package:GL_proxy/util.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLink {
  final navigatorKey = GlobalKey<NavigatorState>();
  final util = Util();
  StreamSubscription<Uri>? linkSubscription;
  Uri? payload;

  Future<void> initDeepLinks() async {
    linkSubscription = AppLinks().uriLinkStream.listen((uri) {
      payload = uri;
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  String extractTargetUrl(String? input) {
    final uri = Uri.parse('?$input');
    return uri.queryParameters['targetUrl'] ?? '';
  }

  String extractPayload(String? input) {
    final uri = Uri.parse('?$input');
    return uri.queryParameters['payload'] ?? '';
  }

  String extractHost(String? input) {
    final uri = Uri.parse('?$input');
    return uri.queryParameters['host'] ?? '';
  }

  void routeToConsole(String host, Map<String, dynamic> payload, String inputPayload) {
    final uriParam = util.encodeJsonToUriParam(payload);
    final md5 = util.calculateMD5Hash(inputPayload);
    util.launchURL("$host/pos/cart/eft/$uriParam?md5=$md5");
  }

  void routeToConsoleFailed(String host) {
    util.launchURL("$host/pos/cart/");
  }

  void dispose() {
    linkSubscription?.cancel();
  }
}