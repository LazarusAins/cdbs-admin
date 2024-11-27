import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdmissionPaymentsPage2 extends StatefulWidget {

  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  final int userId;
  AdmissionPaymentsPage2({super.key, required this.formDetails, required this.onNextPressed, required this.userId});

  @override
  State<AdmissionPaymentsPage2> createState() => _AdmissionPaymentsPage2State();
}

class _AdmissionPaymentsPage2State extends State<AdmissionPaymentsPage2> {
  // List of states for green and red buttons per container
  final List<bool> _isGreenExpanded = List.generate(2, (_) => false);
  final List<bool> _isRedExpanded = List.generate(2, (_) => false);
  final List<bool> _isInvoiceDisabled = List.generate(2, (_) => false);

  String? applicationId;
  String? fullName;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;

  List<Map<String, dynamic>> myformDetails=[];

  @override
  void initState() {
    super.initState();
    myformDetails=widget.formDetails!;
    applicationId = myformDetails[0]['db_admission_table']['admission_form_id'];
    fullName='${myformDetails[0]['db_admission_table']['first_name']} ${myformDetails[0]['db_admission_table']['last_name']}';
    status=myformDetails[0]['db_admission_table']['admission_status'];
    if(myformDetails[0]['db_admission_table']['payment_date']!=null){
      dateCreatedString = myformDetails[0]['db_admission_table']['payment_date'];
      DateTime dateCreated = DateTime.parse(dateCreatedString!);
      formattedDate = formatDate(dateCreated);
    }else{
      formattedDate='---';
    }
  }

  Future<void> updateData(int admissionId) async  {
    myformDetails = await ApiService(apiUrl).getFormsDetailsById(admissionId, supabaseUrl, supabaseKey);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Dynamic list of containers
          for (int i = 0; i < myformDetails.length; i++)
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
                          value: applicationId!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Applicant Name',
                          value: fullName!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: myformDetails[0]['db_admission_table']['level_applying_for'],
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildInfoColumn(
                          label: 'Application Status',
                          value: status!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Green Check Button
                          if (!_isRedExpanded[i])
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _isGreenExpanded[i] ? 99 : 44,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                          final response = await http.post(
                                            Uri.parse('$apiUrl/api/admin/update_admission'),
                                            headers: {
                                              'Content-Type': 'application/json',
                                              'supabase-url': supabaseUrl,
                                              'supabase-key': supabaseKey,
                                            },
                                            body: json.encode({
                                              'admission_id': myformDetails[0]['db_admission_table']['admission_id'],
                                              'admission_status':'complete',  // Send customer_id in the request body
                                              'user_id':widget.userId,
                                              'is_paid':true,
                                              'is_done':true
                                            }),
                                          );

                                          if (response.statusCode == 200) {
                                            final responseBody = jsonDecode(response.body);
                                            updateData(myformDetails[0]['db_admission_table']['admission_id']);
                                              setState(() {
                                                _isGreenExpanded[i] = true;
                                                _isRedExpanded[i] = false;
                                                _isInvoiceDisabled[i] = false; // Enable invoice button
                                              });
                                          } else {
                                            // Handle failure
                                            final responseBody = jsonDecode(response.body);
                                            print('Error: ${responseBody['error']}');
                                          }
                                        } catch (error) {
                                          // Handle error (e.g., network error)
                                          print('Error: $error');
                                        }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // Space between buttons
                          if (!_isGreenExpanded[i])
                            const SizedBox(width: 2),

                          // Red X Button
                          if (!_isGreenExpanded[i])
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _isRedExpanded[i] ? 99 : 44,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {

                                  setState(() {
                                    _isRedExpanded[i] = true;
                                    _isGreenExpanded[i] = false;
                                    _isInvoiceDisabled[i] = true; // Disable invoice button
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Payment Type',
                          value: 'Application Fee',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Total Amount',
                          value: '600.00',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildInfoColumn(
                          label: 'Payment Method',
                          value: 'Over the Counter',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Date Created',
                          value: formattedDate!,
                          scale: scale,
                        ),
                      ),
                      SizedBox(
                        width: 99,
                        height: 37,
                        child: ElevatedButton(
                          onPressed: _isInvoiceDisabled[i]
                              ? null
                              : () {
                                  // Handle invoice button action
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff012169),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Invoice',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _isInvoiceDisabled[i]
                                  ? Colors.grey
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
