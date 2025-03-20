class ExpenseModel {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> sharedBy;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.sharedBy,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json["_id"]?.toString() ?? "",
      description: json["description"] ?? "No description",
      amount: (json["amount"] as num).toDouble(),
      paidBy: json["paidBy"]["username"] ?? "Unknown",
      sharedBy:
          (json["sharedBy"] as List<dynamic>)
              .map((user) => user["username"].toString())
              .toList(),
    );
  }
}
