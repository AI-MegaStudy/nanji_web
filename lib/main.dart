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
        title: '한강공원 주차장 예측',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E5AC7),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        ),
        debugShowCheckedModeBanner: false,
        home: const DashboardScreen(),
      ),
    );
  }
}