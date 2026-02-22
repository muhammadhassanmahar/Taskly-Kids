import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'child_progress_screen.dart';

class ChildDashboard extends StatefulWidget {
  final String childEmail;

  const ChildDashboard({
    super.key,
    required this.childEmail,
  });

  @override
  State<ChildDashboard> createState() => _ChildDashboardState();
}

class _ChildDashboardState extends State<ChildDashboard> {
  List<Map<String, dynamic>> tasks = [];
  bool loading = false;
  int coins = 0;

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
          await ApiService.getTasksForChild(widget.childEmail);

      int totalCoins = 0;
      final safeKey = safeEmail(widget.childEmail);

      for (var t in data) {
        final starsMap =
            Map<String, dynamic>.from(t['stars'] ?? {});
        final starsValue = starsMap[safeKey];

        if (starsValue is int) {
          totalCoins += starsValue * 2;
        }
      }

      if (!mounted) return;

      setState(() {
        tasks = data;
        coins = totalCoins;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading tasks: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= MARK COMPLETE =================
  Future<void> markComplete(String taskId) async {
    if (taskId.isEmpty) return;

    final success = await ApiService.completeTask(
      taskId: taskId,
      childEmail: widget.childEmail,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task sent for approval ⏳"),
          backgroundColor: Colors.orange,
        ),
      );
      fetchTasks();
    }
  }

  // ================= STATUS =================
  String getStatus(Map<String, dynamic> task) {
    final safeKey = safeEmail(widget.childEmail);
    final statusMap =
        Map<String, dynamic>.from(task['status'] ?? {});
    return statusMap[safeKey] ?? "not_started";
  }

  int getStars(Map<String, dynamic> task) {
    final safeKey = safeEmail(widget.childEmail);
    final starsMap =
        Map<String, dynamic>.from(task['stars'] ?? {});
    final value = starsMap[safeKey];
    return value is int ? value : 0;
  }

  Color getCardColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green.shade700;
      case "declined":
        return Colors.red.shade700;
      case "pending":
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade900;
    }
  }

  Widget buildSubtitle(String status, int stars) {
    if (status == "approved") {
      return Row(
        children: List.generate(
          5,
          (i) => Icon(
            i < stars ? Icons.star : Icons.star_border,
            color: Colors.yellow,
            size: 18,
          ),
        ),
      );
    }

    if (status == "pending") {
      return const Text(
        "Waiting for parent approval...",
        style: TextStyle(color: Colors.white70),
      );
    }

    if (status == "declined") {
      return const Text(
        "Task was declined ❌",
        style: TextStyle(color: Colors.white70),
      );
    }

    return const SizedBox.shrink();
  }

  Widget buildTrailing(String status, String taskId) {
    switch (status) {
      case "not_started":
        return IconButton(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.white54,
          ),
          onPressed: () => markComplete(taskId),
        );
      case "pending":
        return const Icon(
          Icons.hourglass_top,
          color: Colors.white,
        );
      case "approved":
        return const Icon(
          Icons.check_circle,
          color: Colors.yellow,
        );
      case "declined":
      default:
        return const Icon(
          Icons.cancel,
          color: Colors.yellow,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Child Dashboard"),
        backgroundColor: Colors.black,
        actions: [
          // ⭐ Coins Display
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(
                  "$coins",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // 📊 Progress Button
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.yellow,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChildProgressScreen(
                    childEmail: widget.childEmail,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.yellow,
        onRefresh: fetchTasks,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ),
                )
              : tasks.isEmpty
                  ? const Center(
                      child: Text(
                        "No tasks assigned yet",
                        style:
                            TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final t = tasks[index];
                        final taskId = t['_id'].toString();
                        final taskTitle =
                            t['task']?.toString() ?? '';
                        final status = getStatus(t);
                        final stars = getStars(t);

                        return Card(
                          color: getCardColor(status),
                          elevation: 4,
                          margin:
                              const EdgeInsets.symmetric(
                                  vertical: 6),
                          child: ListTile(
                            title: Text(
                              taskTitle,
                              style: const TextStyle(
                                  color: Colors.white),
                            ),
                            subtitle:
                                buildSubtitle(status, stars),
                            trailing:
                                buildTrailing(status, taskId),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
