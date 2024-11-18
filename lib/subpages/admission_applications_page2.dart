// import 'package:flutter/material.dart';
// import 'package:cdbs_admin/subpages/landing_page.dart';

// class AdmissionApplicationsPage2 extends StatefulWidget {
//   const AdmissionApplicationsPage2({super.key});

//   @override
//   _AdmissionApplicationsPage2State createState() =>
//       _AdmissionApplicationsPage2State();
// }

// class _AdmissionApplicationsPage2State
//     extends State<AdmissionApplicationsPage2> {
//   int _currentPage = 1;

//   // Method to handle navigation to next page
//   void _nextPage() {
//     setState(() {
//       if (_currentPage < 3) {
//         _currentPage++;
//       }
//     });
//   }

//   // Method to handle navigation to previous page
//   void _backPage() {
//     setState(() {
//       if (_currentPage > 1) {
//         _currentPage--;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LandingPage(
//       appBar: AppBar(
//         title: const Text('Admission Applications'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Conditional rendering of body content based on _currentPage
//             if (_currentPage == 1)
//               const Text('Body Content 1', style: TextStyle(fontSize: 24)),
//             if (_currentPage == 2)
//               const Text('Body Content 2', style: TextStyle(fontSize: 24)),
//             if (_currentPage == 3)
//               const Text('Body Content 3', style: TextStyle(fontSize: 24)),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Back button is only visible if not on the first page
//             if (_currentPage > 1)
//               ElevatedButton(
//                 onPressed: _backPage,
//                 child: const Text('Back'),
//               ),
//             // Next button is always visible
//             ElevatedButton(
//               onPressed: _nextPage,
//               child: const Text('Next'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
