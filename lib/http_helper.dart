import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:squadron_web_app/misc/auth_session.dart';


const String _baseUri = "https://api.squadron.party";


Future fetchStatus() async
{
  final response = await http.get(
    Uri.parse('$_baseUri/'),
  );

  if (response.statusCode != 200)
  {
    throw Exception('Request failed with status ${response.statusCode}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}


Future<bool> loginUser(String username, String password) async
{
  final response = await http.post(
    Uri.parse('$_baseUri/login'),
    body: {
      'username': username,
      'password': password,
    },
  );

  if (response.statusCode != 200)
  {
    return false;
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final token = data['access_token'] as String?;

  if (token == null || token.isEmpty) {
    return false;
  }

  AuthSession.setToken(token);
  return true;
}


Future getStatus() async
{
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (AuthSession.token != null) 'Authorization': 'Bearer ${AuthSession.token}',
  };

  final response = await http.get(
    Uri.parse('$_baseUri/user/all'),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw Exception('Request failed with status ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body) as List<dynamic>;
  return decoded.cast();
}


Stream<Map<String, dynamic>> _streamSseEvents(
  Uri uri, {
  String? bearerToken,
}) async*
{
  final client = http.Client();
  debugPrint("trying to start SSE");

  try {
    final request = http.Request('GET', uri);
    if (bearerToken != null && bearerToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $bearerToken';
    }

    final response = await client.send(request);
    if (response.statusCode != 200) {
      throw Exception('SSE connection failed (${response.statusCode})');
    }

    debugPrint("starting SSE");

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      debugPrint("event line: $trimmed");
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        final eventMap = Map<String, dynamic>.from(decoded);
        debugPrint("yield: ${eventMap['event']}");
        yield eventMap;
      }
    }
  } finally {
    client.close();
  }
}


Stream<Map<String, dynamic>> getEventStream()
{
  return _streamSseEvents(
    Uri.parse('$_baseUri/events'),
    bearerToken: AuthSession.token
  );
}

