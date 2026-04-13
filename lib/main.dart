import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'VM/admin_auth_viewmodel.dart';
import 'View/admin_login_page.dart';
import 'View/admin_shell.dart';

void main() {
  runApp(const NanjiAdminApp());
}

class NanjiAdminApp extends StatelessWidget {
  const NanjiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자리난지 관리자 대시보드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB5E0F5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Pretendard',
      ),
      home: ChangeNotifierProvider(
        create: (_) => AdminAuthViewModel(),
        child: const AdminAppEntry(),
      ),
    );
  }
}

class AdminAppEntry extends StatelessWidget {
  const AdminAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AdminAuthViewModel>();
    if (authVM.isAuthenticated) {
      return const AdminShell();
    }
    return const AdminLoginPage();
  }
}
