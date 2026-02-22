import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChildProgressScreen extends StatefulWidget {
  final String childEmail;

  const ChildProgressScreen({
    super.key,
    required this.childEmail,
  });

  @override
  State<ChildProgressScreen> createState() =>
      _ChildProgressScreenState();
}

class _ChildProgressScreenState
    extends State<ChildProgressScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? progress;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProgress();
  }

  Future<void> fetchProgress() async {
    setState(() => loading = true);

    final data =
        await ApiService.getChildProgress(widget.childEmail);

    if (!mounted) return;

    setState(() {
      progress = data;
      loading = false;
    });
  }

  Widget buildProgressBar(int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$percentage%",
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: LinearProgressIndicator(
            value: (percentage.clamp(0, 100)) / 100,
            minHeight: 16,
            backgroundColor: Colors.grey.shade800,
            valueColor:
                const AlwaysStoppedAnimation(Colors.yellow),
          ),
        ),
      ],
    );
  }

  Widget infoCard(String title, int value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage =
        progress?['progressPercentage'] ?? 0;
    final approved = progress?['approved'] ?? 0;
    final pending = progress?['pending'] ?? 0;
    final declined = progress?['declined'] ?? 0;
    final totalTasks = progress?['totalTasks'] ?? 0;
    final coins = progress?['coins'] ?? 0;
    final points = progress?['progressPoints'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Progress"),
        backgroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        color: Colors.yellow,
        onRefresh: fetchProgress,
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: Colors.yellow),
              )
            : progress == null
                ? const Center(
                    child: Text(
                      "No data available",
                      style:
                          TextStyle(color: Colors.white54),
                    ),
                  )
                : SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // 🔥 Progress Section
                        buildProgressBar(percentage),

                        const SizedBox(height: 35),

                        // 📊 Stats Section
                        Row(
                          children: [
                            infoCard("Approved", approved),
                            const SizedBox(width: 12),
                            infoCard("Pending", pending),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            infoCard("Declined", declined),
                            const SizedBox(width: 12),
                            infoCard("Total Tasks", totalTasks),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // 💰 Coins & Points Card
                        Container(
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color:
                                              Colors.yellow),
                                      const SizedBox(
                                          width: 8),
                                      Text(
                                        "Coins: $coins",
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Points: $points",
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Keep completing tasks to earn more rewards 🚀",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
