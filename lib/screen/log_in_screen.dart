
// import 'dart:developer';
// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:softmax_app/main_navigation_bar.dart';
// import 'package:softmax_app/providers/login_provider.dart';
// import 'package:softmax_app/screen/post_details_screen.dart'; // ← Your post detail screen

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final AppLinks _appLinks = AppLinks();
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController usernameController =
//       TextEditingController(text: "emilys");
//   final TextEditingController passwordController =
//       TextEditingController(text: "emilyspass");

//   bool passwordVisible = false;
//   bool isListening = false; // Prevent multiple listeners

//   @override
//   void initState() {
//     super.initState();
//     _initDeepLinkListener();
//   }

//   /// Initialize Deep Link Listener (Works on Cold Start + When App is Open)
//   Future<void> _initDeepLinkListener() async {
//     // Handle app opened from terminated state (cold start)
//      Uri? initialLink = await _appLinks.getInitialLink();
//     if (initialLink != null) {
//       log('Cold start - Initial Link: $initialLink');
//       _handleDeepLink(initialLink);
//     }

//     // Listen to incoming links while app is running
//     if (!isListening) {
//       isListening = true;
//       _appLinks.uriLinkStream.listen(
//         (Uri? uri) {
//           if (uri != null) {
//             log('Hot state - Incoming Link: $uri');
//             _handleDeepLink(uri);
//           }
//         },
//         onError: (err) => log('Deep link stream error: $err'),
//       );
//     }
//   }

//   /// Extract post ID and navigate
//   void _handleDeepLink(Uri uri) async {
//     log('Handling deep link: $uri');

//     // Only handle dummyjson.com links
//     if (uri.host != 'dummyjson.com') return;

//     if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'posts') {
//       final String postId = uri.pathSegments[1];

//       if (postId.isEmpty) return;

//       // Wait until user is logged in (or auto-login if needed)
//       final authProvider = context.read<AuthProvider>();

//       // Optional: Auto-login with saved credentials (or skip if already logged in)
//       if (authProvider.user == null) {
//         bool success = await authProvider.login("emilys", "emilyspass");
//         if (!success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Auto-login failed. Please login manually.")),
//           );
//           return;
//         }
//       }

//       // Ensure widget is still mounted
//       if (!mounted) return;

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PostDetailsScreen(postId: int.parse(postId)),
//         ),
//       );
//     }
//   }
// // adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://dummyjson.com/posts/1" com.softmax.app

//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green, Colors.lightGreen],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         "Welcome Back",
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       // ... your TextFormFields (same as before)
//                       TextFormField(
//                         controller: usernameController,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.9),
//                           labelText: 'Username',
//                           prefixIcon: const Icon(Icons.person),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: passwordController,
//                         obscureText: !passwordVisible,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.9),
//                           labelText: 'Password',
//                           prefixIcon: const Icon(Icons.lock),
//                           suffixIcon: IconButton(
//                             icon: Icon(passwordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off),
//                             onPressed: () => setState(
//                                 () => passwordVisible = !passwordVisible),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: authProvider.isLoading
//                               ? null
//                               : () async {
//                                   if (_formKey.currentState!.validate()) {
//                                     final success = await authProvider.login(
//                                       usernameController.text.trim(),
//                                       passwordController.text.trim(),
//                                     );

//                                     if (success && mounted) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                             content: Text("Login Successful")),
//                                       );
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => const MainNavigation(),
//                                         ),
//                                       );
//                                     } else if (mounted) {
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         SnackBar(
//                                             content: Text(
//                                                 authProvider.errorMessage)),
//                                       );
//                                     }
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: authProvider.isLoading
//                               ? const CircularProgressIndicator(color: Colors.green)
//                               : const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:softmax_app/main_navigation_bar.dart';
import 'package:softmax_app/providers/login_provider.dart';
import 'package:softmax_app/screen/post_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AppLinks _appLinks = AppLinks();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController =
      TextEditingController(text: "emilys");
  final TextEditingController passwordController =
      TextEditingController(text: "emilyspass");

  bool passwordVisible = false;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      log('Cold start - Initial Link: $initialLink');
      _handleDeepLink(initialLink);
    }

    if (!isListening) {
      isListening = true;
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) _handleDeepLink(uri);
        },
        onError: (err) => log('Deep link stream error: $err'),
      );
    }
  }

  void _handleDeepLink(Uri uri) async {
    log('Handling deep link: $uri');

    if (uri.host != 'dummyjson.com') return;

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'posts') {
      final String postId = uri.pathSegments[1];
      if (postId.isEmpty) return;

      final authProvider = context.read<AuthProvider>();

      if (authProvider.user == null) {
        bool success = await authProvider.login("emilys", "emilyspass");
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Auto-login failed. Please login manually.")),
          );
          return;
        }
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsScreen(postId: int.parse(postId)),
        ),
      );
    }
  }
// adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://dummyjson.com/posts/1" com.softmax.app
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Username
                  TextFormField(
                    controller: usernameController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () =>
                            setState(() => passwordVisible = !passwordVisible),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authProvider.login(
                                  usernameController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Login Successful")),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainNavigation(),
                                    ),
                                  );
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.errorMessage)),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.green)
                          : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

