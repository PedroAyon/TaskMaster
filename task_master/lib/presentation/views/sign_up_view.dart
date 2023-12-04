import 'package:flutter/material.dart';
import 'package:task_master/presentation/views/home_view.dart';
import 'package:task_master/presentation/views/login_view.dart';
import 'package:task_master/util/utils.dart';

import '../RepositoryManager.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController nameController = TextEditingController();
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
            "Registrarse",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        _nameTextField(),
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
          onPressed: _signUp,
          child: Container(
            width: 250,
            child: Text(
              'Regisrarse',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const SizedBox(
            width: 250,
            child: Text(
              'Iniciar sesion',
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
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        decoration: const InputDecoration(
            labelText: 'email',
            border: OutlineInputBorder(),
            hintText: 'example@domain.com'),
      ),
    );
  }

  Widget _nameTextField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          labelText: 'name',
          border: OutlineInputBorder(),
        ),
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

  _signUp() async {
    // TODO: validate form
    String? errorMessage = await RepositoryManager().authRepository.signUp(
        nameController.text, emailController.text, passwordController.text);
    if (context.mounted) {
      if (errorMessage != null) {
        snackBar(context, errorMessage);
      } else {
        snackBar(context, 'Registrado exitosamente');
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    }
  }
}
