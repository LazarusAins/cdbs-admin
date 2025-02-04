import 'package:flutter/material.dart';

class GradeLevelDropdown extends StatefulWidget {
  final List<String> selectedLevels;
  final ValueChanged<List<String>> onChanged;

  // Constructor to accept selectedLevels and callback function for changes
  GradeLevelDropdown({
    required this.selectedLevels,
    required this.onChanged,
  });

  @override
  _GradeLevelDropdownState createState() => _GradeLevelDropdownState();
}

class _GradeLevelDropdownState extends State<GradeLevelDropdown> {
  List<String> levels = [
    'Pre-Kinder', 'Kinder', 'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
    'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12', 'All'
  ];

  String _sortOrder = 'A-Z';  // Default sorting order

  @override
  Widget build(BuildContext context) {
    // Sort levels based on selected order
    levels.sort((a, b) {
      if (_sortOrder == 'A-Z') {
        return a.compareTo(b);
      } else {
        return b.compareTo(a);
      }
    });

    return Column(
      children: [
        // Dropdown for level selection and sorting
        DropdownButton<String>(
          value: null,
          hint: const Text("Select Level"),
          onChanged: (selectedLevel) {
            if (selectedLevel == 'A-Z' || selectedLevel == 'Z-A') {
              // Change the sorting order when A-Z or Z-A is selected
              setState(() {
                _sortOrder = selectedLevel!;
              });
            } else {
              // Handle selection of a grade level
              List<String> updatedSelection = List.from(widget.selectedLevels);
              if (updatedSelection.contains(selectedLevel)) {
                updatedSelection.remove(selectedLevel);
              } else {
                updatedSelection.add(selectedLevel!);
              }
              widget.onChanged(updatedSelection);
            }
          },
          items: [
            'A-Z', 'Z-A', ...levels
          ].map((String level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text(level),
            );
          }).toList(),
        ),
      ],
    );
  }
}
