import 'package:flutter/material.dart';

import 'package:shopping_list_app/components/modules/popup_container.dart';

enum States {
  general,
  category,
  favorite,
}

class NewProductPopup extends StatefulWidget {
  const NewProductPopup({Key? key}) : super(key: key);

  @override
  State<NewProductPopup> createState() => _NewProductPopupState();
}

class _NewProductPopupState extends State<NewProductPopup> {
  // final States _state = States.general;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nouveau produit", style: theme.textTheme.headline2),
          const SizedBox(height: 6),
          Text("Ajouter un nouveau produit.", style: theme.textTheme.subtitle1),
          const SizedBox(height: 29),

          // General Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nom du produit", style: theme.textTheme.bodyText1),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      borderSide: BorderSide(
                        color: Color.fromRGBO(187, 195, 208, 1),
                        width: 0.2,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a text.';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processing data....")),
                      );
                    }
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
