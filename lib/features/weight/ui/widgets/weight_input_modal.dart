import 'package:flutter/material.dart';

class WeightInputModal extends StatefulWidget {
  final double initialWeight;
  final double? initialMuscle;
  final double? initialFat;
  final Function(double, double?, double?, String?) onSave;

  const WeightInputModal({
    super.key,
    required this.initialWeight,
    this.initialMuscle,
    this.initialFat,
    required this.onSave,
  });

  @override
  State<WeightInputModal> createState() => _WeightInputModalState();
}

class _WeightInputModalState extends State<WeightInputModal> {
  late FixedExtentScrollController _intController;
  late FixedExtentScrollController _decimalController;
  late int _selectedInt;
  late int _selectedDecimal;
  
  late TextEditingController _muscleController;
  late TextEditingController _fatController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedInt = widget.initialWeight.floor();
    _selectedDecimal = ((widget.initialWeight - _selectedInt) * 10).round();
    if (_selectedInt == 0) _selectedInt = 60; // Default if 0

    _intController = FixedExtentScrollController(initialItem: _selectedInt);
    _decimalController = FixedExtentScrollController(initialItem: _selectedDecimal);
    
    _muscleController = TextEditingController(text: widget.initialMuscle?.toString() ?? '');
    _fatController = TextEditingController(text: widget.initialFat?.toString() ?? '');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _intController.dispose();
    _decimalController.dispose();
    _muscleController.dispose();
    _fatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : theme.cardColor;
    final surfaceColor = isDark ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? const Color(0xFF666666) : Colors.grey[600]!;
    final labelColor = isDark ? const Color(0xFF666666) : Colors.grey[700]!;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Weight (kg)', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          
          // Wheel Picker
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Integer Wheel
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        controller: _intController,
                        itemExtent: 60,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) => setState(() => _selectedInt = index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final isSelected = index == _selectedInt;
                            return Center(
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 40 : 24,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? textColor : (isDark ? Colors.grey[800] : Colors.grey[400]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('.', style: TextStyle(color: textColor, fontSize: 40, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    // Decimal Wheel
                    SizedBox(
                      width: 60,
                      child: ListWheelScrollView.useDelegate(
                        controller: _decimalController,
                        itemExtent: 60,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) => setState(() => _selectedDecimal = index),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            if (index > 9) return null;
                            final isSelected = index == _selectedDecimal;
                            return Center(
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 40 : 24,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? textColor : (isDark ? Colors.grey[800] : Colors.grey[400]),
                                ),
                              ),
                            );
                          },
                          childCount: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Extra Fields
          _buildTextField('Skeletal muscle', _muscleController, 'kg', surfaceColor, textColor, hintColor, labelColor, theme),
          const SizedBox(height: 16),
          _buildTextField('Body fat', _fatController, '%', surfaceColor, textColor, hintColor, labelColor, theme),
          
          const SizedBox(height: 24),
          
          // Notes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                hintStyle: TextStyle(color: hintColor, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                icon: Icon(Icons.edit_note, color: hintColor),
              ),
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          
          const Spacer(),
          
          // Buttons
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Cancel', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final weight = _selectedInt + (_selectedDecimal / 10.0);
                    final muscle = double.tryParse(_muscleController.text);
                    final fat = double.tryParse(_fatController.text);
                    final notes = _notesController.text;
                    widget.onSave(weight, muscle, fat, notes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF2C2C2C) : theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String suffix, 
      Color surfaceColor, Color textColor, Color hintColor, Color labelColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0',
                    hintStyle: TextStyle(color: hintColor.withOpacity(0.5)),
                  ),
                  style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: theme.primaryColor,
                ),
              ),
              Text(
                suffix,
                style: TextStyle(color: hintColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
