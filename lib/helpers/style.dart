import 'package:flutter/material.dart';

Border borderUnlessLeft(BorderSide border) =>
    Border(bottom: border, right: border, top: border);

Border borderUnlessRight(BorderSide border) =>
    Border(bottom: border, left: border, top: border);

Border borderUnlessTop(BorderSide border) =>
    Border(bottom: border, right: border, left: border);

Border borderUnlessBottom(BorderSide border) =>
    Border(left: border, right: border, top: border);

final ButtonStyle settingsButtonStyle = ButtonStyle(
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  backgroundColor: MaterialStateProperty.all(Colors.white),
  shadowColor: MaterialStateProperty.all(Colors.transparent),
  minimumSize: MaterialStateProperty.all(Size.zero),
  padding: MaterialStateProperty.all(const EdgeInsets.all(7.5)),
  shape: MaterialStateProperty.all(
    const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(
        color: Color.fromRGBO(187, 195, 208, 1),
        width: 0.5,
      ),
    ),
  ),
);
