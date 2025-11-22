import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:softmax_app/providers/login_provider.dart';
import 'package:softmax_app/screen/log_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
         providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false ,
        title: 'Softmax App',
         theme: ThemeData(primarySwatch: Colors.green),
        home: const LoginScreen(),
      ),
    );
  }
}








