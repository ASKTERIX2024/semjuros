import 'dart:async';
import 'package:flutter/material.dart';

class DebouncedTextField extends StatefulWidget {
  final Duration delay;
  final void Function(String) onDebouncedChanged;
  final InputDecoration? decoration;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const DebouncedTextField({
    Key? key,
    required this.delay,
    required this.onDebouncedChanged,
    this.decoration,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _DebouncedTextFieldState createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(widget.delay, () {
      widget.onDebouncedChanged(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      decoration: widget.decoration,
      onChanged: _onChanged,
    );
  }
}