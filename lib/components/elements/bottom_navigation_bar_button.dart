import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class BottomNavigationBarButton extends StatelessWidget {
  final void Function() onPressed;
  final String iconPath;
  final String label;

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.zero,
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
  );

  BottomNavigationBarButton({
    Key? key,
    required this.onPressed,
    required this.iconPath,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: raisedButtonStyle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color.fromRGBO(107, 121, 134, 1),
            ),
          ),
        ],
      ),
    );
  }
}
