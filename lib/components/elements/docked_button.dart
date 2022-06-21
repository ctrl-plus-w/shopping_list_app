import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class DockedButton extends StatefulWidget {
  const DockedButton({Key? key}) : super(key: key);

  @override
  State<DockedButton> createState() => _DockedButtonState();
}

class _DockedButtonState extends State<DockedButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color.fromRGBO(187, 195, 208, 1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(32, 94, 187, 0),
              blurRadius: 1,
              offset: Offset(1, 1),
              spreadRadius: 0,
            )
          ],
        ),
        width: 60.0,
        height: 60.0,
        child: MaterialButton(
          onPressed: () {},
          child: SvgPicture.asset("assets/add.svg"),
        ),
      ),
      onPressed: () {},
    );
  }
}
