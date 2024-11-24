import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Name of your class
class AdmissionRequirementsPage2 extends StatefulWidget {

  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;

  AdmissionRequirementsPage2({super.key, required this.formDetails, required this.onNextPressed});

  @override
  State<AdmissionRequirementsPage2> createState() =>
      _AdmissionRequirementsPage2State();
}

class _AdmissionRequirementsPage2State extends State<AdmissionRequirementsPage2> {

  String? applicationId;
  String? fullName;
  String? status;
  String? dateCreatedString;
  String? formattedDate;

  @override
  void initState() {
    super.initState();
    print(widget.formDetails);
    applicationId = widget.formDetails![0]['db_admission_table']['admission_form_id'];
    fullName='${widget.formDetails![0]['db_admission_table']['first_name']} ${widget.formDetails![0]['db_admission_table']['last_name']}';
    status=widget.formDetails![0]['db_admission_table']['admission_status'];
    dateCreatedString = widget.formDetails![0]['db_admission_table']['created_at'];
    DateTime dateCreated = DateTime.parse(dateCreatedString!);
    formattedDate = formatDate(dateCreated);
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(date);
  }

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
              label: "Application ID",
              value: applicationId!,
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Applicant Name
          Expanded(
            flex: 3,
            child: _buildInfoColumn(
              label: 'Applicant Name',
              value: fullName!,
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Grade Level
          Expanded(
            flex: 2,
            child: _buildInfoColumn(
              label: 'Grade Level',
              value: widget.formDetails![0]['db_admission_table']['level_applying_for'],
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Application Status
          Expanded(
            flex: 4,
            child: _buildInfoColumn(
              label: 'Application Status',
              value: status!.toUpperCase(),
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
          Expanded(
            child: _buildInfoColumn(
              label: 'Date Created',
              value: formattedDate!,
              scale: scale,
            ),
          ),
        ],
      ),
      const SizedBox(height: 80),
      const Divider(),

      // Attached Documents Header
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
      Wrap(
        alignment: WrapAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [
          _buildImageCard(
            imagePath: 'assets/q4.jpg',
            label: '*Birth Certificate (PSA Copy)',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q2.jpg',
            label: '*Recent ID Photo',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q3.jpg',
            label: '*Parent Questionnaire',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q4.jpg',
            label: 'Baptismal Certificate',
            scale: scale,
          ),
          _buildImageCard(
            label: 'First Communion Certificate',
            scale: scale,
            isPlaceholder: true,
            isDashedLine: true, // Dashed border for placeholder
          ),
          _buildImageCard(
            label: 'Parent’s Marriage Certificate',
            scale: scale,
            isPlaceholder: true,
            isDashedLine: true, // Dashed border for placeholder
          ),
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
    String? imagePath,
    required String label,
    required double scale,
    bool isPlaceholder = false,
    bool isDashedLine = false,
  }) {
    return GestureDetector(
      onTap: () => _showImageDialog(imagePath), // Open dialog on tap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 158,
            height: 89,
            child: isDashedLine
                ? CustomPaint(
                    painter: DashedBorderPainter(),
                    child: Center(
                      child: isPlaceholder
                          ? Text(
                              "No Image",
                              style: TextStyle(
                                fontSize: 10 * scale,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5), // Image radius
                    child: Image.asset(
                      imagePath!,
                      width: 158,
                      height: 89,
                      fit: BoxFit.cover,
                    ),
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
      ),
    );
  }

  // Show image dialog when image is clicked
  void _showImageDialog(String? imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 550,
            height: 600,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle accept action
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle reject action
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(5),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final double nextDash = distance + dashWidth;
        final double nextSpace = nextDash + dashSpace;
        final Tangent tangent = pathMetric.getTangentForOffset(distance) ?? const Tangent(Offset.zero, Offset.zero);

        canvas.drawLine(
          tangent.position,
          tangent.position + tangent.vector * dashWidth,
          paint,
        );

        distance = nextSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
