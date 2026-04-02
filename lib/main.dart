import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'VM/dashboard_viewmodel.dart';
import 'View/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: MaterialApp(
        title: 'Nanji Parking Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}