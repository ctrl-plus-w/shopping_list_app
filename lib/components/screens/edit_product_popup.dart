import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/components/modules/search_input.dart';
import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/category/category.dart';

// Models
import 'package:shopping_list_app/database/models/product/product.dart';

// Modules
import 'package:shopping_list_app/components/modules/popup_container.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:shopping_list_app/states/cart_manager.dart';
import 'package:slugify/slugify.dart';

class EditProductPopup extends StatefulWidget {
  final Product product;

  const EditProductPopup({
    required this.product,
    Key? key,
  }) : super(key: key);

  @override
  State<EditProductPopup> createState() => _EditProductPopupState();
}

class _EditProductPopupState extends State<EditProductPopup> {
  final _formKey = GlobalKey<FormState>();

  final _categoryInputController = TextEditingController();

  late TextEditingController _nameInputController;
  late TextEditingController _quantityInputController;
  late TextEditingController _categorySelectedController;
  late String _quantityType;

  late List<Unit> _units;
  late List<Category> _categories;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.database.whenComplete(() async {
      List<Unit> units = await Unit.getAll();
      List<Category> categories = await Category.getAll();

      setState(() {
        _categorySelectedController =
            TextEditingController(text: widget.product.category.name);
        _nameInputController = TextEditingController(text: widget.product.name);
        _quantityInputController =
            TextEditingController(text: widget.product.quantity.toString());

        _quantityType = widget.product.unit.name;

        _units = units;
        _categories = categories;

        _isLoading = false;
      });
    });
  }

  Future<void> submit(Function refreshProducts) async {
    final unit = _units.firstWhere((u) => u.slug == _quantityType);
    final category = await Category.getByName(_categorySelectedController.text);
    final name = _nameInputController.text;
    final quantity = int.parse(_quantityInputController.text);

    widget.product
      ..name = name
      ..quantity = quantity
      ..unit = unit;

    if (category != null) widget.product.category = category;

    widget.product.update();

    // Refresh the products before closing the popup
    await refreshProducts();

    // Because the func is async, we need to check if the component is mounted before calling the Navigator.
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    final theme = Theme.of(context);

    if (_isLoading) {
      // TODO : When loading, show the skeleton instead of the shrinked box.
      return const SizedBox.shrink();
    }

    return Consumer<CartManager>(
      builder: (context, cartManager, child) => PopupContainer(
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.name, style: theme.textTheme.headline2),
              const SizedBox(height: 6),
              Text("Modifier un produit.", style: theme.textTheme.subtitle1),
              const SizedBox(height: 29),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        controller: _nameInputController,
                        style: theme.textTheme.bodyText1!
                            .merge(formInputTextStyle),
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
                              controller: _quantityInputController,
                              style: theme.textTheme.bodyText1!
                                  .merge(formInputTextStyle),
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
                              value: widget.product.unit.name,
                              items: _units
                                  .map((unit) => DropdownMenuItem<String>(
                                        value: unit.slug,
                                        child: Text(unit.name),
                                      ))
                                  .toList(),
                              onChanged: (String? value) async {
                                if (value != null) {
                                  _quantityType = value;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SearchInput<Category>(
                label: 'Nom de la catégorie',
                formKey: _formKey,
                data: _categories,
                controller: _categoryInputController,
                valueController: _categorySelectedController,
                //
                emptyErrorMessage: 'Veuillez entrer un nom pour la catégorie.',
                duplicationErrorMessage: 'La catégorie existe déjà.',
                //
                getSlug: (dynamic category) => category.slug,
                getLabel: (dynamic category) => category.name,
                getId: (dynamic category) => category.id ?? 1,
                //
                addElement: (String label) async {
                  Category category = Category(
                    name: label,
                    slug: slugify(label),
                  );
                  category.id = await category.insert();
                  return category;
                },
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/arrow_left.svg'),
                        const SizedBox(width: 8),
                        const Text('Annuler'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        submit(cartManager.refreshProducts);
                      }
                    },
                    child: const Text('Modifier'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
