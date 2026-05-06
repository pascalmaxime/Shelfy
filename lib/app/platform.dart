import 'package:flutter/foundation.dart';

bool get isDesktopPlatform =>
    defaultTargetPlatform != TargetPlatform.iOS &&
    defaultTargetPlatform != TargetPlatform.android;
