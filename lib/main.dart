import 'package:flutter/material.dart';
import 'package:spend_sum/app/spend_sum_app.dart';
import 'package:spend_sum/app/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const SpendSumApp());
}
