import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service to interact with FastAPI backend
class ApiService {
  // =================== BASE URL ===================
  /// Web (Chrome): http://localhost:8000
  /// Android Emulator: http://10.0.2.2:8000
  /// Physical device: Use your PC IP (e.g., http://192.168.1.5:8000)

  static const String baseUrl = "http://localhost:8000";

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // =================== GENERIC GET ===================
  static Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      debugPrint(
          "GET Error ${response.statusCode}: ${response.body}");
      return null;
    } catch (e) {
      debugPrint("GET Exception: $e");
      return null;
    }
  }

  // =================== GENERIC POST ===================
  static Future<bool> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      debugPrint(
          "POST Error ${response.statusCode}: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("POST Exception: $e");
      return false;
    }
  }

  // =================== GENERIC PUT ===================
  static Future<bool> _put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      debugPrint(
          "PUT Error ${response.statusCode}: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("PUT Exception: $e");
      return false;
    }
  }

  // =================== GENERIC DELETE ===================
  static Future<bool> _delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return true;
      }

      debugPrint(
          "DELETE Error ${response.statusCode}: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("DELETE Exception: $e");
      return false;
    }
  }

  // ======================================================
  // =================== TASK APIs ========================
  // ======================================================

  static Future<bool> addTask({
    required String task,
    required String parentEmail,
    required List<String> children,
  }) async {
    return _post("/tasks/add", {
      "task": task,
      "parentEmail": parentEmail,
      "children": children,
    });
  }

  static Future<List<Map<String, dynamic>>>
      getTasksForParent(String parentEmail) async {
    final data = await _get("/tasks/parent/$parentEmail");
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>>
      getTasksForChild(String childEmail) async {
    final data = await _get("/tasks/child/$childEmail");
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  static Future<bool> completeTask({
    required String taskId,
    required String childEmail,
  }) async {
    return _post("/tasks/complete", {
      "task_id": taskId,
      "childEmail": childEmail,
    });
  }

  static Future<bool> approveTask({
    required String taskId,
    required String childEmail,
    int stars = 5,
  }) async {
    return _post("/tasks/approve", {
      "task_id": taskId,
      "childEmail": childEmail,
      "stars": stars,
    });
  }

  static Future<bool> declineTask({
    required String taskId,
    required String childEmail,
  }) async {
    return _post("/tasks/decline", {
      "task_id": taskId,
      "childEmail": childEmail,
    });
  }

  static Future<bool> updateTask({
    required String taskId,
    String? task,
    List<String>? children,
  }) async {
    final body = {
      if (task != null) "task": task,
      if (children != null) "children": children,
    };

    return _put("/tasks/update/$taskId", body);
  }

  static Future<bool> deleteTask(String taskId) async {
    return _delete("/tasks/delete/$taskId");
  }

  // ======================================================
  // =================== PROGRESS APIs ====================
  // ======================================================

  static Future<Map<String, dynamic>?> getChildProgress(
      String childEmail) async {
    final data = await _get("/progress/child/$childEmail");
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>>
      getParentProgress(String parentEmail) async {
    final data = await _get("/progress/parent/$parentEmail");
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }
}
