import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  final String title;
  final bool value;
  final Function(bool) onChange;
  final EdgeInsets padding;
  final EdgeInsets checkboxPadding;

  const CustomCheckbox({
    required this.value,
    required this.onChange,
    required this.title,
    this.checkboxPadding = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onChange(!widget.value),
        child: Padding(
          padding: widget.padding,
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                padding: widget.checkboxPadding,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 0.4,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value
                          ? const Color.fromRGBO(32, 94, 187, 1)
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(widget.title, style: theme.textTheme.bodyText1),
            ],
          ),
        ),
      ),
    );
  }
}
