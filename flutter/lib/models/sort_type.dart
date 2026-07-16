enum SortType { alphabeticalAsc, alphabeticalDesc, provider }

String sortTypeToString(SortType sort) {
  switch (sort) {
    case SortType.alphabeticalAsc:
      return "Alphabetical ASC";
    case SortType.alphabeticalDesc:
      return "Alphabetical DESC";
    case SortType.provider:
      return "Provider";
  }
}
