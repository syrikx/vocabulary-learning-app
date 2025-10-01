import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/vocabulary_provider.dart';
import 'providers/word_provider.dart';
import 'providers/stats_provider.dart';
import 'services/api_auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocabularyApp());
}

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiAuthService>(
          create: (_) => ApiAuthService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<ApiAuthService, VocabularyProvider>(
          create: (context) => VocabularyProvider(
            context.read<ApiAuthService>(),
          ),
          update: (context, authService, previous) =>
              previous ?? VocabularyProvider(authService),
        ),
        ChangeNotifierProxyProvider<ApiAuthService, WordProvider>(
          create: (context) => WordProvider(
            context.read<ApiAuthService>(),
          ),
          update: (context, authService, previous) =>
              previous ?? WordProvider(authService),
        ),
        ChangeNotifierProxyProvider<ApiAuthService, StatsProvider>(
          create: (context) => StatsProvider(
            context.read<ApiAuthService>(),
          ),
          update: (context, authService, previous) =>
              previous ?? StatsProvider(authService),
        ),
      ],
      child: MaterialApp(
        title: '영어 단어장',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const MainNavigationScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 로그인 없이 바로 메인 화면 표시 (게스트 모드 허용)
    return const MainNavigationScreen();
  }
}
