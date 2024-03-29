import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:slugify/slugify.dart';

class SearchInput<T> extends StatefulWidget {
  /// Label of the form field
  final String label;

  /// Key used in the wrapper form
  final GlobalKey<FormState> formKey;

  /// List of data used in the form field
  final List<T> data;

  /// Form field controller
  final TextEditingController controller;

  /// Selected value controller
  final TextEditingController valueController;

  /// Error message used when the user tries to add an element with the field
  /// empty
  final String emptyErrorMessage;

  /// Error message used when the user tries to add an element that already
  /// exists
  final String duplicationErrorMessage;

  /// From an element in the data list, get the slug of this element
  final String Function(T) getSlug;

  /// From an element in the data list, get the label / name of this element
  final String Function(T) getLabel;

  /// From an element in the data list, get the id of this element
  final int Function(T) getId;

  /// From the name of the element to create, do the computations to create
  /// this element and return it
  final Future<T> Function(String) addElement;

  const SearchInput({
    required this.label,
    required this.formKey,
    required this.data,
    required this.controller,
    required this.valueController,
    required this.emptyErrorMessage,
    required this.duplicationErrorMessage,
    required this.getSlug,
    required this.getLabel,
    required this.addElement,
    required this.getId,
    Key? key,
  }) : super(key: key);

  @override
  State<SearchInput> createState() => _SearchInputState<T>();
}

class _SearchInputState<T> extends State<SearchInput> {
  /// Error returned by the form field
  String? _inputError;

  /// Id of the selected element
  int? _selectedElementId;

  /// List of elements that have been added with the form field
  List<T> _additionalData = [];

  /// Combination of the already existing [widget.data] and the [_additionalData]
  List<T> get _combinedData {
    return [...widget.data, ..._additionalData];
  }

  /// [_combinedData] filtered by the content on the form input field through
  /// the [widget.controller]
  List<T> get _filteredData {
    return _combinedData
        .where((element) =>
            widget.getLabel(element).startsWith(widget.controller.text))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    /// The goal here is to IF the valueController is not empty when loading the
    /// component, select the right element at that time.
    ///
    /// Whe first get that element by checking its label with the text inside
    /// the value controller, then we set the [_selectedElementId] value with
    /// the found element id.
    if (widget.valueController.text.isNotEmpty) {
      setState(() {
        _selectedElementId = widget.getId(_filteredData.firstWhere(
          (element) => widget.getLabel(element) == widget.valueController.text,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const formInputTextStyle = TextStyle(fontSize: 16);

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.bodyText1,
        ),

        // Separator
        const SizedBox(height: 8),

        // Main Form Field
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
            style: theme.textTheme.bodyText1!.merge(formInputTextStyle),
            controller: widget.controller,
            onChanged: (String value) {
              // ! Need so as to refresh the dropdown list of searched results.
              setState(() {});
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.emptyErrorMessage;
              }

              if (_combinedData
                  .map((element) => widget.getSlug(element))
                  .contains(slugify(value))) {
                return widget.duplicationErrorMessage;
              }

              if (_inputError != null) {
                return _inputError;
              }

              return null;
            },
            decoration: InputDecoration(
              hintText: "Aucune catégorie",
              suffixIconConstraints: BoxConstraints.loose(const Size(32, 32)),
              suffixIcon: InkWell(
                onTap: () async {
                  if (widget.formKey.currentState!.validate()) {
                    try {
                      String label = widget.controller.text;
                      T element = await widget.addElement(label);

                      widget.valueController.text = widget.getLabel(element);

                      setState(() {
                        _additionalData = [..._additionalData, element];
                        _selectedElementId = widget.getId(element);
                      });

                      widget.controller.clear();

                      if (mounted) {
                        FocusScope.of(context).unfocus();
                      }
                    } catch (error) {
                      setState(() {
                        _inputError = error.toString();
                      });

                      widget.formKey.currentState!.validate();
                    }
                  }
                },
                child: Center(
                  child: SizedBox(
                    width: 18,
                    child: SvgPicture.asset(
                      'assets/add.svg',
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            ).applyDefaults(theme.inputDecorationTheme),
          ),
        ),

        /// ? Separator
        const SizedBox(height: 16),

        /// ? Dropdown
        if (_filteredData.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                  color: const Color.fromRGBO(187, 195, 208, 1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.11),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: ((BuildContext context, int index) {
                    T element = _filteredData[index];
                    bool isSelected = _selectedElementId != null &&
                        _selectedElementId == widget.getId(element);

                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          setState(() {
                            _selectedElementId = widget.getId(element);
                            widget.valueController.text =
                                widget.getLabel(element);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 12,
                        ),
                        width: double.infinity,
                        child: Text(
                          widget.getLabel(element),
                          style: isSelected
                              ? theme.textTheme.bodyText1!
                                  .merge(const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ))
                              : theme.textTheme.bodyText1,
                        ),
                      ),
                    );
                  }),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    color: Color.fromRGBO(187, 195, 208, 1),
                    height: 1,
                    thickness: 1,
                  ),
                  itemCount: _filteredData.length,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
