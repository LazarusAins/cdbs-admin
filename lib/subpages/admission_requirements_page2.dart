import 'package:flutter/material.dart';

// Name of your class
class AdmissionRequirementsPage2 extends StatefulWidget {
  const AdmissionRequirementsPage2({super.key});

  @override
  State<AdmissionRequirementsPage2> createState() => _AdmissionRequirementsPage2State();
}

class _AdmissionRequirementsPage2State extends State<AdmissionRequirementsPage2> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400;
    double baseHeight = 800;
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;




    return Container(
      padding: const EdgeInsets.all(16), // Optional padding for spacing
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Application ID
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Label text


      // Row to align the number beside the text
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Number next to the text
                Text(
        'Application ID',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(width: 30,),
          Text(
            '9741',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),

      Container(
        height: 1,
        color: const Color(0xFF909590), // Underline color
      ),
    ],
  ),
),
              ],
            ),
          ),









          const SizedBox(width: 16),


SizedBox(
            width: 550,
            child: Row(
              children: [
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

          Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Number next to the text
                Text(
        'Applicant Name',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(width: 30),
          Text(
            'Lazarus Ains',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),

      Container(
        height: 1,
        color: const Color(0xFF909590), // Underline color
      ),
    ],
  ),
),
              ],
            ),
          ),





          const SizedBox(width: 16),

          // Grade Level
SizedBox(
            width: 150,
            child: Row(
              children: [
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

          Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Number next to the text
                Text(
        'Grade Level',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(width:30),
          Text(
            '11',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),

      Container(
        height: 1,
        color: const Color(0xFF909590), // Underline color
      ),
    ],
  ),
),
              ],
            ),
          ),


          const SizedBox(width: 16),

          // Application Status
Expanded(
  child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

      Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      // Number next to the text
Text(
    'Application Status',
    style: TextStyle(
      fontSize: 11 * scale,
      fontFamily: 'Roboto-R',
    ),
  ),
  const SizedBox(width: 30),
      Text(
'REQUIREMENTS - IN REVIEW',
style: TextStyle(
  fontSize: 14 * scale,
  fontFamily: 'Roboto-R',
),
      ),
    ],
  ),
  const SizedBox(height: 4),

  Container(
    height: 1,
    color: const Color(0xFF909590), // Underline color
  ),
],
  ),
),
        ],
      ),
    );
  }
}
