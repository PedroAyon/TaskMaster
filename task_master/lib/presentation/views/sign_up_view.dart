import 'package:flutter/material.dart';

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
        Container(
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
            print('Name: ${nameController.text}');
            print('Email: ${emailController.text}');
            print('Password: ${passwordController.text}');
          },
          child: Container(
            width: 250,
            child: Text(
              'Regisrarse',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 250,
            child: Text(
              'Iniciar sesion',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 32),
      ],
    ));
  }
}
