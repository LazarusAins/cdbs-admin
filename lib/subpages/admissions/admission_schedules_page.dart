import 'dart:async';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/subpages/admissions/admission_schedules_page2.dart';
import 'package:intl/intl.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:cdbs_admin/subpages/page3.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AdmissionSchedulesPage extends StatefulWidget {
  const AdmissionSchedulesPage({super.key});

  @override
  State<AdmissionSchedulesPage> createState() => _AdmissionSchedulesPageState();
}



class _AdmissionSchedulesPageState extends State<AdmissionSchedulesPage> {
  List<bool> checkboxStates = List.generate(10, (_) => false);
  late ApiService _apiService;
  // Variable to track current action
  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  List<Map<String, dynamic>>? formDetails;

  

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamSchedule(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  String formatDate(DateTime date) {
    final DateTime localDate = date.toLocal(); // Converts to local time zone

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(localDate);
  }


  String formatTime(String time) {
  // Parse the time string into a DateTime object. 
  // For example, "8:00" should be parsed into a DateTime object with 12:00 AM
  final DateTime parsedTime = DateFormat('HH:mm').parse(time);

  // Format the DateTime object into a 12-hour format with AM/PM
  final DateFormat formatter = DateFormat('hh:mm a'); // 'hh' for 12-hour format, 'a' for AM/PM
  
  // Return formatted time
  return formatter.format(parsedTime);  // Format the DateTime object to time only
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
    TextEditingController dateController = TextEditingController();
    TextEditingController startTimeController = TextEditingController();
    TextEditingController endTimeController = TextEditingController();



@override
void dispose() {
  startTimeController.dispose();
  endTimeController.dispose();
  super.dispose();
}

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(
              // Center the spinner when loading
              child: SpinKitCircle(
                color: Color(0xff13322B), // Change the color as needed
                size: 50.0, // Adjust size as needed
              ),
            );
          } else if (authState is AuthSuccess) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: admissionForms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
              // Center the spinner when loading
                    child: SpinKitCircle(
                      color: Color(0xff13322B), // Change the color as needed
                      size: 50.0, // Adjust size as needed
                    ),
                  );
                }
                requests = snapshot.data ?? []; // Use the data from the snapshot
                filteredRequest = requests;

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Padding(
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
                    fontSize: 32 * scale,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              thickness: 2,
              color: Color(0XFF222222),
            ),

            if (_selectedAction == 0) _buildDefaultContent(scale), // Default content
            if (_selectedAction == 1) _buildViewContent(scale, formDetails!, authState.uid), // View content
            if (_selectedAction == 2) _buildReminderContent(scale), // Reminder content
            if (_selectedAction == 3) _buildDeactivateContent(scale),
            if (_selectedAction == 0) ...[

Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      'Schedules',
      style: TextStyle(
        color: const Color(0xff222222),
        fontFamily: "Roboto-L",
        fontSize: 20 * scale,
      ),
    ),
    const Spacer(),
    SizedBox(
      width: 178,
      height: 37,
      child: ElevatedButton(
        onPressed: () {
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    child: SizedBox(
      width: 500,
      height: 520,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Schedule Form',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Roboto-R",
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            // Date Field
            const Text(
              'Exam Date',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            TextField(
  controller: dateController, // Attach the controller to the TextField
  decoration: InputDecoration(
    hintText: 'Select date',
    suffixIcon: const Icon(Icons.calendar_today),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  readOnly: true,
  onTap: () async {
    // Open date picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      // Update the text field with the selected date
      dateController.text = selectedDate.toLocal().toString().split(' ')[0];
    }
  },
),
            const SizedBox(height: 16),
            // First Row of Dropdowns
            Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam Start Time',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: startTimeController, // Controller for start time
            decoration: InputDecoration(
              hintText: 'Select start time',
              suffixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                // Update the text field with the selected time
                startTimeController.text = pickedTime.format(context);
              }
            },
          ),
        ],
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam End Time',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: endTimeController, // Controller for end time
            decoration: InputDecoration(
              hintText: 'Select end time',
              suffixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                // Update the text field with the selected time
                endTimeController.text = pickedTime.format(context);
              }
            },
          ),
        ],
      ),
    ),
  ],
),


            const SizedBox(height: 16),
            // Expanded Dropdown
            const Text(
              'Location',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  onChanged: (value) {
    // Handle text input
  },
),

            const SizedBox(height: 16),
            // Second Row of Dropdowns
            Row(
              children: [
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Grade Level',
        style: TextStyle(fontSize: 11),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        items: [
          'Pre-Kinder',
          'Kinder',
          'Grade 1',
          'Grade 2',
          'Grade 3',
          'Grade 4',
          'Grade 5',
          'Grade 6',
          'Grade 7',
          'Grade 8',
          'Grade 9',
          'Grade 10',
          'Grade 11',
          'Grade 12',
        ]
        .map((grade) => DropdownMenuItem(
              value: grade,
              child: Text(grade),
            ))
        .toList(),
        onChanged: (value) {
          // Handle change
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ],
  ),
),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Slots',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  onChanged: (value) {
    // Handle text input
  },
),

                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Submit Button
            Center(
              child: SizedBox(
                width: 289,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle submit action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff012169),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontFamily: 'Roboto-R', fontSize: 13),),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Cancel Button
            Center(
              child: SizedBox(
                width: 289,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD3D3D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontFamily: 'Roboto-R', fontSize: 13),),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);


        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff012169),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          'Add New Schedule',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Roboto-R',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const SizedBox(width: 16), // Space between button and search bar
    SizedBox(
      width: 226 * scale,
      height: 32 * scale,
      child: TextField(
        decoration: InputDecoration(
          hintText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
          prefixIcon: InkWell(
            onTap: () {
              print("Search icon tapped");
            },
            child: Icon(
              Icons.search,
              size: 20 * scale,
              color: Colors.grey,
            ),
          ),
        ),
        style: TextStyle(fontSize: 14 * scale),
      ),
    ),
  ],
),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'EXAM DATE',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'EXAM TIME',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'EXAM LOCATION',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'GRADE LEVEL',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SLOTS',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date Created',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox.shrink()),
              ],
            ),
            const Divider(color: Colors.grey, thickness: 1),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRequest.length,
                itemBuilder: (context, index) {
                  final request = filteredRequest[index];

                  String dateCreatedString = request['create_at'];
                  DateTime dateCreated = DateTime.parse(dateCreatedString);
                  String formattedDate = formatDate(dateCreated);

                  String examDate = request['exam_date'];
                  DateTime dateExam = DateTime.parse(examDate);
                  String formattedExamDate = formatDate(dateExam);

                  String startTime = formatTime(request['start_time']);
                  String endTime = formatTime(request['end_time']);
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Text(formattedExamDate,
                                  style: TextStyle(fontSize: 12 * scale),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('$startTime - $endTime',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(request['location'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(request['grade_level'].toUpperCase(),
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(request['reservation_count']==request['slots']?'FULL':'${request['reservation_count']}/${request['slots']}',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(formattedDate,
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                            // Other table cells...
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<int>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  List<Map<String, dynamic>> members = await ApiService(apiUrl).fetchScheduleById(request['schedule_id'], supabaseUrl, supabaseKey);
                                     if(members.isNotEmpty){
                                             
                                        setState(()  {
                                          formDetails=members;
                                          _selectedAction = value; // Change the selected action
                                        });
                                     }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.visibility, color: Colors.black),
                                        SizedBox(width: 8 * scale),
                                        Text("VIEW", style: TextStyle(fontSize: 16 * scale)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.notifications, color: Colors.black),
                                        SizedBox(width: 8 * scale),
                                        Text("REMINDER", style: TextStyle(fontSize: 16 * scale)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.block, color: Colors.black),
                                        SizedBox(width: 8 * scale),
                                        Text("DEACTIVATE", style: TextStyle(fontSize: 16 * scale)),
                                      ],
                                    ),
                                  ),
                                ],
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
          ],
        ),
      );
              }
            );
          }
          return Container();
        }
      )
    );
  }

  // Build content for each action (VIEW, REMINDER, DEACTIVATE)
Widget _buildViewContent(double scale, List<Map<String, dynamic>> details, int userId) {
    return Container(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      // Back button with left arrow and "Back" text
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: Text(
              "Back",
              style: TextStyle(color: Colors.black, fontFamily: 'Roboto-R', fontSize: 12 * scale),
            ),
          ),

        ],
      ),
      
      // Adding AdmissionApplicationsPage2 below the buttons
       AdmissionSchedulesPage2(formDetails: details, onNextPressed: (bool isClicked) {
         context.read<AdmissionBloc>().add(MarkAsCompleteClicked(isClicked));
       },),
    ],
  ),
);



  }

  Widget _buildReminderContent(double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'REMINDER content goes here.',
            style: TextStyle(fontSize: 18 * scale),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildDeactivateContent(double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'DEACTIVATE content goes here.',
            style: TextStyle(fontSize: 18 * scale),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(double scale) {
    return Container(
      // padding: const EdgeInsets.all(16),
      // child: Text(
      //   '',
      //   style: TextStyle(fontSize: 18 * scale),
      // ),
    );
  }
}

