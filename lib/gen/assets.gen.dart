/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFlagsGen {
  const $AssetsFlagsGen();

  /// File path: assets/flags/gb.png
  AssetGenImage get gb => const AssetGenImage('assets/flags/gb.png');

  /// File path: assets/flags/vn.png
  AssetGenImage get vn => const AssetGenImage('assets/flags/vn.png');

  /// List of all assets
  List<AssetGenImage> get values => [gb, vn];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/google.png
  AssetGenImage get googlePng => const AssetGenImage('assets/icons/google.png');

  /// File path: assets/icons/google.svg
  String get googleSvg => 'assets/icons/google.svg';

  /// File path: assets/icons/search.svg
  String get search => 'assets/icons/search.svg';

  /// List of all assets
  List<dynamic> get values => [googlePng, googleSvg, search];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/asiantech.png
  AssetGenImage get asiantech =>
      const AssetGenImage('assets/images/asiantech.png');

  /// File path: assets/images/background.jpg
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.jpg');

  /// File path: assets/images/default_avatar.jpg
  AssetGenImage get defaultAvatar =>
      const AssetGenImage('assets/images/default_avatar.jpg');

  /// File path: assets/images/default_logo.png
  AssetGenImage get defaultLogo =>
      const AssetGenImage('assets/images/default_logo.png');

  /// File path: assets/images/devplus.png
  AssetGenImage get devplus => const AssetGenImage('assets/images/devplus.png');

  /// File path: assets/images/glints.png
  AssetGenImage get glints => const AssetGenImage('assets/images/glints.png');

  /// File path: assets/images/google.png
  AssetGenImage get google => const AssetGenImage('assets/images/google.png');

  /// File path: assets/images/greenglobal.png
  AssetGenImage get greenglobal =>
      const AssetGenImage('assets/images/greenglobal.png');

  /// File path: assets/images/images.png
  AssetGenImage get images => const AssetGenImage('assets/images/images.png');

  /// File path: assets/images/kozmocom.png
  AssetGenImage get kozmocom =>
      const AssetGenImage('assets/images/kozmocom.png');

  /// File path: assets/images/logo-2021-nho.png
  AssetGenImage get logo2021Nho =>
      const AssetGenImage('assets/images/logo-2021-nho.png');

  /// File path: assets/images/logoBapSoftware.png
  AssetGenImage get logoBapSoftware =>
      const AssetGenImage('assets/images/logoBapSoftware.png');

  /// File path: assets/images/logo_1.jpg
  AssetGenImage get logo1 => const AssetGenImage('assets/images/logo_1.jpg');

  /// File path: assets/images/onboarding_1.png
  AssetGenImage get onboarding1 =>
      const AssetGenImage('assets/images/onboarding_1.png');

  /// File path: assets/images/onboarding_2.png
  AssetGenImage get onboarding2 =>
      const AssetGenImage('assets/images/onboarding_2.png');

  /// File path: assets/images/onboarding_3.png
  AssetGenImage get onboarding3 =>
      const AssetGenImage('assets/images/onboarding_3.png');

  /// File path: assets/images/png-transparent-fpt-group-computer-software-software-development-information-technology-fpt-software-business-text-service-people.png
  AssetGenImage
  get pngTransparentFptGroupComputerSoftwareSoftwareDevelopmentInformationTechnologyFptSoftwareBusinessTextServicePeople =>
      const AssetGenImage(
        'assets/images/png-transparent-fpt-group-computer-software-software-development-information-technology-fpt-software-business-text-service-people.png',
      );

  /// File path: assets/images/simbleSolutions.png
  AssetGenImage get simbleSolutions =>
      const AssetGenImage('assets/images/simbleSolutions.png');

  /// File path: assets/images/todo_icon.png
  AssetGenImage get todoIcon =>
      const AssetGenImage('assets/images/todo_icon.png');

  /// File path: assets/images/todo_icon_two.png
  AssetGenImage get todoIconTwo =>
      const AssetGenImage('assets/images/todo_icon_two.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    asiantech,
    background,
    defaultAvatar,
    defaultLogo,
    devplus,
    glints,
    google,
    greenglobal,
    images,
    kozmocom,
    logo2021Nho,
    logoBapSoftware,
    logo1,
    onboarding1,
    onboarding2,
    onboarding3,
    pngTransparentFptGroupComputerSoftwareSoftwareDevelopmentInformationTechnologyFptSoftwareBusinessTextServicePeople,
    simbleSolutions,
    todoIcon,
    todoIconTwo,
  ];
}

class Assets {
  const Assets._();

  static const String aEnv = '.env';
  static const $AssetsFlagsGen flags = $AssetsFlagsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();

  /// List of all assets
  static List<String> get values => [aEnv];
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size, this.flavors = const {}});

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
