import 'package:flutter/material.dart';

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png', width: 150),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/login',
                arguments: 'parent',
              );
            },
            child: const Text("Login as Parent"),
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/login',
                arguments: 'child',
              );
            },
            child: const Text("Login as Child"),
          ),
        ],
      ),
    );
  }
}
