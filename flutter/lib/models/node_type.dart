import 'package:open_tv/models/exceptions/invalid_value_exception.dart';
import 'package:open_tv/models/media_type.dart';

enum NodeType { category, series, season }

NodeType fromMediaType(MediaType type) {
  switch (type) {
    case MediaType.group:
      return NodeType.category;
    case MediaType.season:
      return NodeType.season;
    case MediaType.serie:
      return NodeType.series;
    case MediaType.livestream:
      throw InvalidValueException(MediaType.livestream.toString());
    case MediaType.movie:
      throw InvalidValueException(MediaType.livestream.toString());
  }
}
