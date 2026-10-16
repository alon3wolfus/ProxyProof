import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Api {
  Api._();
  static final Api instance = Api._();
  static const baseUrl = String.fromEnvironment('PROXYPROOF_API', defaultValue: 'http://127.0.0.1:8787');
  final client = http.Client();
  String? token;
  Map<String, dynamic>? user;
  Future<String>? _deviceFuture;

  Future<String> get deviceId => _deviceFuture ??= _loadDevice();
  Future<String> _loadDevice() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_id');
    if (id == null) { id = const Uuid().v4(); await prefs.setString('device_id', id); }
    return id;
  }

  Future<Map<String, dynamic>> request(String method, String path, {Map<String, dynamic>? data, bool csv = false}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'content-type':'application/json', if (token != null) 'authorization':'Bearer $token'};
    late http.Response response;
    if (method == 'GET') response = await client.get(uri, headers: headers).timeout(const Duration(seconds: 8));
    else response = await client.post(uri, headers: headers, body: jsonEncode(data ?? const {})).timeout(const Duration(seconds: 8));
    dynamic result;
    try { result = jsonDecode(response.body); } catch (_) { result = {'body':response.body}; }
    if(response.statusCode < 200 || response.statusCode >= 300) throw Exception(result is Map ? result['error'] ?? 'Request failed (${response.statusCode})' : 'Request failed');
    return result is Map<String,dynamic> ? result : <String,dynamic>{'body':result};
  }

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    final result = await request('POST','/auth/login',data:{'email':email,'password':password,'role':role,'deviceId':await deviceId});
    token = result['token'] as String; user = Map<String,dynamic>.from(result['user'] as Map); return user!;
  }
}
