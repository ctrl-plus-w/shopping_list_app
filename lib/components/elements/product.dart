import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Models
import 'package:shopping_list_app/database/models/product/product.dart'
    as product_model;

typedef DismissActionFunction = void Function(product_model.Product product);

class Product extends StatefulWidget {
  final product_model.Product product;

  final int quantity;
  final bool striked;
  final bool deletable;

  final bool deleteOnRemoveFavorite;

  final DismissActionFunction favoriteDismissAction;
  final DismissActionFunction deleteDismissAction;

  const Product({
    Key? key,
    required this.product,
    required this.favoriteDismissAction,
    required this.deleteDismissAction,
    this.quantity = 1,
    this.striked = false,
    this.deletable = true,
    this.deleteOnRemoveFavorite = false,
  }) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Key _key = Key(Random().nextInt(10000).toString());

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
            "${widget.quantity} ${widget.product.unit.name}.",
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
            key: _key,
            direction: (widget.deletable)
                ? DismissDirection.horizontal
                : DismissDirection.startToEnd,
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                widget.deleteDismissAction(widget.product);
              }

              if (direction == DismissDirection.startToEnd) {
                widget.favoriteDismissAction(widget.product);

                /**
               * Because the Dismissible widget checks if the key is still in
               * the list when dismissed, we need to change this key when adding
               * to favorite.
               * 
               * If the [deleteOnRemoveFavorite] parameter is enabled and the
               * product is a favorite product, that means we don't want to
               * keep it here, so we do not re-create a Key.
               */
                if (!(widget.product.favorite &&
                    widget.deleteOnRemoveFavorite)) {
                  _key = Key(Random().nextInt(10000).toString());
                }
              }
            },
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
            secondaryBackground: widget.deletable
                ? Container(
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
                  )
                : null,
            child: SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.product.name,
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
