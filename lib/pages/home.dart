import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitmate/services/api_service.dart';
import 'package:splitmate/models/splitmate_group_model.dart';
import 'login_page.dart';
import 'group_details.dart'; // ✅ Import Group Details Page
import 'package:flutter/services.dart'; // ✅ Import Clipboard
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Import FlutterToast

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  List<SplitmateGroupModel> groupList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("auth_token");
    String? storedUsername = prefs.getString("username");

    if (token == null) {
      _logout();
      return;
    }

    setState(() {
      username = storedUsername ?? "User";
    });

    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<SplitmateGroupModel> fetchedGroups = await ApiService.fetchGroups();
      setState(() {
        groupList = fetchedGroups;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load groups. Please try again.";
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("username");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showCreateGroupDialog() {
    String groupName = "";
    String groupIcon = "💰";
    List<String> selectedMembers = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Group"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => groupName = value,
                decoration: const InputDecoration(labelText: "Group Name"),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Add Members (comma separated)",
                ),
                onChanged: (value) {
                  selectedMembers =
                      value.split(',').map((e) => e.trim()).toList();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupName.isEmpty || selectedMembers.isEmpty) return;

                String? inviteCode = await ApiService.createGroup(
                  groupName,
                  groupIcon,
                  selectedMembers,
                );
                if (inviteCode != null) {
                  Navigator.pop(context);
                  _fetchGroups();
                  _showInviteCodeDialog(inviteCode);
                } else {
                  print("Error creating group.");
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _showInviteCodeDialog(String inviteCode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Invite Code"),
          content: GestureDetector(
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: inviteCode),
              ); // ✅ Copy to clipboard
              Fluttertoast.showToast(
                // ✅ Show confirmation
                msg: "Invite Code Copied!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showJoinGroupDialog() {
    String inviteCode = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Group"),
          content: TextField(
            onChanged: (value) => inviteCode = value,
            decoration: const InputDecoration(labelText: "Enter Invite Code"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String? error = await ApiService.joinGroup(inviteCode);
                if (error == null) {
                  Navigator.pop(context);
                  _fetchGroups();
                } else {
                  print("Error joining group: $error");
                }
              },
              child: const Text("Join"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Welcome, $username",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchGroups,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchGroups,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              )
              : groupList.isEmpty
              ? const Center(
                child: Text(
                  "No groups found",
                  style: TextStyle(color: Colors.white70),
                ),
              )
              : ListView.builder(
                itemCount: groupList.length,
                itemBuilder: (context, index) {
                  final group = groupList[index];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: ListTile(
                      leading: Text(
                        group.GroupIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        group.GroupName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Members: ${group.GroupMembers.join(', ')}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        // ✅ Navigate to Group Details Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => GroupDetailsPage(
                                  groupId: group.GroupId,
                                  groupName: group.GroupName,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showJoinGroupDialog,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showCreateGroupDialog,
            backgroundColor: Colors.purpleAccent,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
