import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

@immutable
class BottomNavigationBarButton extends StatelessWidget {
  final void Function() onPressed;
  final String iconPath;
  final String label;
  final bool active;

  const BottomNavigationBarButton({
    Key? key,
    required this.onPressed,
    required this.iconPath,
    required this.label,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: raisedButtonStyle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(iconPath,
              color: active ? const Color.fromRGBO(32, 94, 187, 1) : null),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active
                  ? const Color.fromRGBO(32, 94, 187, 1)
                  : const Color.fromRGBO(107, 121, 134, 1),
            ),
          ),
        ],
      ),
    );
  }
}
