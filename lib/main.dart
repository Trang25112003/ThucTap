import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // For localization support
import 'package:job_supabase/pages/splash_page/splash_page.dart';
import 'package:job_supabase/routes/app_route.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/Home/avatar_provider.dart';
import 'pages/Home/profile/user_info_provider.dart';
import 'package:job_supabase/services/local/shared_pref.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs.initialise();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Không load được file .env: $e");
  }

  await Supabase.initialize(
    url: 'https://ytzfphxrtmssxgysnquu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0emZwaHhydG1zc3hneXNucXV1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MDAxOTAsImV4cCI6MjA1MDE3NjE5MH0.ai62f5SJ8dwI69kOFGSdpzJmT_PM8BqI4QqkN09-AAU',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => UserInfoProvider()),
      ],
      child: MyApp(key: MyApp.myAppStateKey),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<_MyAppState> myAppStateKey = GlobalKey<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _appLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await SharedPrefs.getLocale();
    if (savedLocale != null && mounted) {
      setState(() {
        _appLocale = Locale(savedLocale);
      });
    }
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _appLocale = newLocale;
    });
    SharedPrefs.saveLocale(newLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
      ],
      locale: _appLocale,
      debugShowCheckedModeBanner: false,
      title: 'Instruments',
      navigatorObservers: [routeObserver], // Register the route observer
      onGenerateRoute: AppRoutes.generateRoute,
      home: const SplashPage(),
    );
  }
}
