import 'package:flutter/material.dart';
import '../../resources/app_color.dart';

class TdTextField extends StatelessWidget {
  const TdTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.hintText,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.textInputAction,
    this.validator,
    this.readOnly = false, 
    this.obscureText = false,
    });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? hintText;
  final Icon? prefixIcon;
  final Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator; //muon validate phai co dong nay va gan phia duoi 
  final bool readOnly;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outlineInputBorder(Color color) => OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 1.2),
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        );

    return Stack(
      children: [
        Container(
          height: 48.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: const [
              BoxShadow(
                color: AppColor.shadow,
                offset: Offset(0.0, 3.0),
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          validator: validator,
          readOnly: readOnly,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.6),
            filled: true,
            fillColor: Colors.pink.shade50,
            border: outlineInputBorder(AppColor.green),
            focusedBorder: outlineInputBorder(AppColor.blue),
            enabledBorder: outlineInputBorder(AppColor.green),
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColor.grey),
            labelText: hintText,
            prefixIcon: prefixIcon,
            errorStyle: const TextStyle(color: AppColor.red),
          ),
        ),
      ],
    );
  }
}
