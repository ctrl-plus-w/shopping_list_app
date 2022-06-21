import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shopping_list_app/components/elements/product.dart';

class ProductCategory extends StatefulWidget {
  final String name;
  final List<Product> products;

  const ProductCategory({
    Key? key,
    required this.name,
    this.products = const [],
  }) : super(key: key);

  @override
  State<ProductCategory> createState() => _ProductCategoryState();
}

class _ProductCategoryState extends State<ProductCategory> {
  static List<Widget> getProducts(List<Widget> products) {
    List<Widget> widgets = [];

    for (Widget product in products) {
      widgets.add(product);
      widgets.add(const SizedBox(height: 9));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: const TextStyle(
            color: Color.fromRGBO(33, 51, 67, 1),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 16),
        ...getProducts(widget.products),
      ],
    );
  }
}
