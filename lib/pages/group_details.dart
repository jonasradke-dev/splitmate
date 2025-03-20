import 'package:flutter/material.dart';
import 'package:splitmate/services/api_service.dart';
import 'package:splitmate/models/expense_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupDetailsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  List<ExpenseModel> expenses = [];
  List<String> groupMembers = [];
  bool isLoading = true;
  String? currentUser;
  Map<String, double> balances = {};
  double netBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchExpenses();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = prefs.getString("username") ?? "Unknown";
    });
  }

  Future<void> _fetchExpenses() async {
    List<ExpenseModel> fetchedExpenses = await ApiService.fetchExpenses(
      widget.groupId,
    );
    List<String> members = await ApiService.getGroupMembers(widget.groupId);

    _calculateBalances(fetchedExpenses);

    setState(() {
      expenses = fetchedExpenses;
      groupMembers = members;
      isLoading = false;
    });
  }

  void _calculateBalances(List<ExpenseModel> fetchedExpenses) {
    Map<String, double> newBalances = {};

    for (var expense in fetchedExpenses) {
      if (!newBalances.containsKey(expense.paidBy)) {
        newBalances[expense.paidBy] = 0.0;
      }
      newBalances[expense.paidBy] =
          (newBalances[expense.paidBy] ?? 0.0) + expense.amount;

      for (var person in expense.sharedBy) {
        if (!newBalances.containsKey(person)) {
          newBalances[person] = 0.0;
        }
        newBalances[person] =
            (newBalances[person] ?? 0.0) -
            expense.amount / expense.sharedBy.length;
      }
    }

    setState(() {
      balances = newBalances;
      netBalance = balances[currentUser] ?? 0.0;
    });
  }

  void _showAddExpenseDialog({ExpenseModel? expense}) {
    String description = expense?.description ?? "";
    double amount = expense?.amount ?? 0.0;
    String? paidBy = expense?.paidBy;
    List<String> selectedMembers = expense?.sharedBy ?? [];
    bool isEditing = expense != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? "Edit Expense" : "Add Expense"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: TextEditingController(text: description),
                      onChanged: (value) => description = value,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: TextEditingController(
                        text: amount.toString(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged:
                          (value) => amount = double.tryParse(value) ?? 0.0,
                      decoration: const InputDecoration(
                        labelText: "Amount (€)",
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: paidBy,
                      hint: const Text("Who paid?"),
                      items:
                          groupMembers.map((member) {
                            return DropdownMenuItem<String>(
                              value: member,
                              child: Text(member),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          paidBy = value!;
                          selectedMembers.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("Who is included?"),
                    Wrap(
                      spacing: 5,
                      children:
                          groupMembers.map((member) {
                            return ChoiceChip(
                              label: Text(member),
                              selected: selectedMembers.contains(member),
                              selectedColor: Colors.purpleAccent.withOpacity(
                                0.5,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedMembers.add(member);
                                  } else {
                                    selectedMembers.remove(member);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (description.isEmpty ||
                        amount <= 0 ||
                        paidBy == null ||
                        selectedMembers.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "All fields are required!",
                        gravity: ToastGravity.BOTTOM,
                      );
                      return;
                    }

                    String? error;
                    if (isEditing) {
                      error = await ApiService.updateExpense(
                        widget.groupId,
                        expense.id,
                        description,
                        amount,
                        paidBy!,
                        selectedMembers,
                      );
                    } else {
                      error = await ApiService.addExpense(
                        widget.groupId,
                        description,
                        amount,
                        paidBy!,
                        selectedMembers,
                      );
                    }

                    if (error == null) {
                      Navigator.pop(context);
                      _fetchExpenses();
                      Fluttertoast.showToast(
                        msg: isEditing ? "Expense updated!" : "Expense added!",
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Error: $error",
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
                  child: Text(isEditing ? "Save" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          bottom: const TabBar(
            tabs: [Tab(text: "Expenses"), Tab(text: "Balances")],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Card(
                          color: Colors.white10,
                          child: ListTile(
                            title: Text(
                              expense.description,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Paid by ${expense.paidBy}, split with ${expense.sharedBy.join(", ")}",
                            ),
                            trailing: Text(
                              "€${expense.amount.toStringAsFixed(2)}",
                            ),
                            onTap:
                                () => _showAddExpenseDialog(expense: expense),
                          ),
                        );
                      },
                    ),
                    Column(
                      children: [
                        ListTile(
                          title: const Text("Total Balance"),
                          subtitle: Text(
                            "€${netBalance.toStringAsFixed(2)}",
                            style: TextStyle(
                              color:
                                  netBalance >= 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children:
                                balances.entries.map((entry) {
                                  return ListTile(
                                    title: Text(entry.key),
                                    trailing: Text(
                                      "€${entry.value.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color:
                                            entry.value >= 0
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "addExpenseFAB",
          onPressed: _showAddExpenseDialog,
          backgroundColor: Colors.purpleAccent,
          label: const Text("Add Expense"),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
