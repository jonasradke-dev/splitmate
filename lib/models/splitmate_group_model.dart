class SplitmateGroupModel {
  final String GroupId;
  final String GroupName;
  final List<String> GroupMembers;
  final String GroupIcon;

  SplitmateGroupModel({
    required this.GroupId,
    required this.GroupName,
    required this.GroupMembers,
    required this.GroupIcon,
  });

  factory SplitmateGroupModel.fromJson(Map<String, dynamic> json) {
    return SplitmateGroupModel(
      GroupId: json['_id']?.toString() ?? "",
      GroupName: json['name'] ?? "Unknown Group",
      GroupMembers:
          (json['members'] as List<dynamic>?)
              ?.map(
                (member) => member['username']?.toString() ?? "Unknown User",
              )
              .toList() ??
          [],
      GroupIcon: json['icon'] ?? "❓",
    );
  }
}
