import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeviceSessionsPage extends StatefulWidget {
  const DeviceSessionsPage({super.key});

  @override
  State<DeviceSessionsPage> createState() => _DeviceSessionsPageState();
}

class _DeviceSessionsPageState extends State<DeviceSessionsPage> {
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchDeviceSessions();
  }

  Future<void> fetchDeviceSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access');

    if (access == null) return;

    final url = Uri.parse('http://127.0.0.1:8000/api/devices/mine/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $access',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _sessions = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } else {
      print("Erreur lors de la récupération des sessions");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes sessions"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return ListTile(
            leading: const Icon(Icons.devices),
            title: Text(session['device_name'] ?? "Inconnu"),
            subtitle: Text("Expire le : ${session['expires_at']}"),
            trailing: Text(session['device_type'] ?? ""),
          );
        },
      ),
    );
  }
}
