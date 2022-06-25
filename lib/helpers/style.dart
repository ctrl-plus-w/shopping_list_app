import 'package:flutter/material.dart';

Border borderUnlessLeft(BorderSide border) =>
    Border(bottom: border, right: border, top: border);

Border borderUnlessRight(BorderSide border) =>
    Border(bottom: border, left: border, top: border);

Border borderUnlessTop(BorderSide border) =>
    Border(bottom: border, right: border, left: border);

Border borderUnlessBottom(BorderSide border) =>
    Border(left: border, right: border, top: border);
