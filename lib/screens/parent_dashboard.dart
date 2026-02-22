import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'parent_progress_screen.dart';

class ParentDashboard extends StatefulWidget {
  final String parentEmail;

  const ParentDashboard({
    super.key,
    required this.parentEmail,
  });

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final taskController = TextEditingController();
  final emailController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];
  bool loading = false;

  String safeEmail(String email) => email.replaceAll('.', '_');

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // ================= FETCH TASKS =================
  Future<void> fetchTasks() async {
    setState(() => loading = true);

    try {
      final data =
          await ApiService.getTasksForParent(widget.parentEmail);

      if (!mounted) return;

      setState(() {
        tasks = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // ================= SHOW ADD TASK DIALOG =================
  void showAddTaskDialog() {
    taskController.clear();
    emailController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Add New Task",
          style: TextStyle(color: Colors.yellow),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Child Emails (comma separated)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: taskController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Task"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
            ),
            onPressed: () async {
              await addTask();
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  // ================= ADD TASK =================
  Future<void> addTask() async {
    final task = taskController.text.trim();
    final emails = emailController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (task.isEmpty || emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter task and child email"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok = await ApiService.addTask(
      task: task,
      parentEmail: widget.parentEmail,
      children: emails,
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (ok) {
      taskController.clear();
      emailController.clear();
      fetchTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task Added Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to Add Task"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= DELETE TASK =================
  Future<void> deleteTask(String taskId) async {
    final ok = await ApiService.deleteTask(taskId);

    if (!mounted) return;

    if (ok) {
      fetchTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Deleted")),
      );
    }
  }

  // ================= EDIT TASK =================
  Future<void> editTask(Map<String, dynamic> taskData) async {
    taskController.text = taskData['task']?.toString() ?? '';
    emailController.text =
        (taskData['children'] as List<dynamic>)
            .map((e) => e.toString())
            .join(',');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Edit Task",
          style: TextStyle(color: Colors.yellow),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Child Emails (comma separated)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: taskController,
              style: const TextStyle(color: Colors.white),
              decoration: _input("Task"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
            ),
            onPressed: () async {
              final ok = await ApiService.updateTask(
                taskId: taskData['_id'].toString(),
                task: taskController.text.trim(),
                children: emailController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList(),
              );

              if (!mounted) return;

              Navigator.pop(context);

              if (ok) {
                fetchTasks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task Updated")),
                );
              }
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  // ================= APPROVE / DECLINE =================
  Future<void> approveTask(String taskId, String childEmail) async {
    await ApiService.approveTask(
      taskId: taskId,
      childEmail: childEmail,
    );
    fetchTasks();
  }

  Future<void> declineTask(String taskId, String childEmail) async {
    await ApiService.declineTask(
      taskId: taskId,
      childEmail: childEmail,
    );
    fetchTasks();
  }

  int countStatus(Map<String, dynamic> status, String value) =>
      status.values.where((v) => v == value).length;

  @override
  void dispose() {
    taskController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart,
                color: Colors.yellow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ParentProgressScreen(
                    parentEmail: widget.parentEmail,
                  ),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Colors.yellow),
            )
          : tasks.isEmpty
              ? const Center(
                  child: Text(
                    "No tasks yet",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    final status =
                        Map<String, dynamic>.from(
                            t['status'] ?? {});
                    final children =
                        List<String>.from(
                            t['children'] ?? []);

                    return Card(
                      color: Colors.grey.shade900,
                      margin:
                          const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        collapsedIconColor: Colors.yellow,
                        iconColor: Colors.yellow,
                        title: Text(
                          t['task']?.toString() ?? '',
                          style: const TextStyle(
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          "✅ ${countStatus(status, "approved")}   "
                          "⏳ ${countStatus(status, "pending")}   "
                          "❌ ${countStatus(status, "declined")}",
                          style: const TextStyle(
                              color: Colors.yellow),
                        ),
                        children: [
                          Column(
                            children: children.map((child) {
                              final key = safeEmail(child);
                              final childStatus =
                                  status[key];

                              return ListTile(
                                title: Text(
                                  child,
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                trailing: childStatus ==
                                        "pending"
                                    ? Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.check,
                                                color:
                                                    Colors.green),
                                            onPressed: () =>
                                                approveTask(
                                                    t['_id']
                                                        .toString(),
                                                    child),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.close,
                                                color:
                                                    Colors.red),
                                            onPressed: () =>
                                                declineTask(
                                                    t['_id']
                                                        .toString(),
                                                    child),
                                          ),
                                        ],
                                      )
                                    : Icon(
                                        childStatus ==
                                                "approved"
                                            ? Icons
                                                .check_circle
                                            : childStatus ==
                                                    "declined"
                                                ? Icons.cancel
                                                : Icons
                                                    .circle_outlined,
                                        color: childStatus ==
                                                "approved"
                                            ? Colors.green
                                            : childStatus ==
                                                    "declined"
                                                ? Colors.red
                                                : Colors
                                                    .white54,
                                      ),
                              );
                            }).toList(),
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.edit,
                                    color:
                                        Colors.yellow),
                                onPressed: () =>
                                    editTask(t),
                              ),
                              IconButton(
                                icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    deleteTask(
                                        t['_id']
                                            .toString()),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  InputDecoration _input(String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      );
}
