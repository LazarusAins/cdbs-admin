//import 'package:cdbs_admin/subpages/admission_overview_page.dart';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
/*import 'package:cdbs_admin/subpages/page1.dart';
import 'package:cdbs_admin/subpages/s1.dart';*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
/*import 'subpages/home_page.dart';
import 'subpages/login_page.dart';
import 'subpages/forgot_password.dart';
import 'subpages/reset_password.dart';
import 'subpages/admission_applications_page2.dart';*/

// void main() => runApp(const MaterialApp(
//       debugShowCheckedModeBanner: false,
// //HomePage is the name of the class you're about to run
//       home: LoginPage(),
//     ));



void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => AdmissionBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Don Bosco Admin',
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 249, 249, 252),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1), // Default border color
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF012169), width: 2), // Active (focused) border color
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0XFF012169), // Sets the cursor color to green
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
        },
      ),
    );
  }
}
