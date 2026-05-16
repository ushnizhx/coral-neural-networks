import 'package:flutter/material.dart';

const Color kPrimaryTeal = Color(0xFF006067);
const Color kPrimaryContainer = Color(0xFF007B83);
const Color kOnPrimary = Color(0xFFFFFFFF);
const Color kOnPrimaryContainer = Color(0xFFD0FBFF);

const Color kSecondary = Color(0xFF006A66);
const Color kSecondaryContainer = Color(0xFF81F2EB);
const Color kOnSecondary = Color(0xFFFFFFFF);
const Color kOnSecondaryContainer = Color(0xFF006F6A);

const Color kBackgroundLight = Color(0xFFF6FAFE);
const Color kOnBackground = Color(0xFF171C1F);

const Color kCardLowest = Color(0xFFFFFFFF);
const Color kCardLow = Color(0xFFF0F4F8);
const Color kCardHigh = Color(0xFFE4E9ED);
const Color kCardHighest = Color(0xFFDFE3E7);

const Color kBorderGrey = Color(0xFFBDC9CA); // outline-variant
const Color kOutline = Color(0xFF6E797A);

const Color kTextPrimary = Color(0xFF171C1F); // on-surface
const Color kTextSecondary = Color(0xFF3E494A); // on-surface-variant

const Color kHealthyGreen = Color(0xFF006A66); // secondary
const Color kBleachedAmber = Color(0xFFF59E0B);
const Color kDeadRed = Color(0xFFBA1A1A); // error

// Custom styles
TextStyle get kHeadlineStyle => const TextStyle(
      fontFamily: 'Manrope',
      color: kTextPrimary,
      fontWeight: FontWeight.w800,
    );

TextStyle get kBodyStyle => const TextStyle(
      fontFamily: 'Inter',
      color: kTextSecondary,
      fontWeight: FontWeight.w400,
    );

TextStyle get kLabelStyle => const TextStyle(
      fontFamily: 'Inter',
      color: kTextSecondary,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );
