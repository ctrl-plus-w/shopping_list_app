import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:shopping_list_app/helpers/preferences.dart';

class GeneralStepFormCategory extends StatefulWidget {
  final void Function() setNextState;
  final void Function() setPreviousState;
  final List<Unit> units;
  final String pagePrefPrefix;

  const GeneralStepFormCategory({
    Key? key,
    required this.units,
    required this.setNextState,
    required this.setPreviousState,
    required this.pagePrefPrefix,
  }) : super(key: key);

  @override
  State<GeneralStepFormCategory> createState() =>
      _GeneralStepFormCategoryState();
}

class _GeneralStepFormCategoryState extends State<GeneralStepFormCategory> {
  late Function getPrefPropName;

  late String defaultUnit;

  final _formKey = GlobalKey<FormState>();

  // Input
  late TextEditingController nameInputController;
  late TextEditingController quantityInputController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    defaultUnit = widget.units[0].name;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        getPrefPropName = prefPropNameGetter(widget.pagePrefPrefix, "general");

        nameInputController = TextEditingController(
          text: prefs.getString(getPrefPropName('name')),
        );

        quantityInputController = TextEditingController(
          text: (prefs.getInt(getPrefPropName('quantity')) ?? 1).toString(),
        );

        final quantityType = prefs.getString(getPrefPropName('quantity_type'));
        if (quantityType != null && quantityType.isNotEmpty) {
          defaultUnit = quantityType;
        }

        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    String quantityType = defaultUnit;

    final theme = Theme.of(context);

    if (_isLoading) {
      // TODO : When loading, show the skeleton instead of the shrinked box.
      return const SizedBox.shrink();
    }

    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Input Field
            Text("Nom du produit", style: theme.textTheme.bodyText1),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.11),
                  ),
                ],
              ),
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: nameInputController,
                style: theme.textTheme.bodyText1!.merge(formInputTextStyle),
                decoration: const InputDecoration(hintText: "Tomates")
                    .applyDefaults(theme.inputDecorationTheme),
                validator: (value) {
                  // Check if the string isn't empty.
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom d\'un produit';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input Field
            Text("Quantité", style: theme.textTheme.bodyText1),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.11),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: quantityInputController,
                      style:
                          theme.textTheme.bodyText1!.merge(formInputTextStyle),
                      decoration: const InputDecoration(
                        hintText: "0",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3),
                          ),
                          borderSide: BorderSide(),
                        ),
                      ).applyDefaults(theme.inputDecorationTheme),
                      validator: (value) {
                        // Checks if the field isn't empty and is a real number.
                        const errorMessage =
                            'Vous devez avoir au moins 1 produit.';

                        if (value == null) return errorMessage;

                        final intValue = num.tryParse(value);

                        if (intValue == null || intValue == 0) {
                          return errorMessage;
                        }

                        return null;
                      },
                    ),
                  ),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      style:
                          theme.textTheme.bodyText1!.merge(formInputTextStyle),
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ).applyDefaults(theme.inputDecorationTheme),
                      value: defaultUnit,
                      items: widget.units
                          .map((unit) => DropdownMenuItem<String>(
                                value: unit.slug,
                                child: Text(unit.name),
                              ))
                          .toList(),
                      onChanged: (String? value) async {
                        if (value != null) {
                          quantityType = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Space
            const Spacer(),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Get the SharedPreferences instance and save all the values of the field.
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setInt(
                      getPrefPropName('quantity'),
                      int.parse(quantityInputController.text),
                    );

                    await prefs.setString(
                      getPrefPropName('name'),
                      nameInputController.text,
                    );

                    await prefs.setString(
                      getPrefPropName('quantity_type'),
                      quantityType,
                    );

                    widget.setNextState();
                  }
                },
                child: const Text('Choisir la catégorie'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
