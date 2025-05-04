import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../services/local/shared_pref.dart';

class AppBar extends StatefulWidget implements PreferredSizeWidget {
  AppBar({
    super.key,
    this.iconPressed,
    this.color,
    Icon? icon,
    required this.title,
  }) : icon = icon ??
            Icon(
              Icons.arrow_back_ios_new,
              color: Colors.brown.withOpacity(0.8),
            );

  final Function()? iconPressed;
  final Color? color;
  final Icon icon;
  final String title;

  @override
  State<AppBar> createState() => _AppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(86.0);
}

class _AppBarState extends State<AppBar> {
  SharedPrefs prefs = SharedPrefs();
  String? avatarPath;

  @override
  void initState() {
    super.initState();
    // _getAvatar();
  }

  // Future<void> _pickAvatar() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //   );
  //   if (result != null) {
  //     prefs.saveAvatarPath(result.files.single.path!);
  //   }
  // }

  // void _getAvatar() {
  //   prefs.getAvatarPath().then((strAvatar) {
  //     if (strAvatar == null) return;
  //     File(strAvatar).exists().then((value) {
  //       if (value) {
  //         avatarPath = strAvatar;
  //         setState(() {});
  //       }else{
  //         avatarPath = null;
  //         setState(() {});
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 20.0,
          top: MediaQuery.of(context).padding.top + 6.0,
          right: 16.0,
          bottom: 12.0),
      color: widget.color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: widget.iconPressed,
            child: Transform.rotate(
              angle: 45 * math.pi / 180,
              child: Container(
                padding: const EdgeInsets.all(6.8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: Transform.rotate(
                    angle: -45 * math.pi / 180, child: widget.icon),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Shimmer.fromColors(
              baseColor: Colors.red,
              highlightColor: Colors.yellow,
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () async {
          //     await _pickAvatar();
          //     _getAvatar();
          //   },
          //   // child: AppAvatar(imagePath: avatarPath),
          // ),
        ],
      ),
    );
  }
}
