import 'package:flutter/material.dart';

// Define a custom widget for the dropdown
class GradeLevelDropdown extends StatelessWidget {
  final String? selectedLevel;
  final ValueChanged<String?> onChanged;

  // Constructor to accept selectedLevel and callback function
  GradeLevelDropdown({
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLevel,
      hint: Text("Select Level"),
      items: [
        'Pre-Kinder', 'Kinder', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
        'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12', 'All'
      ].map((String level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(level),
        );
      }).toList(),
      onChanged: onChanged,  // Pass the callback function for handling changes
    );
  }
}
