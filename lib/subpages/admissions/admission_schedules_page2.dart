import 'package:flutter/material.dart';

class AdmissionSchedulesPage2 extends StatefulWidget {
  const AdmissionSchedulesPage2({super.key});

  @override
  State<AdmissionSchedulesPage2> createState() => _AdmissionSchedulesPage2State();
}

class _AdmissionSchedulesPage2State extends State<AdmissionSchedulesPage2> {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Row with Logo, Text, and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and Text
              Row(
                children: [
                  // Logo (replace 'assets/logo.png' with your image path)
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      'assets/Logo.png', 
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Text(
                        'John Mark Romero',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto-R',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'jm@email.com / 0912-345-678',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto-R',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 40),



          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Exam Date',
                          value: '12/11/2024',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Exam Time',
                          value: '9AM - 10AM',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Exam Location',
                          value: 'Lobby',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: 'Grade 1',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Status',
                          value: '2/10',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Date Created',
                          value: '06/11/2024',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 99,
                        height: 37,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff012169),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),







            const SizedBox(height: 40),

          // Three Copies of Rows in Containers
          for (int i = 0; i < 2; i++) 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Application ID',
                          value: '9741',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Applicant Name',
                          value: 'Lazarus Ains',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: '11',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildInfoColumn(
                          label: 'Application Status',
                          value: 'REQUIREMENTS - IN REVIEW',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 99,),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: _buildInfoColumn(
                          label: 'Date Created',
                          value: '2024-11-20',
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Row(
  mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
  crossAxisAlignment: CrossAxisAlignment.center, // Aligns text and icon vertically
  children: [
    Text(
      'Reschedule ',
      style: TextStyle(
        fontSize: 14, // Adjust the font size as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      '(3)', // Display the number of applications
      style: TextStyle(
        fontSize: 14,
      ),
    ),
    SizedBox(width: 4), // Space between text and icon
    Icon(
      Icons.keyboard_arrow_down, // Down arrow icon
      size: 20, // Adjust size as needed
    ),
  ],
)


        ],
      ),
    );
    
  }

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
                fontSize: 11 * scale,
                fontFamily: 'Roboto-R',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 1,
          color: const Color(0xFF909590),
        ),
      ],
    );
  }
}
