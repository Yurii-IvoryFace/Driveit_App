import 'package:driveit_app/app/ui_shell.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DriveItApp extends StatelessWidget {
  const DriveItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveIt - Car Manager',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const UiShell(),
    );
  }
}
