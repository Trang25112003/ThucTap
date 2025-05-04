import 'package:flutter/material.dart';
import '../../resources/app_color.dart';

class TdElevatedButton extends StatelessWidget {
  TdElevatedButton({
    super.key,
    this.onPressed,
    this.height = 48.0,
    this.color = const Color.fromARGB(255, 48, 122, 51),
    this.borderColor = const Color.fromARGB(255, 61, 155, 65),
    required this.text,
    this.textColor = AppColor.white,
    this.fontSize = 16.0,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(10.0),
        splashColor = splashColor ?? AppColor.yellow.withOpacity(0.8),
        highlightColor = highlightColor ?? AppColor.green.withOpacity(0.8);

  TdElevatedButton.outline({
    super.key,
    this.onPressed,
    this.height = 48.0,
    this.color = AppColor.white,
    this.borderColor = const Color.fromARGB(255, 44, 106, 46),
    required this.text,
    this.textColor = const Color.fromARGB(255, 63, 143, 66),
    this.fontSize = 16.0,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(10.0),
        splashColor = splashColor ?? AppColor.yellow.withOpacity(0.6),
        highlightColor = highlightColor ?? AppColor.green.withOpacity(0.6);

  TdElevatedButton.small({
    super.key,
    this.onPressed,
    this.height = 38.0,
    this.color = AppColor.green,
    this.borderColor = AppColor.green,
    required this.text,
    this.textColor = AppColor.white,
    this.fontSize = 14.6,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(8.0),
        splashColor = splashColor ?? AppColor.yellow.withOpacity(0.8),
        highlightColor = highlightColor ?? AppColor.green.withOpacity(0.8);

  TdElevatedButton.smallOutline({
    super.key,
    this.onPressed,
    this.height = 38.0,
    this.color = AppColor.white,
    this.borderColor = AppColor.green,
    required this.text,
    this.textColor = AppColor.green,
    this.fontSize = 14.6,
    this.icon,
    BorderRadius? borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
    this.isDisable = false,
    Color? splashColor,
    Color? highlightColor,
  })  : borderRadius = borderRadius ?? BorderRadius.circular(8.0),
        splashColor = splashColor ?? AppColor.yellow.withOpacity(0.6),
        highlightColor = highlightColor ?? AppColor.green.withOpacity(0.6);

  final Function()? onPressed;
  final double height;
  final Color color;
  final Color borderColor;
  final String text;
  final Color textColor;
  final double fontSize;
  final Icon? icon;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDisable;
  final Color splashColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: isDisable ==true ? null : onPressed,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: Ink(
          padding: padding,
          height: height,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.4),
            borderRadius: borderRadius,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 4.6),
              ],
              isDisable == true
                  ? Center(
                      child: SizedBox.square(
                        dimension: height - 22.0,
                        child: CircularProgressIndicator(
                            color: textColor, strokeWidth: 2.2),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
