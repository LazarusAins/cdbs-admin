import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/page3.dart';
import 'package:flutter/material.dart';

class AdmissionOverviewPage extends StatefulWidget {
  const AdmissionOverviewPage({super.key});

  @override
  State<AdmissionOverviewPage> createState() => _AdmissionOverviewPageState();
}

class _AdmissionOverviewPageState extends State<AdmissionOverviewPage> {
  List<bool> checkboxStates = List.generate(10, (_) => false);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    color: const Color(0xff222222),
                    fontFamily: "Roboto-L",
                    fontSize: 20 * scale,
                  ),
                ),
                const Spacer(),
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
                    'Application ID',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Applicant Name',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Handled By',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontSize: 14 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 1,
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
                itemCount: 10,
                itemBuilder: (context, index) {
                  int sampleId = 1000 + index;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: checkboxStates[index],
                                  onChanged: (value) {
                                    setState(() {
                                      checkboxStates[index] = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  '$sampleId',
                                  style: TextStyle(fontSize: 12 * scale),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Applicant Name $index',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Handled By $index',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Status $index',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Date Created $index',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 14 * scale),
                            ),
                          ),




Expanded(
  flex: 1,
  child: PopupMenuButton<int>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) {
      // Handle selection here
      switch (value) {
        case 1:
          print("VIEW selected");
          // Navigate to the desired page here
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation,
                      secondaryAnimation) =>
                  const Page3(),
              transitionDuration:
                  Duration.zero, // No animation
              reverseTransitionDuration: Duration
                  .zero, // No animation on back
            ),
          );
          break;
        case 2:
          print("REMINDER selected");
          break;
        case 3:
          print("DEACTIVATE selected");
          break;
        default:
          break;
      }
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, color: Colors.black), // Replace with your icon
                 SizedBox(width: 8 * scale),
                Text("VIEW", style: TextStyle(fontSize: 16 * scale)),
              ],
            ),
          ],
        ),
      ),

      PopupMenuItem(
        value: 2,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, color: Colors.black), // Replace with your icon
                SizedBox(width: 8 * scale),
                Text("REMINDER", style: TextStyle(fontSize: 16 * scale)),
              ],
            ),
          ],
        ),
      ),


      PopupMenuItem(
        value: 3,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.black), // Replace with your icon
                SizedBox(width: 8 * scale),
                Text("DEACTIVATE", style: TextStyle(fontSize: 16 * scale)),
              ],
            ),
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
        ),
      ),
    );
  }
}
