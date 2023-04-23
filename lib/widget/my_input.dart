import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  final TextEditingController textController;
  final String hintext;
  const MyInput({
    super.key,
    required this.textController,
    required this.hintext,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        fillColor: Colors.white,
        filled: true,
        hintText: hintext,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
    );
  }
}
