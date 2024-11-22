import 'package:flutter/material.dart';

class UserGuestAccountsPage2 extends StatefulWidget {
  const UserGuestAccountsPage2({super.key});

  @override
  State<UserGuestAccountsPage2> createState() => _UserGuestAccountsPage2State();
}

class _UserGuestAccountsPage2State extends State<UserGuestAccountsPage2> {
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
                            'Action',
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

                  const SizedBox(height: 16),

                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 240,
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
  children: [
    Text(
      'Number of Applications: ',
      style: TextStyle(
        fontSize: 14, // Adjust the font size as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      '(2)', // Display the number of applications
      style: TextStyle(
        fontSize: 14,
        color: Colors.blue, // You can customize the color
      ),
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
                fontSize: 14 * scale,
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
