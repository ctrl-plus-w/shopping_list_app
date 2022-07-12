import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Modules
import 'package:shopping_list_app/components/modules/popup_container.dart';
import 'package:shopping_list_app/components/modules/search_input.dart';

// Database
import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/category/category.dart';

// Models
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:slugify/slugify.dart';

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

  List<Unit> _units = <Unit>[];
  List<Category> _categories = <Category>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.database.whenComplete(() async {
      List<Unit> units = await Unit.getAll();
      List<Category> categories = await Category.getAll();

      setState(() {
        _units = units;
        _categories = categories;
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
            // GeneralStepFormCategory(units: _units),
            CategoryStepFormCategory(categories: _categories),
          ],
        ),
      ),
    );
  }
}

class FavoriteStepFormCategory extends StatelessWidget {
  const FavoriteStepFormCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class CategoryStepFormCategory extends StatefulWidget {
  final List<Category> categories;

  const CategoryStepFormCategory({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  State<CategoryStepFormCategory> createState() =>
      _CategoryStepFormCategoryState();
}

class _CategoryStepFormCategoryState extends State<CategoryStepFormCategory> {
  final _formKey = GlobalKey<FormState>();

  final _categoryInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchInput<Category>(
              label: 'Nom de la catégorie',
              formKey: _formKey,
              data: widget.categories,
              controller: _categoryInputController,
              //
              emptyErrorMessage: 'Error1',
              duplicationErrorMessage: 'Error2',
              //
              getSlug: (dynamic category) => category.slug,
              getLabel: (dynamic category) => category.name,
              getId: (dynamic category) => category.id ?? 1,
              //
              addElement: (String label) async {
                Category category = Category(name: label, slug: slugify(label));
                category.id = await category.insert();
                return category;
              },
            ),

            // Space
            const Spacer(),

            // Next Step Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO : Handle the data.
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/arrow_left.svg'),
                      const SizedBox(width: 8),
                      const Text('Général'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO : Handle the data.
                  },
                  child: const Text('Créer le produit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralStepFormCategory extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final List<Unit> units;

  GeneralStepFormCategory({Key? key, required this.units}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    final theme = Theme.of(context);

    // TODO : Make TextFormFields validators.
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
                style: theme.textTheme.bodyText1!.merge(formInputTextStyle),
                decoration: const InputDecoration(hintText: "Tomates")
                    .applyDefaults(theme.inputDecorationTheme),
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
                children: [
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
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
                      value: units[0].name,
                      items: units
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
    );
  }
}
