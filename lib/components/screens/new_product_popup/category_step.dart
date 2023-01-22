import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:slugify/slugify.dart';

// Modules
import 'package:shopping_list_app/components/modules/search_input.dart';

// Models
import 'package:shopping_list_app/database/models/category/category.dart';

// Helpers
import 'package:shopping_list_app/helpers/preferences.dart';

class CategoryStepFormCategory extends StatefulWidget {
  final void Function() setNextState;
  final void Function() setPreviousState;
  final List<Category> categories;

  final String pagePrefPrefix;

  final Future<void> Function() submit;
  final bool skipFavoriteStep;

  const CategoryStepFormCategory({
    Key? key,
    required this.categories,
    required this.setNextState,
    required this.setPreviousState,
    required this.submit,
    required this.skipFavoriteStep,
    required this.pagePrefPrefix,
  }) : super(key: key);

  @override
  State<CategoryStepFormCategory> createState() =>
      _CategoryStepFormCategoryState();
}

class _CategoryStepFormCategoryState extends State<CategoryStepFormCategory> {
  late Function getPrefPropName =
      prefPropNameGetter(widget.pagePrefPrefix, "category");

  final _formKey = GlobalKey<FormState>();

  final _categoryInputController = TextEditingController();
  final _categorySelectedController = TextEditingController();

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
              valueController: _categorySelectedController,
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
                    widget.setPreviousState();
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
                  onPressed: () async {
                    if (_categorySelectedController.text.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setString(
                        getPrefPropName('name'),
                        _categorySelectedController.text,
                      );

                      if (widget.skipFavoriteStep) {
                        await widget.submit();
                      } else {
                        widget.setNextState();
                      }
                    }
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
