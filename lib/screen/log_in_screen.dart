// import 'dart:developer';

// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:softmax_app/main_navigation_bar.dart';
// import 'package:softmax_app/providers/login_provider.dart';
// import 'package:softmax_app/screen/home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {


//     final AppLinks _appLinks = AppLinks();
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController usernameController = TextEditingController(
//     text: "emilys",
//   );
//   final TextEditingController passwordController = TextEditingController(
//     text: "emilyspass",
//   );

//   bool passwordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//   _initDeepLinkListener();
//     passwordVisible = false;
//   }


//    /// Initialize Deep Link Listener
//   Future<void> _initDeepLinkListener() async {
//     // 🔹 Cold start deep link
//     try {
//       Uri? initialLink = await _appLinks.getInitialLink();

//       // Retry after small delay (Release build fix)
//       if (initialLink == null) {
//         await Future.delayed(const Duration(seconds: 2));
//         initialLink = await _appLinks.getInitialLink();
//       }

//       if (initialLink != null) {
//         log('📩 Initial Link (with retry): $initialLink');
//         await _handleDeepLink(initialLink);
//       } else {
//         log('⚠️ No initial link found even after retry');
//       }
//     } catch (e) {
//       log('❌ Error reading initial link: $e');
//     }

//     // 🔹 Stream listener for app already running
//     if (!isListening) {
//       isListening = true;
//       _appLinks.uriLinkStream.listen(
//             (Uri uri) {
//           log('🔔 Stream Link: $uri');
//           _handleDeepLink(uri);
//         },
//         onError: (err) => log('❌ Deep link stream error: $err'),
//       );
//     }
//   }

//   /// Handle deep link logic
//   Future<void> _handleDeepLink(Uri uri) async {
//     log('🔗 URI: $uri');

//     if (uri.scheme != 'https' || uri.host != 'dummyjson.com') return;

//     final List<String> pathSegments = uri.pathSegments;
//     if (pathSegments.isEmpty || pathSegments.first != 'posts') return;

//     final String? id =
//     pathSegments.length > 1 ? pathSegments[1] : uri.queryParameters['id'];

//     if (id == null || id.isEmpty) {
//       log('❌ No book code found in link');
//       return;
//     }


//   }
  

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();
//     final isLoading = authProvider.isLoading;

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
//                       TextFormField(
//                         controller: usernameController,
//                         keyboardType: TextInputType.text,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.white.withOpacity(0.9),
//                           labelText: 'Username',
//                           prefixIcon: const Icon(Icons.person),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Colors.green,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Username is required';
//                           }
//                           if (value.length < 3) {
//                             return 'Username must be at least 3 characters';
//                           }
//                           return null;
//                         },
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
//                             icon: Icon(
//                               passwordVisible
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 passwordVisible = !passwordVisible;
//                               });
//                             },
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(
//                               color: Colors.green,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Password is required';
//                           }
//                           if (value.length < 6) {
//                             return 'Password must be at least 6 characters';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: isLoading
//                               ? null
//                               : () async {
//                                   if (_formKey.currentState!.validate()) {
//                                     final success = await authProvider.login(
//                                       usernameController.text
//                                           .trim(), // send username instead of email
//                                       passwordController.text.trim(),
//                                     );
//                                     if (success) {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text("Login Successful"),
//                                         ),
//                                       );
//                                       Navigator.pushReplacement(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) {
//                                             return const MainNavigation();
//                                           },
//                                         ),
//                                       );
//                                       // Navigate to next screen
//                                     } else {
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             authProvider.errorMessage,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             backgroundColor: Colors.white,
//                           ),
//                           child: isLoading
//                               ? const CircularProgressIndicator(
//                                   color: Colors.green,
//                                 )
//                               : const Text(
//                                   "Login",
//                                   style: TextStyle(
//                                     color: Colors.green,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
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
import 'package:softmax_app/screen/post_details_screen.dart'; // ← Your post detail screen

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
  bool isListening = false; // Prevent multiple listeners

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  /// Initialize Deep Link Listener (Works on Cold Start + When App is Open)
  Future<void> _initDeepLinkListener() async {
    // Handle app opened from terminated state (cold start)
     Uri? initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      log('Cold start - Initial Link: $initialLink');
      _handleDeepLink(initialLink);
    }

    // Listen to incoming links while app is running
    if (!isListening) {
      isListening = true;
      _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            log('Hot state - Incoming Link: $uri');
            _handleDeepLink(uri);
          }
        },
        onError: (err) => log('Deep link stream error: $err'),
      );
    }
  }

  /// Extract post ID and navigate
  void _handleDeepLink(Uri uri) async {
    log('Handling deep link: $uri');

    // Only handle dummyjson.com links
    if (uri.host != 'dummyjson.com') return;

    if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'posts') {
      final String postId = uri.pathSegments[1];

      if (postId.isEmpty) return;

      // Wait until user is logged in (or auto-login if needed)
      final authProvider = context.read<AuthProvider>();

      // Optional: Auto-login with saved credentials (or skip if already logged in)
      if (authProvider.user == null) {
        bool success = await authProvider.login("emilys", "emilyspass");
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Auto-login failed. Please login manually.")),
          );
          return;
        }
      }

      // Ensure widget is still mounted
      if (!mounted) return;

      // // Navigate to Post Details
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PostDetailsScreen(postId: int.tryParse(postId)!),
      //   ),
      // );

      // Or go directly to PostDetailsScreen if you want to skip main nav
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailsScreen(postId: int.parse(postId)),
        ),
      );
    }
  }

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
      body: Stack(
        children: [
          Container(
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
                      // ... your TextFormFields (same as before)
                      TextFormField(
                        controller: usernameController,
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
                      TextFormField(
                        controller: passwordController,
                        obscureText: !passwordVisible,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(
                                () => passwordVisible = !passwordVisible),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text("Login Successful")),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MainNavigation(),
                                        ),
                                      );
                                    } else if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                authProvider.errorMessage)),
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
        ],
      ),
    );
  }
}