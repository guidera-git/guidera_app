import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightBlue,
  scaffoldBackgroundColor: AppColors.lightBackground,
  fontFamily: 'ProductSans',
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    foregroundColor: AppColors.lightTextPrimary,
    elevation: 2,
    iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightBlue,
      foregroundColor: AppColors.myWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.lightTextPrimary
    ),
    bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.lightTextPrimary
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.lightBlue,
    secondary: AppColors.darkBlue,
    surface: AppColors.lightSurface,
    background: AppColors.lightBackground,
    onSurface: AppColors.lightTextPrimary,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.lightBlue,
  scaffoldBackgroundColor: AppColors.myBlack,
  fontFamily: 'ProductSans',
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.myBlack,
    foregroundColor: AppColors.myWhite,
    elevation: 2,
    iconTheme: IconThemeData(color: AppColors.myWhite),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightBlue,
      foregroundColor: AppColors.myWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.myWhite
    ),
    bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.myWhite
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.lightBlue,
    secondary: AppColors.darkBlue,
    surface: AppColors.lightBlack,
    background: AppColors.myBlack,
    onSurface: AppColors.myWhite,
  ),
);