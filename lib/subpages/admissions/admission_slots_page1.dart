import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/admissions/admission_requirements_page2.dart';
import 'package:cdbs_admin/subpages/admissions/admission_results_page2.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:cdbs_admin/subpages/s2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdmissionSlotsPage1 extends StatefulWidget {
  const AdmissionSlotsPage1({super.key});

  @override
  State<AdmissionSlotsPage1> createState() => _AdmissionSlotsPage1State();
}

class _AdmissionSlotsPage1State extends State<AdmissionSlotsPage1> {
//List<bool> checkboxStates = List.generate(10, (_) => false);


  

  


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400;
    double baseHeight = 800;
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;

    return Scaffold(
      body: Padding(
  padding: const EdgeInsets.symmetric(horizontal: 40),
  child: Column(
    children: [
      // Check if _selectedAction == 0 to show the default content

        // Header and Search Bar
        Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Admissions',
            style: TextStyle(
              color: const Color(0xff222222),
              fontFamily: "Roboto-R",
              fontSize: 34 * scale,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      const Divider(
        thickness: 2,
        color: Color(0XFF222222),
      ),



      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Slots',
            style: TextStyle(
              color: const Color(0xff222222),
              fontFamily: "Roboto-L",
              fontSize: 22 * scale,
            ),
          ),
          const Spacer(),

        ],
      ),
      const SizedBox(height: 40),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Grade Level',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Slots',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
        ],
      ),
      const Divider(color: Colors.grey, thickness: 1),
      



      Expanded(
        child: ListView.builder(
                itemBuilder: (context, index) {

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Grade 1",
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "3/10",
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Pending",
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                ],
              );
            },
          ),
        ),
      ],
    
  ),
));
              }}