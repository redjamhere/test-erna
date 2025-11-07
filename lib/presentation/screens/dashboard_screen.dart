import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

/// Dashboard screen showing overview of health data from smart watch
@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Smart Watch Data Dashboard')),
    );
  }
}
