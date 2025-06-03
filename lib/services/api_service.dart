import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';





class ApiService {
  // ✅ Use 10.0.2.2 instead of 127.0.0.1 for Android Emulator
  static final String baseUrl = "http://10.0.2.2:8000";

  // LOGIN
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login/');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("Login response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', data['access']);
      await prefs.setString('refresh', data['refresh']);
      await prefs.setString('user', jsonEncode(data['user']));
      return true;
    } else {
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
    await prefs.remove('user');
  }

  // GET DASHBOARD
  static Future<Map<String, dynamic>?> getDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access');
    if (access == null) return null;

    final url = Uri.parse('$baseUrl/api/dashboard/');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $access",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // SIGNUP
  static Future<bool> signup(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register/');

    final body = jsonEncode({
      "username": username,
      "email": email,
      "password": password,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    print("Signup response: ${response.statusCode} ${response.body}");

    return response.statusCode == 201;
  }

  // RESET PASSWORD
  static Future<bool> resetPassword(String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/auth/reset-password/');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "new_password": newPassword,
      }),
    );

    print("Reset Password response: ${response.statusCode} ${response.body}");

    return response.statusCode == 200;
  }

  // DEVICE DETAILS
  static Future<Map<String, String>> getDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'device_name': androidInfo.model ?? 'Android',
        'device_type': 'Mobile',
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'device_name': iosInfo.utsname.machine ?? 'iPhone',
        'device_type': 'Mobile',
      };
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return {
        'device_name': windowsInfo.computerName ?? 'Windows PC',
        'device_type': 'Desktop',
      };
    }

    return {
      'device_name': 'Unknown',
      'device_type': 'Other',
    };
  }

  // CREATE DEVICE SESSION
  static Future<void> createDeviceSession() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access');
    if (access == null) return;

    final details = await getDeviceDetails();
    final url = Uri.parse('$baseUrl/api/devices/create/');
    final expires = DateTime.now().add(Duration(days: 2));

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "device_name": details['device_name'],
        "device_type": details['device_type'],
        "expires_at": expires.toUtc().toIso8601String(),
      }),
    );

    print("Device Session response: ${response.statusCode} ${response.body}");

    if (response.statusCode == 201) {
      print("✅ DeviceSession created successfully");
    } else {
      print("❌ Error creating DeviceSession");
    }
  }
  static Future<String> detectColor(File imageFile) async {
    final url = Uri.parse('$baseUrl/api/color-detect/');

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['color'] ?? 'Unknown';
    } else {
      print('❌ Failed to detect color: ${response.statusCode} ${response.body}');
      throw Exception('Color detection failed');
    }
  }

}


