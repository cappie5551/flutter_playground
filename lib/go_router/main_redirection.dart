import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class LoginInfo extends ChangeNotifier {
  /// The username of login.
  String get userName => _userName;
  String _userName = '';

  /// Whether a user has logged in.
  bool get loggedIn => _userName.isNotEmpty;

  /// Logs in a user.
  void login(String userName) {
    _userName = userName;
    notifyListeners();
  }

  /// Logs out the current user
  void logout() {
    _userName = '';
    notifyListeners();
  }
}

void main() => runApp(App());

/// The main app.
class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final LoginInfo _loginInfo = LoginInfo();

  /// The title of the app.
  static const String title = 'GoRouter Example: Redirection';

  // add the login info into the tree as app state that can change over time
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<LoginInfo>.value(
        value: _loginInfo,
        child: MaterialApp.router(
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
          title: title,
          debugShowCheckedModeBanner: false,
        ),
      );

  late final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      )
    ],

    // redirect to the login page if the user is not logged in
    redirect: (GoRouterState state) {
      // if the user is not logged in, they need to login
      final bool loggedIn = _loginInfo.loggedIn;
      final bool loggingIn = state.subloc == '/login';
      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      // if the user is logged in but still on the login page, send them to the home page
      if (loggingIn) {
        return '/';
      }

      // no need to redirect at all
      return null;
    },

    // changes on the listenable will cause the router to refresh it's route
    refreshListenable: _loginInfo,
  );
}

/// The login screen.
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // log a user in, letting all the listeners know
                context.read<LoginInfo>().login('test-user');

                // router will automatically redirect from .login to / using refreshListenable
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The home screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginInfo info = context.read<LoginInfo>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(App.title),
        actions: [
          IconButton(
            onPressed: info.logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout: ${info.userName}',
          )
        ],
      ),
      body: const Center(
        child: Text('HomeScreen'),
      ),
    );
  }
}
