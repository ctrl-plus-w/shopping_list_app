import 'package:flutter/material.dart';

// Modules
import 'package:shopping_list_app/components/modules/popup_container.dart';

// Database
import 'package:shopping_list_app/database/database.dart';

// Models
import 'package:shopping_list_app/database/models/unit/unit.dart';

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

  List<Unit> _units = <Unit>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.database.whenComplete(() async {
      List<Unit> units = await Unit.getAll();
      setState(() {
        _units = units;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PopupContainer(
        child: Text("Loading..."),
      );
    }

    final theme = Theme.of(context);

    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    // TODO : Only the first part of the form is made. Make the others ones and handle switching.

    return PopupContainer(
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nouveau produit", style: theme.textTheme.headline2),
            const SizedBox(height: 6),
            Text("Ajouter un nouveau produit.",
                style: theme.textTheme.subtitle1),
            const SizedBox(height: 29),

            // TODO : Make TextFormFields validators.

            // General Form
            Form(
              key: _formKey,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name Input Field
                    Text("Nom du produit", style: theme.textTheme.bodyText1),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      style:
                          theme.textTheme.bodyText1!.merge(formInputTextStyle),
                      decoration: const InputDecoration(hintText: "Tomates")
                          .applyDefaults(theme.inputDecorationTheme),
                    ),
                    const SizedBox(height: 16),

                    // Quantity Input Field
                    Text("Quantité", style: theme.textTheme.bodyText1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          // TODO : Make the TextFormField a number input.
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            style: theme.textTheme.bodyText1!
                                .merge(formInputTextStyle),
                            decoration: const InputDecoration(
                              hintText: "0",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                ),
                              ),
                            ).applyDefaults(theme.inputDecorationTheme),
                          ),
                        ),
                        Flexible(
                          child: DropdownButtonFormField<String>(
                            style: theme.textTheme.bodyText1!
                                .merge(formInputTextStyle),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                            ).applyDefaults(theme.inputDecorationTheme),
                            value: _units[0].name,
                            items: _units
                                .map((unit) => DropdownMenuItem<String>(
                                      value: unit.slug,
                                      child: Text(unit.name),
                                    ))
                                .toList(),
                            onChanged: (String? value) {
                              // TODO : Handle the change ? What should be done ?
                            },
                          ),
                        ),
                      ],
                    ),

                    // Space
                    const Spacer(),

                    // Next Step Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO : Handle the data.
                        },
                        child: const Text('Choisir la catégorie'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
