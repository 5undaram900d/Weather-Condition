

import 'package:flutter/material.dart';

class CustomThemes{

  static final lightTheme = ThemeData(
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.grey[800],
    iconTheme: IconThemeData(
      color: Colors.grey[600],
    ),
  );

  static final darkTheme = ThemeData(
    cardColor: Colors.grey,
    scaffoldBackgroundColor: Colors.black12,
    primaryColor: Colors.white,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  );

}