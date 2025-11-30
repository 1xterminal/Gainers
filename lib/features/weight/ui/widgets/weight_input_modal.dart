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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('Weight (kg)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          
          // Wheel Picker
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
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
                                  color: isSelected ? Colors.white : Colors.grey[800],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('.', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
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
                                  color: isSelected ? Colors.white : Colors.grey[800],
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
          _buildTextField('Skeletal muscle', _muscleController, 'kg'),
          const SizedBox(height: 16),
          _buildTextField('Body fat', _fatController, '%'),
          
          const SizedBox(height: 24),
          
          // Notes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes...',
                hintStyle: TextStyle(color: Color(0xFF666666), fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                icon: Icon(Icons.edit_note, color: Color(0xFF666666)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
                child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    backgroundColor: const Color(0xFF2C2C2C),
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

  Widget _buildTextField(String label, TextEditingController controller, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0',
                    hintStyle: TextStyle(color: Color(0xFF333333)),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: Colors.blue,
                ),
              ),
              Text(
                suffix,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
