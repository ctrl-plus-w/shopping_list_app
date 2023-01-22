enum States {
  general,
  category,
  favorite,
}

class NavigationAutomata {
  final States state;
  final bool skipFavoriteState;

  const NavigationAutomata(this.state, {this.skipFavoriteState = false});

  NavigationAutomata? next() {
    if (state == States.general) {
      return const NavigationAutomata(States.category);
    }

    if (state == States.category && !skipFavoriteState) {
      return const NavigationAutomata(States.favorite);
    }

    return null;
  }

  NavigationAutomata? previous() {
    if (state == States.favorite) {
      return const NavigationAutomata(States.category);
    }

    if (state == States.category) {
      return const NavigationAutomata(States.general);
    }

    return null;
  }
}
