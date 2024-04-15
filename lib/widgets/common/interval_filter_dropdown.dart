import 'package:flutter/material.dart';

typedef IntervalFilterValueChanged = void Function(String filter);

class IntervalFilterDropdown extends StatefulWidget {
  final Color iconColor;
  final IntervalFilterValueChanged onChanged;
    final double smFontSize;
  final double iconSize;
  final TextStyle dropDownTextStyle;
  final double responsiveWidth;
  const IntervalFilterDropdown({
    super.key,
    required this.onChanged,
    this.iconColor = Colors.black,
      this.smFontSize = 11,
    this.iconSize = 18,
    this.dropDownTextStyle = const TextStyle(
      fontSize: 14,
    ),  this.responsiveWidth = 380,
  });

  @override
  State<IntervalFilterDropdown> createState() => _IntervalFilterDropdownState();
}

class _IntervalFilterDropdownState extends State<IntervalFilterDropdown> {
  String selectedIntervalFilterDropdown = '';
  List<String> dropdownItems = [
    'SECOND',
    'MINUTE',
    'HOUR',
    'DAY',
    'WEEK',
    'MONTH',
    'YEAR',
  ];

  DateTime selectedDate = DateTime.now();
 
  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    double fontSize = widget.smFontSize;
    double adjustedIconSize =
        screenWidth < widget.responsiveWidth ? widget.iconSize * 0.75 : widget.iconSize;
    return Column(
      children: [
        Row(
          children: [
            DropdownButton<String>(
                hint: Padding(
                  padding: const EdgeInsets.only(right:20),
                  child: Text('INTERVAL',style: screenWidth > widget.responsiveWidth
                  ? widget.dropDownTextStyle
                  : widget.dropDownTextStyle.copyWith(fontSize: fontSize)),
                ),
                icon: selectedIntervalFilterDropdown.isEmpty
                    ? Icon(Icons.filter_list, color: widget.iconColor,size:adjustedIconSize)
                    : const Icon(Icons.filter_list, color: Colors.transparent),
                items: dropdownItems.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: screenWidth > widget.responsiveWidth
                  ? widget.dropDownTextStyle
                  : widget.dropDownTextStyle.copyWith(fontSize: fontSize)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedIntervalFilterDropdown = newValue!;
                  });
                  widget.onChanged(newValue!);
                },
                value: selectedIntervalFilterDropdown.isNotEmpty
                    ? selectedIntervalFilterDropdown
                    : null),
            if (selectedIntervalFilterDropdown.isNotEmpty)
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedIntervalFilterDropdown = '';
                  });
                  widget.onChanged('');
                },
                icon: Icon(Icons.clear, color: Colors.black,size:adjustedIconSize),
              ),
          ],
        ),
      ],
    );
  }
}
