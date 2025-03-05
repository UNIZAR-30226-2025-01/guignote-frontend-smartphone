///
///
///
///
///
library;

import 'package:flutter/material.dart';


class CustomTextForm extends StatelessWidget
{
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;


  const CustomTextForm
  (
    {
      super.key,
      required this.hintText,
      this.prefixIcon,
      required this.controller,
      this.obscureText = false,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.suffixIcon,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return TextFormField
    (
      key: key,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration
      (
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.grey.shade400,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.black45) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder
        (
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}