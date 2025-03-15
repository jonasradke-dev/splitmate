import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitmate/models/splitmate_group_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SplitmateGroupModel> groupList = [];

  @override
  void initState() {
    super.initState();
    _getGroupList();
  }

  void _getGroupList() {
    setState(() {
      groupList = SplitmateGroupModel.getGroupList();
    });
  }

  void _showCreateGroupDialog() {
    String groupName = "";
    String groupIcon = "💶"; // Default emoji
    List<String> selectedMembers = [];
    TextEditingController memberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(
                0xFF1A1A1A,
              ), // Slightly brighter black
              title: const Text(
                "Create New Group",
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Group Name Input
                    TextField(
                      onChanged: (value) => groupName = value,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Group Name",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Emoji Picker for Group Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Choose Icon:",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () async {
                            String? emoji = await _showEmojiPicker(context);
                            if (emoji != null) {
                              setState(() {
                                groupIcon = emoji;
                              });
                            }
                          },
                          child: Text(
                            groupIcon,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Manually Add Group Members
                    TextField(
                      controller: memberController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Add Member",
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purpleAccent,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.purpleAccent,
                          ),
                          onPressed: () {
                            if (memberController.text.isNotEmpty) {
                              setState(() {
                                selectedMembers.add(memberController.text);
                                memberController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display Selected Members
                    if (selectedMembers.isNotEmpty)
                      Wrap(
                        spacing: 5,
                        children:
                            selectedMembers
                                .map(
                                  (member) => Chip(
                                    backgroundColor: Colors.purpleAccent
                                        .withOpacity(0.2),
                                    label: Text(
                                      member,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        selectedMembers.remove(member);
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.purpleAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (groupName.isNotEmpty && selectedMembers.isNotEmpty) {
                      _addNewGroup(groupName, selectedMembers, groupIcon);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showEmojiPicker(BuildContext context) async {
    List<String> emojis = [
      "😀",
      "🎉",
      "🔥",
      "💰",
      "🎈",
      "🏆",
      "📌",
      "🎨",
      "🎵",
      "💡",
    ];

    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            "Choose an Emoji",
            style: TextStyle(color: Colors.white),
          ),
          content: Wrap(
            spacing: 10,
            children:
                emojis
                    .map(
                      (emoji) => GestureDetector(
                        onTap: () {
                          Navigator.pop(context, emoji);
                        },
                        child: Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.purpleAccent,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }

  void _addNewGroup(String name, List<String> members, String icon) {
    setState(() {
      groupList.add(
        SplitmateGroupModel(
          GroupName: name,
          GroupId: DateTime.now().millisecondsSinceEpoch.toString(),
          GroupMembers: members,
          GroupIcon: icon,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SplitMate', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: groupList.length,
        itemBuilder: (context, index) {
          final group = groupList[index];
          return Card(
            color: Colors.white10, // Transparent background for groups
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                print('Tapped on ${group.GroupName}');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
