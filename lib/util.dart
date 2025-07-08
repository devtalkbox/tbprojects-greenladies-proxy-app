import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {
  Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String encodeJsonToUriParam(Map<String, dynamic> payload) {
    final json = jsonEncode(payload);
    return Uri.encodeComponent(json);
  }

  String calculateMD5Hash(String input) {
    final Uint8List inputBytes = utf8.encode(input);
    final hash = md5.convert(inputBytes);
    return hash.toString();
  }
}

