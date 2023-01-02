import 'package:flutter/cupertino.dart';
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
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
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.products.length,
          shrinkWrap: true,
          itemBuilder: (context, index) => Column(
            children: [
              widget.products[index],
              const SizedBox(height: 9),
            ],
          ),
        ),
      ],
    );
  }
}
