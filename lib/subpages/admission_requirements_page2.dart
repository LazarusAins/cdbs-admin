import 'package:flutter/material.dart';

// Name of your class
class AdmissionRequirementsPage2 extends StatefulWidget {
  const AdmissionRequirementsPage2({super.key});

  @override
  State<AdmissionRequirementsPage2> createState() =>
      _AdmissionRequirementsPage2State();
}

class _AdmissionRequirementsPage2State
    extends State<AdmissionRequirementsPage2> {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // First Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Application ID
              Expanded(
                flex: 2,
                child: _buildInfoColumn(
                  label: 'Application ID',
                  value: '9741',
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Applicant Name
              Expanded(
                flex: 3,
                child: _buildInfoColumn(
                  label: 'Applicant Name',
                  value: 'Lazarus Ains',
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Grade Level
              Expanded(
                flex: 2,
                child: _buildInfoColumn(
                  label: 'Grade Level',
                  value: '11',
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Application Status
              Expanded(
                flex: 4,
                child: _buildInfoColumn(
                  label: 'Application Status',
                  value: 'REQUIREMENTS - IN REVIEW',
                  scale: scale,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Space between rows

          // Second Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date Submitted
              SizedBox(
                width: 240,
                child: Expanded(
                  child: _buildInfoColumn(
                    label: 'Date Created',
                    value: '2024-11-20',
                    scale: scale,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          const Divider(),

          // Attached Documents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attached Document/s',
                style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-R'),
              ),
            ],
          ),

          const SizedBox(height: 40), // Space before images

          // Row of Images
          Row(

            children: [
              _buildImageCard(
                  imagePath: 'assets/q1.jpg',
                  label: 'Document 1',
                  scale: scale),
              _buildImageCard(
                  imagePath: 'assets/q2.jpg',
                  label: 'Document 2',
                  scale: scale),
              _buildImageCard(
                  imagePath: 'assets/q3.jpg',
                  label: 'Document 3',
                  scale: scale),
              _buildImageCard(
                  imagePath: 'assets/q1.jpg',
                  label: 'Document 4',
                  scale: scale),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to create the individual information column
  Widget _buildInfoColumn({
    required String label,
    required String value,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11 * scale,
                fontFamily: 'Roboto-R',
              ),
            ),
            const SizedBox(width: 30),
            Text(
              value,
              style: TextStyle(
                fontSize: 14 * scale,
                fontFamily: 'Roboto-R',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 1,
          color: const Color(0xFF909590), // Underline color
        ),
      ],
    );
  }

  // Helper method to create image cards
  Widget _buildImageCard({
    required String imagePath,
    required String label,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5), // Image radius
          child: Image.asset(
            imagePath,
            width: 158,
            height: 89,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8), // Space between image and text
        Text(
          label,
          style: TextStyle(
            fontSize: 11 * scale,
            fontFamily: 'Roboto-R',
          ),
          textAlign: TextAlign.left, // Align text to the left
        ),
      ],
    );
  }
}
