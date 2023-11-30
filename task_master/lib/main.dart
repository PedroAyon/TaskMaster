import 'package:flutter/material.dart';
import 'package:task_master/presentation/views/login_view.dart';
import 'package:task_master/presentation/views/sign_up_view.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Botón de Pánico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}

void main() {
  runApp(const Home());
}