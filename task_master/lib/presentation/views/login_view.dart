import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_master/data/repository/auth_repository_impl.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/views/home_view.dart';
import 'package:task_master/presentation/views/sign_up_view.dart';

import '../../util/utils.dart';

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
        SizedBox(
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
        const SizedBox(height: 16),
        _emailTextField(),
        const SizedBox(height: 16),
        _passwordTextField(),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                Theme.of(context).colorScheme.primary),
          ),
          onPressed: _logIn,
          child: SizedBox(
            width: 250,
            child: Text(
              'Iniciar Sesion',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const SizedBox(
            width: 250,
            child: Text(
              'Registarse',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ));
  }

  Widget _emailTextField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
            labelText: 'email',
            border: OutlineInputBorder(),
            hintText: 'example@domain.com'),
      ),
    );
  }

  Widget _passwordTextField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
            labelText: 'password', border: OutlineInputBorder()),
      ),
    );
  }

  void _logIn() async {
    // TODO: validate form
    String? errorMessage = await RepositoryManager()
        .authRepository
        .logIn(emailController.text, passwordController.text);
    if (context.mounted) {
      if (errorMessage != null) {
        snackBar(context, errorMessage);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    }
  }
}
