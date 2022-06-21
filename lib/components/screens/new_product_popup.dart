import 'package:flutter/material.dart';

import 'package:shopping_list_app/components/modules/popup_container.dart';

class NewProductPopup extends StatelessWidget {
  const NewProductPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PopupContainer(
      child: SizedBox(
        width: double.infinity,
        child: Text("Popup content..."),
      ),
    );
  }
}
