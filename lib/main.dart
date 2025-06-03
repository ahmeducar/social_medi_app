import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_app/firebase_options.dart';
import 'package:twitter_clone_app/services/auth/auth_gate.dart';
import 'package:twitter_clone_app/services/database/database_provider.dart';
import 'package:twitter_clone_app/themes/theme.provider.dart';
 
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(providers: [
      //* theme provider
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      //! database provider
      ChangeNotifierProvider(create: (context)=> DatabaseProvider()),
      ],
      child: const MyApp(),  //* main app widget
    )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {'/':(context) => const AuthGate()},
      theme:Provider.of<ThemeProvider>(context).themeData,
    );

  }
}
