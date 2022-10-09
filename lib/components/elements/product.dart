import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';

class Product extends StatefulWidget {
  final String name;
  final Unit unit;
  final int quantity;
  final bool striked;

  const Product({
    Key? key,
    required this.name,
    required this.unit,
    this.quantity = 1,
    this.striked = false,
  }) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    final double opacity = widget.striked ? 0.4 : 1;
    final ThemeData theme = Theme.of(context);

    return Row(
      children: [
        // Left Label Container
        Container(
          width: 52,
          padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 5.5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            border: Border.all(
                color:
                    const Color.fromRGBO(187, 195, 208, 1).withOpacity(opacity),
                width: 0.2),
            borderRadius: const BorderRadius.all(Radius.circular(5.5)),
            boxShadow: [
              BoxShadow(
                blurRadius: 1.85,
                color: const Color.fromRGBO(207, 208, 208, 0.28)
                    .withOpacity(opacity),
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Text(
            "${widget.quantity} ${widget.unit.name}.",
            style: TextStyle(
              fontSize: 11,
              color:
                  const Color.fromRGBO(107, 121, 134, 1).withOpacity(opacity),
            ),
          ),
        ),

        // Gap
        const SizedBox(width: 11),

        // Product name
        Expanded(
          child: Dismissible(
            key: Key(widget.name),
            confirmDismiss: (direction) async => false,
            background: Container(
              decoration: const BoxDecoration(),
              // color: Colors.yellow,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  'assets/favorite_illustration_xs.svg',
                  height: 32,
                ),
              ),
            ),
            secondaryBackground: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(236, 53, 53, 0.5),
                    Color.fromRGBO(236, 53, 53, 0)
                  ],
                  stops: [0.8, 1],
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SvgPicture.asset(
                  'assets/delete.svg',
                  height: 24,
                ),
              ),
            ),
            child: SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.name,
                  style: theme.textTheme.bodyText1!.merge(
                    TextStyle(
                      decoration: widget.striked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: const Color.fromRGBO(33, 51, 67, 1)
                          .withOpacity(opacity),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
