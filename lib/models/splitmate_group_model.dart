class SplitmateGroupModel {
  String GroupName;
  String GroupId;
  List<String> GroupMembers;
  String GroupIcon;

  SplitmateGroupModel({
    required this.GroupName,
    required this.GroupId,
    required this.GroupMembers,
    required this.GroupIcon,
  });

  static List<SplitmateGroupModel> getGroupList() {
    return [
      SplitmateGroupModel(
        GroupName: 'Group 1',
        GroupId: '1',
        GroupMembers: ['User 1', 'User 2', 'User 3'],
        GroupIcon: 'icon1',
      ),
      SplitmateGroupModel(
        GroupName: 'Group 2',
        GroupId: '2',
        GroupMembers: ['User 1', 'User 2', 'User 3'],
        GroupIcon: 'icon2',
      ),
      SplitmateGroupModel(
        GroupName: 'Group 3',
        GroupId: '3',
        GroupMembers: ['User 1', 'User 2', 'User 3'],
        GroupIcon: 'icon3',
      ),
    ];
  }
}
