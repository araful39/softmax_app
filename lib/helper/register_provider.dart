import 'package:provider/provider.dart';
import 'package:softmax_app/providers/login_provider.dart';
import 'package:softmax_app/providers/post_details_provider.dart';
import 'package:softmax_app/providers/post_list_provider.dart';
import 'package:softmax_app/providers/profile_provider.dart';

var registerProviders = [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => PostListProvider()),
           ChangeNotifierProvider(create: (_) => PostDetailsProvider()),
      ];