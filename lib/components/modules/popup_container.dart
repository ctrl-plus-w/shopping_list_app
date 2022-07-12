import 'dart:ui';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// States
import 'package:shopping_list_app/states/screen_manager.dart';

class PopupContainer extends StatefulWidget {
  final Widget? child;

  const PopupContainer({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  State<PopupContainer> createState() => _PopupContainerState();
}

class _PopupContainerState extends State<PopupContainer> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final close = Navigator.of(context).pop;

    return Consumer<ScreenManager>(
      builder: (context, manager, child) => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: close,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
          Container(
            height: height * 0.86,
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 37,
                  spreadRadius: 0,
                  color: Color.fromRGBO(28, 48, 72, 0.24),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      primary: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: close,
                    child: SvgPicture.asset('assets/close.svg'),
                  ),
                ),
                widget.child ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
