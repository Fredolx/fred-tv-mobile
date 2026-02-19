import 'package:open_tv/models/exceptions/invalid_value_exception.dart';
import 'package:open_tv/src/rust/api/types.dart';

enum NodeType { category, series }

NodeType fromMediaType(MediaType type) {
  switch (type) {
    case MediaType.group:
      return NodeType.category;
    case MediaType.serie:
      return NodeType.series;
    case MediaType.livestream:
      throw InvalidValueException(MediaType.livestream.toString());
    case MediaType.movie:
      throw InvalidValueException(MediaType.movie.toString());
    case MediaType.season:
      throw InvalidValueException(MediaType.season.toString());
  }
}
