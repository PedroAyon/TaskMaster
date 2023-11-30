import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_master/presentation/views/sign_up_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("TaskMaster"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _form(),
        ),
      ),
    );
  }

  Form _form() {
    return Form(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          child: Text(
            "Inicio de Sesión",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 300,
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
                labelText: 'email',
                border: OutlineInputBorder(),
                hintText: 'example@domain.com'),
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: 300,
          child: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'password',
                border: OutlineInputBorder(),
                hintText: 'example@domain.com'),
          ),
        ),
        SizedBox(height: 32),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary),
          ),
          onPressed: () {
            // Add your authentication logic here
            // For simplicity, let's just print the email and password for now
            print('Email: ${emailController.text}');
            print('Password: ${passwordController.text}');
          },
          child: Container(
            width: 250,
            child: Text(
              'Iniciar Sesion',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupView()),
            );
          },
          child: Container(
            width: 250,
            child: Text(
              'Registarse',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 32),
      ],
    ));
  }
}
