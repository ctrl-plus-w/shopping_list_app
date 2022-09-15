typedef PrefPropNameGetter = String Function(String propName);

/// Get preferency property name
///
/// Returns a [Function] that get the final property name
/// from the page and section prefixes passed in the initial function.
PrefPropNameGetter prefPropNameGetter(
  String pagePrefPrefix,
  String sectionPrefPrefix,
) {
  return (String propName) =>
      [pagePrefPrefix, sectionPrefPrefix, propName].join('_');
}
