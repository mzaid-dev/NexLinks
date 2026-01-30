import 'package:chat_app/core/utils/app_validators.dart';
import 'package:chat_app/core/widgets/common/my_textformfield.dart';
import 'package:flutter/material.dart';

class EditProfileForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController usernameController;
  final TextEditingController experienceController;
  final List<String> expertise;
  final Function(List<String>) onExpertiseChanged;

  const EditProfileForm({
    super.key,
    required this.fullNameController,
    required this.usernameController,
    required this.experienceController,
    required this.expertise,
    required this.onExpertiseChanged,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final TextEditingController _expertiseInputController = TextEditingController();
  bool _isInputEmpty = true;

  @override
  void initState() {
    super.initState();
    _expertiseInputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _expertiseInputController.removeListener(_onInputChanged);
    _expertiseInputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final isEmpty = _expertiseInputController.text.trim().isEmpty;
    if (isEmpty != _isInputEmpty) {
      setState(() {
        _isInputEmpty = isEmpty;
      });
    }
  }

  void _addExpertise() {
    final text = _expertiseInputController.text.trim();
    if (text.isNotEmpty && !widget.expertise.contains(text)) {
       final newList = List<String>.from(widget.expertise)..add(text);
       widget.onExpertiseChanged(newList);
       _expertiseInputController.clear();
    }
  }

  void _removeExpertise(String tag) {
     final newList = List<String>.from(widget.expertise)..remove(tag);
     widget.onExpertiseChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Details",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          _buildRegularTextField(
              "Full Name", "Alex Rivet", widget.fullNameController,
              validator: AppValidators.validateFullName),
          const SizedBox(height: 16),
          
          _buildRegularTextField("Username", "@alexrivet", widget.usernameController,
              validator: AppValidators.validateUsername),
          const SizedBox(height: 16),
          
          _buildRegularTextField(
             "Experience (Years)", "8", widget.experienceController,
             keyboardType: TextInputType.number,
             validator: (value) => (value?.isEmpty ?? true) ? 'Please enter years of experience' : null,
          ),
          
          const SizedBox(height: 24),
          Text("Expertise",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          
          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.expertise.map((tag) => Chip(
              label: Text(tag, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12)),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white70),
              onDeleted: () => _removeExpertise(tag),
            )).toList(),
          ),
          
          if (widget.expertise.isNotEmpty) const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isInputEmpty ? Colors.transparent : const Color(0xFF2979FF).withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _expertiseInputController,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Add skill (e.g. Flutter)",
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: (_) => _addExpertise(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isInputEmpty ? null : _addExpertise,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isInputEmpty 
                      ? Colors.white.withOpacity(0.1) 
                      : const Color(0xFF2979FF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isInputEmpty ? [] : [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4)
                      )
                    ]
                  ),
                  child: Icon(
                    Icons.add_rounded, 
                    color: _isInputEmpty ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3) : Colors.white,
                  ),
                ),
              )
            ],
          )

        ],
      ),
    );
  }

  Widget _buildRegularTextField(
      String label, String placeholder, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return MyTextFormField(
      controller: controller,
      labelText: label,
      hintText: placeholder,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
