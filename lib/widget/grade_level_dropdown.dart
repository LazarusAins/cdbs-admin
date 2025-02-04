import 'package:flutter/material.dart';

class GradeLevelDropdown extends StatefulWidget {
  final List<String> selectedLevels;
  final ValueChanged<List<String>> onChanged;
  final ValueChanged<String> onSortChanged;

  GradeLevelDropdown({
    required this.selectedLevels,
    required this.onChanged,
    required this.onSortChanged,
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
    return Column(
      children: [
        // PopupMenuButton for multi-selection and sorting options
        PopupMenuButton<String>(
          onSelected: (selected) {
            if (selected == 'A-Z' || selected == 'Z-A') {
              setState(() {
                _sortOrder = selected;  // Update the sorting order
              });
              widget.onSortChanged(_sortOrder);  // Notify parent of sorting change
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              // Sorting options with checkboxes (allow only one to be selected)
              PopupMenuItem<String>(
                value: 'A-Z',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      children: [
                        Checkbox(
                          value: _sortOrder == 'A-Z',  // Checked if A-Z is selected
                          onChanged: (bool? isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _sortOrder = 'A-Z';  // Select A-Z
                              }
                            });
                            widget.onSortChanged(_sortOrder);  // Notify parent of sorting change
                          },
                        ),
                        Text('A - Z'),
                      ],
                    );
                  },
                ),
              ),
              PopupMenuItem<String>(
                value: 'Z-A',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Row(
                      children: [
                        Checkbox(
                          value: _sortOrder == 'Z-A',  // Checked if Z-A is selected
                          onChanged: (bool? isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _sortOrder = 'Z-A';  // Select Z-A
                              }
                            });
                            widget.onSortChanged(_sortOrder);  // Notify parent of sorting change
                          },
                        ),
                        Text('Z - A'),
                      ],
                    );
                  },
                ),
              ),
              // Level options with checkboxes for multi-selection
              ...levels.map((level) {
                return PopupMenuItem<String>(
                  value: level,
                  child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        children: [
                          Checkbox(
                            value: widget.selectedLevels.contains(level),
                            onChanged: (bool? isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  widget.selectedLevels.add(level);
                                } else {
                                  widget.selectedLevels.remove(level);
                                }
                              });
                              widget.onChanged(widget.selectedLevels); // Notify parent
                            },
                          ),
                          Text(level),
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ];
          },
          child: const Row(
            children: [
              Icon(Icons.filter_list),
              SizedBox(width: 8),
              Text('Select Level(s) and Sort'),
            ],
          ),
        ),
      ],
    );
  }
}
