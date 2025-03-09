enum ViewType { all, categories, favorites, history, settings }

String viewTypeToString(ViewType vw) {
  switch (vw) {
    case ViewType.all:
      return "All";
    case ViewType.categories:
      return "Categories";
    case ViewType.favorites:
      return "Favorites";
    case ViewType.history:
      return "History";
    default:
      return "All";
  }
}
