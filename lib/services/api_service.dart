import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/splitmate_group_model.dart';
import '../models/expense_model.dart';

class ApiService {
  static const String baseUrl = "https://splitmate.jonasradke.dev";

  // **🔹 Login Function**
  static Future<String?> login(String email, String password) async {
    try {
      print("🔄 Sending login request to API...");
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          "auth_token",
          data["token"],
        ); // Store token correctly
        await prefs.setString("username", data["username"]);

        print("✅ Login successful, token saved: ${data["token"]}");
        return null; // No error
      } else {
        String errorMessage = jsonDecode(response.body)["message"];
        print("❌ Login failed: $errorMessage");
        return errorMessage;
      }
    } catch (e) {
      print("❌ Login API error: $e");
      return "An unexpected error occurred. Please try again.";
    }
  }

  // **🔹 Register Function**
  static Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      print("🔄 Sending registration request...");
      final response = await http.post(
        Uri.parse("$baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        print("✅ Registration successful.");
        return null; // Success
      } else {
        String errorMessage = jsonDecode(response.body)["message"];
        print("❌ Registration failed: $errorMessage");
        return errorMessage;
      }
    } catch (e) {
      print("❌ Registration API error: $e");
      return "An unexpected error occurred. Please try again.";
    }
  }

  // **🔹 Logout Function**
  static Future<void> logout() async {
    print("🚪 Logging out user...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("username");
    print("✅ User logged out successfully.");
  }

  // **🔹 Create Group & Generate Invite Code**
  static Future<String?> createGroup(
    String name,
    String icon,
    List<String> members,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/groups/create"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": name, "icon": icon, "members": members}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Group created with invite code: ${data['inviteCode']}");
        return data['inviteCode']; // ✅ Return invite code to show in UI
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // **🔹 Join Group with Invite Code**
  static Future<String?> joinGroup(String inviteCode) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/groups/join"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inviteCode": inviteCode}),
      );

      if (response.statusCode == 200) {
        return null; // ✅ Success
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // **🔹 Fetch Groups**
  static Future<List<SplitmateGroupModel>> fetchGroups() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        print("❌ No authentication token found.");
        throw Exception("User not authenticated");
      }

      print("🔄 Fetching groups with token: $token");

      final response = await http.get(
        Uri.parse("$baseUrl/groups"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("✅ Groups received: ${data.length}");
        return data.map((json) => SplitmateGroupModel.fromJson(json)).toList();
      } else {
        print("❌ Failed to load groups. Status: ${response.statusCode}");
        throw Exception("Failed to load groups");
      }
    } catch (e) {
      print("❌ Error fetching groups: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  static Future<List<ExpenseModel>> fetchExpenses(String groupId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/groups/$groupId/expenses"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ExpenseModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch expenses");
      }
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  static Future<String?> addExpense(
    String groupId,
    String description,
    double amount,
    String paidBy,
    List<String> sharedBy,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/groups/$groupId/expenses"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "description": description,
          "amount": amount,
          "paidBy": paidBy,
          "sharedBy": sharedBy,
        }),
      );

      if (response.statusCode == 201) {
        return null; // Success
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // Update Expense
  static Future<String?> updateExpense(
    String groupId,
    String expenseId,
    String description,
    double amount,
    String paidBy,
    List<String> sharedBy,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.put(
        Uri.parse("$baseUrl/groups/$groupId/expenses/$expenseId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "description": description,
          "amount": amount,
          "paidBy": paidBy,
          "sharedBy": sharedBy,
        }),
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // **🔹 Delete Expense**
  static Future<String?> deleteExpense(String groupId, String expenseId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) throw Exception("User not authenticated");

      final response = await http.delete(
        Uri.parse("$baseUrl/groups/$groupId/expenses/$expenseId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  static Future<List<String>> getGroupMembers(String groupId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        throw Exception("User not authenticated");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/groups/$groupId/members"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        throw Exception("Failed to fetch group members");
      }
    } catch (e) {
      print("❌ Error fetching group members: $e");
      return [];
    }
  }
}
