import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:task_master/presentation/RepositoryManager.dart';
import 'package:task_master/presentation/views/board_view.dart';
import 'package:task_master/presentation/views/home_view.dart';
import 'package:task_master/presentation/views/login_view.dart';
import 'package:task_master/presentation/views/sign_up_view.dart';
import 'package:task_master/presentation/views/task_assignment_view.dart';
import 'package:task_master/presentation/views/task_view.dart';
import 'package:url_strategy/url_strategy.dart';

import 'domain/model/board.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppFlowyEditorLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/board') {
          final Map<String, String> params =
              settings.arguments as Map<String, String>;
          final int? boardId =
              params['id'] != null ? int.parse(params['id']!) : null;
          return MaterialPageRoute(
              builder: (context) {
                return const BoardView();
              },
              settings: RouteSettings(
                name: '/board',
                arguments: boardId,
              ));
        }
        return null;
      },
      routes: {
        '/': (context) => _authCheck(context, const HomeView()),
        '/login': (context) => const LoginView(),
        '/signup': (context) => const SignupView(),
        '/board': (context) => const BoardView(),
        '/task': (context) => const TaskView(),
        '/task_assignment': (context) => const TaskAssignmentView(),
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
