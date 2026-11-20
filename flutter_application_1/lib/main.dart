import 'package:flutter/material.dart';

import 'screens/profile_page.dart';
import 'screens/add_blog_page.dart';
import 'screens/login_user_page.dart';
import 'screens/register_user_page.dart';
import 'screens/users_page.dart';
import 'screens/blog_page.dart';
import 'screens/reported_comments_page.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My aplicacion',
      initialRoute: '/login',
      routes: {
        '/reported-comments': (context) => const ReportedCommentsPage(),
        '/blog': (context) => const BlogPage(),
        '/users': (context) => const UsersPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/add-blog': (context) => const AddBlogPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
