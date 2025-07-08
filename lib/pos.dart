import 'dart:convert';
import 'package:GL_proxy/util.dart';
import 'package:http/http.dart' as http;

class PosTerminalService {
  static const String _userAgent = 'EFT_ECR_API';
  final util = Util();

  final String host;
  final int port;

  PosTerminalService({required this.host, required this.port});

  Future<Map<String, dynamic>> sendTransaction(String payload) async {
    final uri = Uri.parse('http://$host:$port/');

    final response = await http.post(
      uri,
      headers: {
        'User-Agent': _userAgent,
        'Content-Type': "application/json; charset=utf-8",
        'Connection': 'Keep-Alive',
        'X-MD5': util.calculateMD5Hash(payload),
      },
      body: payload,
      encoding: Encoding.getByName('iso-8859-1'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process transaction: ${response.statusCode}');
    }
  }

  String getResponseStatus(Map<String, dynamic> response) => response["STATUS"];

  bool checkSuccess(Map<String, dynamic> response) => getResponseStatus(response) == "Approved";
}

