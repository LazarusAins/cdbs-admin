import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/widget/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
//import 'package:tus_client/tus_client.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:tusc/tusc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


// Name of your class
class PreSubmission2 extends StatefulWidget {
  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  int userId;
  final String adminType;
  PreSubmission2(
      {super.key,
      required this.formDetails,
      required this.onNextPressed,
      required this.userId,
      required this.adminType});

  @override
  State<PreSubmission2> createState() =>
      _PreSubmission2State();
}

class _PreSubmission2State
    extends State<PreSubmission2> {
  TextEditingController rejectController = TextEditingController();
  String? applicationId;
  String? fullName;
  String? parentName;
  String? parentEmail;
  String? parentContact;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;
  String originalUrl = '';
  bool isLoading = false;
  int index =-1;
  List<Map<String, dynamic>> myformDetails = [];
  List<PlatformFile> _selectedFiles =[];
  bool isSelect = false;
  final fileUrls = <String>[];

  @override
  void initState() {
    super.initState();
    myformDetails = widget.formDetails!;
    applicationId = myformDetails[0]['db_admission_table']['admission_form_id'];
    fullName = '${myformDetails[0]['db_admission_table']['first_name']} ${myformDetails[0]['db_admission_table']['last_name']}';
    parentName = '${myformDetails[0]['db_admission_users_table']['last_name']}, ${myformDetails[0]['db_admission_users_table']['first_name']}';
    parentEmail = '${myformDetails[0]['db_admission_users_table']['email_address']}';
    parentContact = '${myformDetails[0]['db_admission_users_table']['contact_no']}';
    status = myformDetails[0]['db_admission_table']['admission_status'];
    dateCreatedString = myformDetails[0]['db_admission_table']['created_at'];
    DateTime dateCreated = DateTime.parse(dateCreatedString!);
    formattedDate = formatDate(dateCreated);
  }

  Future<void> updateData(int admissionId) async {
    myformDetails = await ApiService(apiUrl).getFormsDetailsById(admissionId, supabaseUrl, supabaseKey);
    setState(() {
      var document = myformDetails[0]['db_admission_table']['db_required_documents_table'];
      index = document.indexWhere((doc) => doc['requirements_type'] == 16);
      if (index != -1) {
        originalUrl = document[index]['document_url'];
      }
    });
  }


  void openUrlsInSameTab(List<String> urls) {
  try {
    // Create an iframe to display the first document
    var iframe = html.IFrameElement();
    iframe.src = urls.first; // Set the first URL
    iframe.width = '100%';
    iframe.height = '100vh';
    html.document.body!.children.add(iframe); // Add iframe to the body

    // After viewing the first URL, switch to the next one
    for (var i = 1; i < urls.length; i++) {
      // Update the iframe's source to the next URL
      iframe.src = urls[i];
    }
  } catch (e) {
    // If an error occurs, show a SnackBar with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the link'),
      ),
    );
  }
}


Future<void> _pickFiles(StateSetter setState) async {
  try {
    // Create the file upload input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf'; // Accept PDF files only
    uploadInput.multiple = true; // Allow multiple files
    uploadInput.click(); // Trigger the file picker dialog

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        // Create a list to store new selected files
        List<PlatformFile> newFiles = [];

        for (var file in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file); // Read as ArrayBuffer (Uint8List)
          await reader.onLoadEnd.first; // Wait for the file to be fully loaded

          if (reader.result != null) {
            final bytes = reader.result as Uint8List;

            // Check if the file is already in the list (prevent duplicates)
            bool fileExists = _selectedFiles.any((f) => f.name == file.name);
            if (!fileExists) {
              newFiles.add(PlatformFile(
                name: file.name,
                size: file.size,
                bytes: bytes,
                path: null, // Path is not available in web
              ));
            }
          }
        }

        // Update the selected files in the state
        setState(() {
          if (_selectedFiles.isEmpty) {
            _selectedFiles = newFiles; // If empty, replace with new files
          } else {
            _selectedFiles.addAll(newFiles); // Append new files
          }
        });
      }
    });
  } catch (e) {
    print('Error picking files: $e');
  }
}



  String formatDate(DateTime date) {
    // Convert the UTC date to local time
    DateTime localDate = date.toLocal();

    // Create a DateFormat object to format the date
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');

    // Return the formatted date in local time
    return formatter.format(localDate);
  }

Future<bool> uploadFile(String bucketName, List<PlatformFile> selectedFiles, String admissionId) async {
  final uploadURL = '$supabaseUrl/storage/v1/upload/resumable';
   // To store uploaded file URLs

  // Convert List<PlatformFile> to List<XFile>
  List<XFile> xFiles = selectedFiles.map((platformFile) {
    if (kIsWeb) {
      return XFile.fromData(
        platformFile.bytes!, // Use bytes on web
        name: platformFile.name,
        mimeType: 'application/pdf', // Adjust mime type as needed
      );
    } else {
      return XFile(platformFile.path!, name: platformFile.name);
    }
  }).toList();

  bool allUploadsSuccessful = true; // Flag to check if all uploads were successful

  for (XFile file in xFiles) {
    try {
      // Generate a unique file name and path
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${timestamp}-${file.name}-admissionID-${admissionId}';
      final filePath = '$timestamp/$fileName'; // Path with timestamp as folder and file name as the file

      // Construct the public URL
      final publicUrl = '${supabaseUrl}storage/v1/object/public/$bucketName/$filePath';
      fileUrls.add(publicUrl);

      // Create a client with necessary configurations
      final tusClient = TusClient(
        url: uploadURL,
        file: file,
        chunkSize: 6 * 1024 * 1024, // 6 MB per chunk
        cache: TusPersistentCache('/some/path'), // Optional: Set your cache path
        headers: <String, dynamic>{
          HttpHeaders.authorizationHeader: 'Bearer $supabaseKey', // Authorization
          'x-upsert': 'true', // Optional: Set upsert to true to overwrite existing files
        },
        metadata: <String, dynamic>{
          'bucketName': bucketName,
          'objectName': filePath,
          'contentType': 'application/pdf', // Ensure to use correct mime type
          'cacheControl': '3600',
        },
        timeout: Duration(seconds: 10), // Optional: Set your timeout
        httpClient: http.Client(),
      );

      // Start the upload process for the current file
      await tusClient.startUpload(
        onProgress: (count, total, progress) {
          print('Uploading $fileName - Progress: ${((count / total) * 100).toInt()}%');
        },
        onComplete: (response) {
          print('File $fileName uploaded successfully!');
          print('Upload URL: ${tusClient.uploadUrl}');
        },
        onTimeout: () {
          print('Upload timed out for $fileName');
          allUploadsSuccessful = false; // Mark as unsuccessful if timeout occurs
        },
      );

      // Example: Pause upload after 6 seconds
      await Future.delayed(const Duration(seconds: 6), () async {
        await tusClient.pauseUpload();
        print('Upload paused for $fileName. State: ${tusClient.state}');
      });

      // Example: Cancel upload after 6 more seconds
      await Future.delayed(const Duration(seconds: 6), () async {
        await tusClient.cancelUpload();
        print('Upload cancelled for $fileName. State: ${tusClient.state}');
      });

      // Example: Resume upload after 8 more seconds
      await Future.delayed(const Duration(seconds: 8), () async {
        tusClient.resumeUpload();
        print('Upload resumed for $fileName. State: ${tusClient.state}');
      });
    } catch (error) {
      print('Error uploading $file: $error');
      allUploadsSuccessful = false; // Mark as unsuccessful if error occurs
    }
  }

  return allUploadsSuccessful;
}





Future<bool> _uploadRecommendation(
  String requirementsType,
  String admissionId,
  String bucketName,
  String status
) async {
  try {
   final response = await http.post(
        Uri.parse('$apiUrl/api/admin/upload_requirements'),
        headers: {
          'Content-Type': 'application/json',
          'supabase-url': supabaseUrl,
          'supabase-key': supabaseKey,
        },
        body: json.encode({
          'requirements_type': requirementsType,
          'admission_id':admissionId,
          'bucket_name': bucketName,
          'file_urls': jsonEncode(fileUrls),
          'status':status
        }),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return true;
      }else {
        // Handle failure
        final responseBody = jsonDecode(response.body);
        print('Error: ${responseBody['error']}');
        return false;
      }
  } on TimeoutException {
    print('The request timed out. Please try again later.');
    return false;
  } catch (e) {
    print('Unexpected error: $e');
    return false;
  }
}

// Ensure the file name is properly URL-encoded to handle special characters
String encodeFileName(String fileName) {
  return Uri.encodeComponent(fileName);
}

String? _getMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    default:
      return null;
  }
}

// Example method to fetch file bytes

Future<Uint8List?> _getFileBytes(PlatformFile file) async {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  // Check if file bytes are available and valid
  if (file.bytes == null || file.bytes!.isEmpty) {
    print('File bytes are empty or null for ${file.name}');
    return null; // Return null if no bytes
  }

  // Create a Blob from the file's bytes
  final blob = html.Blob([file.bytes!]);

  // Read the Blob as an ArrayBuffer
  reader.readAsArrayBuffer(blob);

  // Handle the load and error events
  reader.onLoadEnd.listen((e) {
    final result = reader.result;
    if (result != null) {
      print('File read successfully: ${(result as Uint8List).length} bytes');
      completer.complete(result as Uint8List);
    } else {
      print('Failed to read file data for ${file.name}');
      completer.completeError('Error reading file data');
    }
  });

  reader.onError.listen((e) {
    print('Error while reading file ${file.name}: ${e}');
    completer.completeError('Error reading file data');
  });

  return completer.future;
}




  /*Future<Uint8List> _getFileBytes(PlatformFile file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    // Create a Blob from the file's bytes
    final blob = html.Blob(
        [file.bytes]); // Assuming 'file.bytes' gives you the byte data

    reader.readAsArrayBuffer(blob);
    reader.onLoadEnd.listen((e) {
      completer.complete(reader.result as Uint8List);
    });

    return completer.future;
  }*/

  


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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  value: myformDetails[0]['db_admission_table']
                      ['level_applying_for'],
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Application Status
              Expanded(
                flex: 2,
                child: _buildInfoColumn(
                  label: 'Application Status',
                  value: status!.toUpperCase(),
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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Application ID
              Expanded(
                flex: 2,
                child: _buildParentColumn(
                  label: "Parent Name",
                  value: parentName!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Applicant Name
              Expanded(
                flex: 3,
                child: _buildInfoColumn(
                  label: 'Email Address',
                  value: parentEmail!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Grade Level
              Expanded(
                flex: 2,
                child: _buildInfoColumn(
                  label: 'Contact Number',
                  value: parentContact!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: SizedBox()
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: SizedBox()
              ),
              
            ],
          ),

          // Second Row

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

          SizedBox(
              width: 800,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Document Type',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 3,
                    child: Text('View Documents',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('Status',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('Actions',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                ],
              )),

              SizedBox(
                  width: 800,
                  height: 400,
                  child: BlocConsumer<AuthBloc, AuthState>(
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
                      
                    if (authState is AuthSuccess) {
                      var document = myformDetails[0]['db_admission_table']['db_required_documents_table'];
                      index = document.indexWhere((doc) => doc['requirements_type'] == 16);
                      if (index != -1) {
                        originalUrl = document[index]['document_url'];
                      }
                      return Column(children: [
                        const SizedBox(height: 10),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Pre-Requirement',
                                  style: TextStyle(
                                      fontFamily: 'Roboto-R', fontSize: 14 * scale),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 3,
                                child: originalUrl.isEmpty
                                ? ElevatedButton(
                                    onPressed: () {
                                      // Upload button action
                                      // Implement the upload functionality here\
                                      showUploadDialog(context, myformDetails[0]['db_admission_table']['admission_id'], setState);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff28a745), // Green color for upload
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Text(
                                      "Upload",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                :ElevatedButton(
                                  onPressed: originalUrl.isNotEmpty
                                      ? () async {
                                          List<String> urls = List<String>.from(json.decode(originalUrl));
                                          try {
                                            for (var url in urls) {
                                              // Open each URL in a new tab
                                              html.window.open(url, '_blank');
                                            }
                                          } catch (e) {
                                            // If an error occurs, show a SnackBar with the error message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Could not open the link'),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff012169),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    "Open Link",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                  flex: 2,
                                  child: Text(myformDetails[0]['db_admission_table']['is_pre_requirement_submitted'] ?'COMPLETE':'PENDING',
                                    style: TextStyle(
                                        fontFamily: 'Roboto-R',
                                        fontSize: 14 * scale),
                                  )),
                                  const SizedBox(width: 40),
                              Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed:!myformDetails[0]['db_admission_table']['is_pre_requirement_submitted']
                                                ? () {
                                                  if(myformDetails[0]['db_admission_table']['admission_status']=='PROBATIONARY'){
                                                    if(originalUrl.isEmpty){
                                                      _showMessage('Please upload the probationary contract first','error');
                                                    }else{
                                                      
showDialog(context: context,
                                                      builder: (context) => Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                        child: BlocConsumer<
                                                            AdmissionBloc,
                                                            AdmissionState>(
                                                          listener:
                                                              (context, state) {},
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is AdmissionIsLoading) {
                                                              isLoading =
                                                                  state.isLoading;
                                                            }
                                                            return SizedBox(
                                                              width: 349.0,
                                                              height: 272.0,
                                                              child: isLoading
                                                                  ? const CustomSpinner(
                                                                      color: Color(
                                                                          0xff13322b), // Change the spinner color if needed
                                                                      size:
                                                                          60.0, // Change the size of the spinner if needed
                                                                    )
                                                                  : Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // Title
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top:
                                                                                  16.0,
                                                                              bottom:
                                                                                  8.0),
                                                                          child:
                                                                              Text(
                                                                            "Confirmation",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  20,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        // Content
                                                                        const Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  24.0),
                                                                          child:
                                                                              Text(
                                                                            "Are you sure you want to confirm?",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  13,
                                                                              fontWeight:
                                                                                  FontWeight.normal,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // Divider
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left:
                                                                                  20,
                                                                              right:
                                                                                  20),
                                                                          child: Divider(
                                                                              thickness:
                                                                                  1),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // No Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xffD3D3D3), // No button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context).pop(); // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "No",
                                                                                style:
                                                                                    TextStyle(color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                12.0), // Spacing between buttons
                                                                        // Yes Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xff012169), // Amber button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () async {
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(true));
                                                                                try {
                                                                                  final response = await http.post(
                                                                                    Uri.parse('$apiUrl/api/admin/update_admission'),
                                                                                    headers: {
                                                                                      'Content-Type': 'application/json',
                                                                                      'supabase-url': supabaseUrl,
                                                                                      'supabase-key': supabaseKey,
                                                                                    },
                                                                                    body: json.encode({
                                                                                      'admission_id': myformDetails[0]['admission_id'], // Send admission_id in the request body
                                                                                      'is_pre_require': true,
                                                                                      'user_id': widget.userId,
                                                                                      'is_done': true,
                                                                                    }),
                                                                                  );
                
                                                                                  if (response.statusCode == 200) {
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    setState(() {
                                                                                      updateData(document[index]['admission_id']);
                                                                                      //bool isDone = checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(document));
                                                                                    });
                                                                                    // Show success modal
                                                                                    context.read<AdmissionBloc>().add(IsLoadingClicked(false));
                                                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return Dialog(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                          ),
                                                                                          child: Container(
                                                                                            width: 349,
                                                                                            height: 272,
                                                                                            padding: const EdgeInsets.all(16),
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                // Centered Text
                                                                                                const Center(
                                                                                                    // child: Text(
                                                                                                    //   "",
                                                                                                    //   style: TextStyle(
                                                                                                    //     fontSize: 20,
                                                                                                    //   ),
                                                                                                    //   textAlign: TextAlign.center,
                                                                                                    // ),
                                                                                                    ),
                                                                                                // Red X Icon with Circular Outline
                                                                                                Column(
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 90,
                                                                                                      height: 90,
                                                                                                      decoration: BoxDecoration(
                                                                                                        shape: BoxShape.circle,
                                                                                                        border: Border.all(color: const Color(0XFF012169), width: 2),
                                                                                                      ),
                                                                                                      child: const Center(
                                                                                                        child: Icon(
                                                                                                          Icons.check,
                                                                                                          color: Color(0XFF012169),
                                                                                                          size: 40,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(height: 20),
                                                                                                    // No Form Submitted Text
                                                                                                    const Text(
                                                                                                      "Done updating data",
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                // Divider
                                                                                                const Divider(
                                                                                                  thickness: 1,
                                                                                                  color: Colors.grey,
                                                                                                ),
                                                                                                // Close Button
                                                                                                Align(
                                                                                                  alignment: Alignment.bottomCenter,
                                                                                                  child: ElevatedButton(
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop(); // Close the modal
                                                                                                    },
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                      backgroundColor: const Color(0xff012169), // Button color
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                                      ),
                                                                                                      minimumSize: const Size(double.infinity, 50), // Expand width and set height
                                                                                                    ),
                                                                                                    child: const Text(
                                                                                                      "Close",
                                                                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  } else {
                                                                                    // Handle failure
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    print('Error: ${responseBody['error']}');
                                                                                    Navigator.of(context).pop();
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (context) => AlertDialog(
                                                                                        title: const Text("Error"),
                                                                                        content: Text("Failed to complete review: ${responseBody['error']}"),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop(); // Close dialog
                                                                                            },
                                                                                            child: const Text("OK"),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                } catch (error) {
                                                                                  // Handle network error
                                                                                  print('Error: $error');
                                                                                  Navigator.of(context).pop();
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => AlertDialog(
                                                                                      title: const Text("Error"),
                                                                                      content: const Text("An unexpected error occurred. Please try again later."),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop(); // Close dialog
                                                                                          },
                                                                                          child: const Text("OK"),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                } // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "Yes",
                                                                                style:
                                                                                    TextStyle(color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                    }
                                                  }else{
                                                    
showDialog(context: context,
                                                      builder: (context) => Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                        child: BlocConsumer<
                                                            AdmissionBloc,
                                                            AdmissionState>(
                                                          listener:
                                                              (context, state) {},
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is AdmissionIsLoading) {
                                                              isLoading =
                                                                  state.isLoading;
                                                            }
                                                            return SizedBox(
                                                              width: 349.0,
                                                              height: 272.0,
                                                              child: isLoading
                                                                  ? const CustomSpinner(
                                                                      color: Color(
                                                                          0xff13322b), // Change the spinner color if needed
                                                                      size:
                                                                          60.0, // Change the size of the spinner if needed
                                                                    )
                                                                  : Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // Title
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top:
                                                                                  16.0,
                                                                              bottom:
                                                                                  8.0),
                                                                          child:
                                                                              Text(
                                                                            "Confirmation",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  20,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        // Content
                                                                        const Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  24.0),
                                                                          child:
                                                                              Text(
                                                                            "Are you sure you want to confirm?",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  13,
                                                                              fontWeight:
                                                                                  FontWeight.normal,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // Divider
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left:
                                                                                  20,
                                                                              right:
                                                                                  20),
                                                                          child: Divider(
                                                                              thickness:
                                                                                  1),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // No Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xffD3D3D3), // No button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context).pop(); // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "No",
                                                                                style:
                                                                                    TextStyle(color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                12.0), // Spacing between buttons
                                                                        // Yes Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xff012169), // Amber button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () async {
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(true));
                                                                                try {
                                                                                  final response = await http.post(
                                                                                    Uri.parse('$apiUrl/api/admin/update_admission'),
                                                                                    headers: {
                                                                                      'Content-Type': 'application/json',
                                                                                      'supabase-url': supabaseUrl,
                                                                                      'supabase-key': supabaseKey,
                                                                                    },
                                                                                    body: json.encode({
                                                                                      'admission_id': myformDetails[0]['admission_id'], // Send admission_id in the request body
                                                                                      'is_pre_require': true,
                                                                                      'user_id': widget.userId,
                                                                                      'is_done': true,
                                                                                    }),
                                                                                  );
                
                                                                                  if (response.statusCode == 200) {
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    setState(() {
                                                                                      updateData(document[index]['admission_id']);
                                                                                      //bool isDone = checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(document));
                                                                                    });
                                                                                    // Show success modal
                                                                                    context.read<AdmissionBloc>().add(IsLoadingClicked(false));
                                                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) {
                                                                                        return Dialog(
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                          ),
                                                                                          child: Container(
                                                                                            width: 349,
                                                                                            height: 272,
                                                                                            padding: const EdgeInsets.all(16),
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                // Centered Text
                                                                                                const Center(
                                                                                                    // child: Text(
                                                                                                    //   "",
                                                                                                    //   style: TextStyle(
                                                                                                    //     fontSize: 20,
                                                                                                    //   ),
                                                                                                    //   textAlign: TextAlign.center,
                                                                                                    // ),
                                                                                                    ),
                                                                                                // Red X Icon with Circular Outline
                                                                                                Column(
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      width: 90,
                                                                                                      height: 90,
                                                                                                      decoration: BoxDecoration(
                                                                                                        shape: BoxShape.circle,
                                                                                                        border: Border.all(color: const Color(0XFF012169), width: 2),
                                                                                                      ),
                                                                                                      child: const Center(
                                                                                                        child: Icon(
                                                                                                          Icons.check,
                                                                                                          color: Color(0XFF012169),
                                                                                                          size: 40,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    const SizedBox(height: 20),
                                                                                                    // No Form Submitted Text
                                                                                                    const Text(
                                                                                                      "Done updating data",
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                      textAlign: TextAlign.center,
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                // Divider
                                                                                                const Divider(
                                                                                                  thickness: 1,
                                                                                                  color: Colors.grey,
                                                                                                ),
                                                                                                // Close Button
                                                                                                Align(
                                                                                                  alignment: Alignment.bottomCenter,
                                                                                                  child: ElevatedButton(
                                                                                                    onPressed: () {
                                                                                                      Navigator.of(context).pop(); // Close the modal
                                                                                                    },
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                      backgroundColor: const Color(0xff012169), // Button color
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                                      ),
                                                                                                      minimumSize: const Size(double.infinity, 50), // Expand width and set height
                                                                                                    ),
                                                                                                    child: const Text(
                                                                                                      "Close",
                                                                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  } else {
                                                                                    // Handle failure
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    print('Error: ${responseBody['error']}');
                                                                                    Navigator.of(context).pop();
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (context) => AlertDialog(
                                                                                        title: const Text("Error"),
                                                                                        content: Text("Failed to complete review: ${responseBody['error']}"),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () {
                                                                                              Navigator.of(context).pop(); // Close dialog
                                                                                            },
                                                                                            child: const Text("OK"),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }
                                                                                } catch (error) {
                                                                                  // Handle network error
                                                                                  print('Error: $error');
                                                                                  Navigator.of(context).pop();
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => AlertDialog(
                                                                                      title: const Text("Error"),
                                                                                      content: const Text("An unexpected error occurred. Please try again later."),
                                                                                      actions: [
                                                                                        TextButton(
                                                                                          onPressed: () {
                                                                                            Navigator.of(context).pop(); // Close dialog
                                                                                          },
                                                                                          child: const Text("OK"),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                } // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "Yes",
                                                                                style:
                                                                                    TextStyle(color: Colors.white),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff007937),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(10)
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'SAVE',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ))
                            ]
                        )
                        
                      ]);
                    }
                    return Container();
                    }
                  )
              )

          
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
                fontSize: 12 * scale,
                fontFamily: 'Roboto-B',
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


  Widget _buildParentColumn({
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
            Tooltip(
              message: value, // Full name shown on hover
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xff012169),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              child: SizedBox(
                width: 120,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Roboto-B',
                    fontSize: 12 * scale,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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


  bool checkDocumentRequirements(
      String gradeLevel, List<Map<String, dynamic>> formRequirements) {
    // Define the list of required doc_ids based on the grade level
    List<int> requiredDocIds;

    // Check the gradeLevel and set the required doc_ids accordingly
    if (gradeLevel.toLowerCase() == 'pre-kinder' ||
        gradeLevel.toLowerCase() == 'kinder') {
      requiredDocIds = [
        1,
        2,
        4
      ]; // For 'pre-kinder' or 'kinder', require doc_ids 1, 2, and 4
    } else {
      if(gradeLevel.toLowerCase() == 'grade 1'){
        requiredDocIds = [
          1,
          2,
          5,
          14,
          15
        ];
      }else{
        requiredDocIds = [
          1,
          2,
          3,
          5,
          14,
          15
        ];
      } // For other grade levels, require doc_ids 1, 2, 3, and 5
    }

    // Loop through the required doc_ids
    for (int docId in requiredDocIds) {
      bool docFound = false;

      // Check if each doc_id (from requiredDocIds) is in the formRequirements and has 'accepted' status
      for (var requirement in formRequirements) {
        if (requirement['db_requirement_type_table'] != null) {
          var requirementDocId =
              requirement['db_requirement_type_table']['doc_id'];
          var documentStatus = requirement['document_status'];

          // If we find the document with the required doc_id and 'accepted' status, mark it as found
          if (requirementDocId == docId && documentStatus == 'accepted') {
            docFound = true;
            break; // No need to check further for this docId, move on to the next docId
          }
        }
      }

      // If any required document (from requiredDocIds) is missing or not 'accepted', return false
      if (!docFound) {
        return false; // Exit early, because we found a missing or not accepted document
      }
    }

    // If all required docs (1, 2, 3, 4, or 5) are found with 'accepted' status, return true
    return true;
  }

  // Show image dialog when image is clicked
  
  
void showUploadDialog(
      BuildContext context, int admissionId, StateSetter setState) {
    bool _isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
            backgroundColor: const Color(0xffffffff),
            content: SizedBox(
                                                          width: 349.0,
                                                          height: 450,
                                                          child: _isLoading
                                                              ? const CustomSpinner(
                                                                  color: Color(
                                                                      0xff13322b), // Change the spinner color if needed
                                                                  size:
                                                                      60.0, // Change the size of the spinner if needed
                                                                )
                                                              : Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Title
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              16.0,
                                                                          bottom:
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Upload Recommendation File",
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    // Content
                                                                     Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                                        child: Container(
                                                                          child: Column(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 200,
                                                                                height: 40,
                                                                                child: ElevatedButton(
                                                                                  onPressed: !isSelect
                                                                                      ? () {
                                                                                          _pickFiles(setState);
                                                                                          isSelect=true; // Open the file picker
                                                                                        }
                                                                                      : null,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                    ),
                                                                                    backgroundColor: !isSelect
                                                                                        ? const Color(0xff012169)
                                                                                        : const Color(0xffD3D3D3),
                                                                                  ),
                                                                                  child: Text(
                                                                                    'Select File',
                                                                                    style: TextStyle(
                                                                                      color: !isSelect
                                                                                          ? const Color(0xffffffff)
                                                                                          : const Color(0xff000000),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              if (_selectedFiles.isNotEmpty) const SizedBox(height: 5),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),

                                                                        if (_selectedFiles.isNotEmpty)
                                                                                SizedBox(
                                                                                  height: 200,
                                                                                  child: SingleChildScrollView(
                                                                                    child: Column(
                                                                                      children: _selectedFiles.asMap().entries.map((entry) {
                                                                                        int index = entry.key;
                                                                                        var file = entry.value;
                                                                                        return Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              width: 250,
                                                                                              child: Text(
                                                                                                file.name,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                style: const TextStyle(color: Color(0xff13322b)),
                                                                                              ),
                                                                                            ),
                                                                                            IconButton(
                                                                                              icon: const Icon(
                                                                                                Icons.delete,
                                                                                                color: Color(0xff13322b),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                setState(() {
                                                                                                  _selectedFiles.removeAt(index);
                                                                                                  isSelect=false;
                                                                                                });
                                                                                              },
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                      }).toList(),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                              
                                                                     SizedBox(height:_selectedFiles.isEmpty?155:25),
                                                                    // Divider
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                      child: Divider(
                                                                          thickness:
                                                                              1),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16.0),
                                                                    // No Button
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              30.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            289,
                                                                        height:
                                                                            35,
                                                                        child:
                                                                            TextButton(
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:
                                                                                const Color(0xffD3D3D3), // No button color
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                                _selectedFiles=[];
                                                                            Navigator.of(context).pop(); // Close dialog
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12.0), // Spacing between buttons
                                                                    // Yes Button
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              30.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            289,
                                                                        height:
                                                                            35,
                                                                        child:
                                                                            TextButton(
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:_selectedFiles.isNotEmpty?
                                                                                const Color(0xff012169):  Color(0xffD3D3D3), // Amber button color
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                          onPressed: _selectedFiles.isNotEmpty? () async {
                                                                             try{
                                                                                if(_selectedFiles.isEmpty){
                                                                                  _showMessage('Please select a recommendation file to upload', "error");
                                                                                  setState(() {
                                                                                    _selectedFiles = [];
                                                                                  });
                                                                                }else{
                                                                                  setState(() {
                                                                                    _isLoading = true; // Start loading
                                                                                  });
                                                                                  bool isDone = await uploadFile('document_upload',_selectedFiles, admissionId.toString());
                                                                                  if(isDone){
                                                                                    
                                                                                    bool isStated = await _uploadRecommendation(
                                                                                      '16',
                                                                                      admissionId.toString(),
                                                                                      'document_upload',
                                                                                      'accepted'
                                                                                    );
                                                                
                                                                                    setState(() {
                                                                                      _selectedFiles = [];
                                                                                      _isLoading = false; // Stop loading
                                                                                      
                                                                                    });
                                                                                      
                                                                                    if (isStated) {
                                                                                      updateData(admissionId);
                                                                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                      _selectedFiles = [];
                                                                                      isSelect=false;
                                                                                      _showMessage('Pre-Requirement for: $admissionId has been uploaded',
                                                                                          'Upload Completed');
                                                                                    } else {
                                                                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                      _selectedFiles = [];
                                                                                      isSelect=false;
                                                                                      _showMessage('File upload failed. The file size exceeds the 4 MB limit. Please ensure the file is under 4 MB in size.',
                                                                                          'error');
                                                                                    }

                                                                                  }
                                                                                }
                                                                              }catch(error){
                                                                                _selectedFiles = [];
                                                                                isSelect=false;
                                                                                _showMessage('Connection timeout', "error");
                                                                              }
                                                                          }:null,
                                                                          child:
                                                                               Text(
                                                                            "Upload",
                                                                            style:
                                                                                TextStyle(color: _selectedFiles.isNotEmpty? Colors.white:const Color(0xff000000)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                        ),
            
          );
          }
        );
      },
    );
  }

  //message alert box
  void _showMessage(String message, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Container(
      width: 349,
      height: 272,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Centered Text
          const Center(
              // child: Text(
              //   "",
              //   style: TextStyle(
              //     fontSize: 20,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              ),
          // Red X Icon with Circular Outline
          Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: title!='error'? const Color(0XFF012169) : const Color(0XFFE15252), width: 2),
                ),
                child:  Center(
                  child: Icon(title!='error'?
                    Icons.check:Icons.close_rounded,
                    color: title!='error'?const  Color(0XFF012169):const Color(0XFFE15252),
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // No Form Submitted Text
               Text(message,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Divider
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          // Close Button
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff012169), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50), // Expand width and set height
              ),
              child: const Text(
                "Close",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
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
        final Tangent tangent = pathMetric.getTangentForOffset(distance) ??
            const Tangent(Offset.zero, Offset.zero);

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