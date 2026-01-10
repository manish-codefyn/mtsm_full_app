import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;
  final String? hintText;

  const CustomSearchBar({
    super.key, 
    this.controller,
    required this.onChanged,
    this.hintText,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _internalController;

  TextEditingController get _effectiveController => widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _effectiveController,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Search...',
        prefixIcon: const Icon(Icons.search, color: Colors.blue),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            _effectiveController.clear();
            widget.onChanged('');
          },
        ),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
