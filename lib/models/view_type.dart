enum ViewType { all, categories, favorites, settings }

String viewTypeToString(ViewType vw) {
  switch (vw) {
    case ViewType.all:
      return "All";
    case ViewType.categories:
      return "Categories";
    case ViewType.favorites:
      return "Favorites";
    default:
      return "All";
  }
}
