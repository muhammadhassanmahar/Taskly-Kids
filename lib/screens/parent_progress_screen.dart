import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ParentProgressScreen extends StatefulWidget {
  final String parentEmail;

  const ParentProgressScreen({
    super.key,
    required this.parentEmail,
  });

  @override
  State<ParentProgressScreen> createState() =>
      _ParentProgressScreenState();
}

class _ParentProgressScreenState
    extends State<ParentProgressScreen> {
  List<Map<String, dynamic>> childrenProgress = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    setState(() => loading = true);

    final data =
        await ApiService.getParentProgress(widget.parentEmail);

    if (!mounted) return;

    setState(() {
      childrenProgress = data;
      loading = false;
    });
  }

  Widget buildProgressBar(int percentage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: (percentage.clamp(0, 100)) / 100,
        minHeight: 14,
        backgroundColor: Colors.grey.shade800,
        valueColor:
            const AlwaysStoppedAnimation(Colors.yellow),
      ),
    );
  }

  Widget statRow(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white70)),
        Text(value.toString(),
            style:
                const TextStyle(color: Colors.yellow)),
      ],
    );
  }

  Widget buildChildCard(Map<String, dynamic> child) {
    final email = child['childEmail'] ?? "Unknown";
    final percentage = child['progressPercentage'] ?? 0;
    final approved = child['approved'] ?? 0;
    final pending = child['pending'] ?? 0;
    final declined = child['declined'] ?? 0;
    final coins = child['coins'] ?? 0;
    final points = child['progressPoints'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // 👤 Child Name
          Text(
            email,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // 📊 Progress %
          Text(
            "$percentage%",
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          buildProgressBar(percentage),

          const SizedBox(height: 14),

          // 📈 Stats
          statRow("Approved", approved),
          const SizedBox(height: 4),
          statRow("Pending", pending),
          const SizedBox(height: 4),
          statRow("Declined", declined),

          const Divider(
            color: Colors.white24,
            height: 20,
          ),

          // ⭐ Coins & Points
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.yellow),
                  const SizedBox(width: 6),
                  Text(
                    "Coins: $coins",
                    style: const TextStyle(
                        color: Colors.white),
                  ),
                ],
              ),
              Text(
                "Points: $points",
                style: const TextStyle(
                    color: Colors.white),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Children Progress"),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        color: Colors.yellow,
        onRefresh: fetchProgress,
        child: loading
            ? const Center(
                child:
                    CircularProgressIndicator(
                        color: Colors.yellow),
              )
            : childrenProgress.isEmpty
                ? const Center(
                    child: Text(
                      "No children progress found",
                      style: TextStyle(
                          color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.all(16),
                    itemCount:
                        childrenProgress.length,
                    itemBuilder: (context, index) =>
                        buildChildCard(
                            childrenProgress[index]),
                  ),
      ),
    );
  }
}
