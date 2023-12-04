import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/views/home_view.dart';
import 'package:task_master/presentation/views/login_view.dart';
import 'package:task_master/presentation/views/sign_up_view.dart';
import 'package:url_strategy/url_strategy.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _authCheck(context, const HomeView()),
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignupView(),
      },
    );
  }

  Widget _authCheck(BuildContext context, Widget view) {
    return FutureBuilder<Widget>(
      future: _loginCheck(context, view),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return snapshot.data ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<Widget> _loginCheck(BuildContext context, Widget view) async {
    bool loggedIn = await RepositoryManager().authRepository.userLoggedIn();
    if (loggedIn) {
      return view;
    } else {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return const SizedBox.shrink();
    }
  }
}

void main() {
  setPathUrlStrategy();
  runApp(const Home());
}
