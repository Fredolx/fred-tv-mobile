// This is a generated file - do not edit.
//
// Generated from generated_proto.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use mediaTypeDescriptor instead')
const MediaType$json = {
  '1': 'MediaType',
  '2': [
    {'1': 'MEDIA_TYPE_LIVESTREAM', '2': 0},
    {'1': 'MEDIA_TYPE_MOVIE', '2': 1},
    {'1': 'MEDIA_TYPE_SERIE', '2': 2},
    {'1': 'MEDIA_TYPE_GROUP', '2': 3},
    {'1': 'MEDIA_TYPE_SEASON', '2': 4},
  ],
};

/// Descriptor for `MediaType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mediaTypeDescriptor = $convert.base64Decode(
    'CglNZWRpYVR5cGUSGQoVTUVESUFfVFlQRV9MSVZFU1RSRUFNEAASFAoQTUVESUFfVFlQRV9NT1'
    'ZJRRABEhQKEE1FRElBX1RZUEVfU0VSSUUQAhIUChBNRURJQV9UWVBFX0dST1VQEAMSFQoRTUVE'
    'SUFfVFlQRV9TRUFTT04QBA==');

@$core.Deprecated('Use viewTypeDescriptor instead')
const ViewType$json = {
  '1': 'ViewType',
  '2': [
    {'1': 'VIEW_TYPE_ALL', '2': 0},
    {'1': 'VIEW_TYPE_FAVORITES', '2': 1},
    {'1': 'VIEW_TYPE_CATEGORIES', '2': 2},
    {'1': 'VIEW_TYPE_HISTORY', '2': 3},
  ],
};

/// Descriptor for `ViewType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List viewTypeDescriptor = $convert.base64Decode(
    'CghWaWV3VHlwZRIRCg1WSUVXX1RZUEVfQUxMEAASFwoTVklFV19UWVBFX0ZBVk9SSVRFUxABEh'
    'gKFFZJRVdfVFlQRV9DQVRFR09SSUVTEAISFQoRVklFV19UWVBFX0hJU1RPUlkQAw==');

@$core.Deprecated('Use channelDescriptor instead')
const Channel$json = {
  '1': 'Channel',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '9': 0, '10': 'id', '17': true},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'url', '17': true},
    {'1': 'group', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'group', '17': true},
    {'1': 'image', '3': 5, '4': 1, '5': 9, '9': 3, '10': 'image', '17': true},
    {'1': 'media_type', '3': 6, '4': 1, '5': 13, '10': 'mediaType'},
    {
      '1': 'source_id',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 4,
      '10': 'sourceId',
      '17': true
    },
    {
      '1': 'series_id',
      '3': 8,
      '4': 1,
      '5': 4,
      '9': 5,
      '10': 'seriesId',
      '17': true
    },
    {
      '1': 'group_id',
      '3': 9,
      '4': 1,
      '5': 3,
      '9': 6,
      '10': 'groupId',
      '17': true
    },
    {'1': 'favorite', '3': 10, '4': 1, '5': 8, '10': 'favorite'},
    {
      '1': 'stream_id',
      '3': 11,
      '4': 1,
      '5': 4,
      '9': 7,
      '10': 'streamId',
      '17': true
    },
    {
      '1': 'tv_archive',
      '3': 12,
      '4': 1,
      '5': 8,
      '9': 8,
      '10': 'tvArchive',
      '17': true
    },
    {
      '1': 'season_id',
      '3': 13,
      '4': 1,
      '5': 3,
      '9': 9,
      '10': 'seasonId',
      '17': true
    },
    {
      '1': 'episode_num',
      '3': 14,
      '4': 1,
      '5': 3,
      '9': 10,
      '10': 'episodeNum',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_url'},
    {'1': '_group'},
    {'1': '_image'},
    {'1': '_source_id'},
    {'1': '_series_id'},
    {'1': '_group_id'},
    {'1': '_stream_id'},
    {'1': '_tv_archive'},
    {'1': '_season_id'},
    {'1': '_episode_num'},
  ],
};

/// Descriptor for `Channel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelDescriptor = $convert.base64Decode(
    'CgdDaGFubmVsEhMKAmlkGAEgASgDSABSAmlkiAEBEhIKBG5hbWUYAiABKAlSBG5hbWUSFQoDdX'
    'JsGAMgASgJSAFSA3VybIgBARIZCgVncm91cBgEIAEoCUgCUgVncm91cIgBARIZCgVpbWFnZRgF'
    'IAEoCUgDUgVpbWFnZYgBARIdCgptZWRpYV90eXBlGAYgASgNUgltZWRpYVR5cGUSIAoJc291cm'
    'NlX2lkGAcgASgDSARSCHNvdXJjZUlkiAEBEiAKCXNlcmllc19pZBgIIAEoBEgFUghzZXJpZXNJ'
    'ZIgBARIeCghncm91cF9pZBgJIAEoA0gGUgdncm91cElkiAEBEhoKCGZhdm9yaXRlGAogASgIUg'
    'hmYXZvcml0ZRIgCglzdHJlYW1faWQYCyABKARIB1IIc3RyZWFtSWSIAQESIgoKdHZfYXJjaGl2'
    'ZRgMIAEoCEgIUgl0dkFyY2hpdmWIAQESIAoJc2Vhc29uX2lkGA0gASgDSAlSCHNlYXNvbklkiA'
    'EBEiQKC2VwaXNvZGVfbnVtGA4gASgDSApSCmVwaXNvZGVOdW2IAQFCBQoDX2lkQgYKBF91cmxC'
    'CAoGX2dyb3VwQggKBl9pbWFnZUIMCgpfc291cmNlX2lkQgwKCl9zZXJpZXNfaWRCCwoJX2dyb3'
    'VwX2lkQgwKCl9zdHJlYW1faWRCDQoLX3R2X2FyY2hpdmVCDAoKX3NlYXNvbl9pZEIOCgxfZXBp'
    'c29kZV9udW0=');

@$core.Deprecated('Use channelListDescriptor instead')
const ChannelList$json = {
  '1': 'ChannelList',
  '2': [
    {
      '1': 'channels',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.generated_proto.Channel',
      '10': 'channels'
    },
  ],
};

/// Descriptor for `ChannelList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List channelListDescriptor = $convert.base64Decode(
    'CgtDaGFubmVsTGlzdBI0CghjaGFubmVscxgBIAMoCzIYLmdlbmVyYXRlZF9wcm90by5DaGFubm'
    'VsUghjaGFubmVscw==');

@$core.Deprecated('Use sourceDescriptor instead')
const Source$json = {
  '1': 'Source',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '9': 0, '10': 'id', '17': true},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'url', '17': true},
    {
      '1': 'url_origin',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 2,
      '10': 'urlOrigin',
      '17': true
    },
    {
      '1': 'username',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 3,
      '10': 'username',
      '17': true
    },
    {
      '1': 'password',
      '3': 6,
      '4': 1,
      '5': 9,
      '9': 4,
      '10': 'password',
      '17': true
    },
    {'1': 'source_type', '3': 7, '4': 1, '5': 13, '10': 'sourceType'},
    {'1': 'enabled', '3': 9, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'user_agent',
      '3': 10,
      '4': 1,
      '5': 9,
      '9': 5,
      '10': 'userAgent',
      '17': true
    },
    {
      '1': 'stream_user_agent',
      '3': 12,
      '4': 1,
      '5': 9,
      '9': 6,
      '10': 'streamUserAgent',
      '17': true
    },
    {
      '1': 'last_updated',
      '3': 13,
      '4': 1,
      '5': 3,
      '9': 7,
      '10': 'lastUpdated',
      '17': true
    },
  ],
  '8': [
    {'1': '_id'},
    {'1': '_url'},
    {'1': '_url_origin'},
    {'1': '_username'},
    {'1': '_password'},
    {'1': '_user_agent'},
    {'1': '_stream_user_agent'},
    {'1': '_last_updated'},
  ],
};

/// Descriptor for `Source`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sourceDescriptor = $convert.base64Decode(
    'CgZTb3VyY2USEwoCaWQYASABKANIAFICaWSIAQESEgoEbmFtZRgCIAEoCVIEbmFtZRIVCgN1cm'
    'wYAyABKAlIAVIDdXJsiAEBEiIKCnVybF9vcmlnaW4YBCABKAlIAlIJdXJsT3JpZ2luiAEBEh8K'
    'CHVzZXJuYW1lGAUgASgJSANSCHVzZXJuYW1liAEBEh8KCHBhc3N3b3JkGAYgASgJSARSCHBhc3'
    'N3b3JkiAEBEh8KC3NvdXJjZV90eXBlGAcgASgNUgpzb3VyY2VUeXBlEhgKB2VuYWJsZWQYCSAB'
    'KAhSB2VuYWJsZWQSIgoKdXNlcl9hZ2VudBgKIAEoCUgFUgl1c2VyQWdlbnSIAQESLwoRc3RyZW'
    'FtX3VzZXJfYWdlbnQYDCABKAlIBlIPc3RyZWFtVXNlckFnZW50iAEBEiYKDGxhc3RfdXBkYXRl'
    'ZBgNIAEoA0gHUgtsYXN0VXBkYXRlZIgBAUIFCgNfaWRCBgoEX3VybEINCgtfdXJsX29yaWdpbk'
    'ILCglfdXNlcm5hbWVCCwoJX3Bhc3N3b3JkQg0KC191c2VyX2FnZW50QhQKEl9zdHJlYW1fdXNl'
    'cl9hZ2VudEIPCg1fbGFzdF91cGRhdGVk');

@$core.Deprecated('Use settingsDescriptor instead')
const Settings$json = {
  '1': 'Settings',
  '2': [
    {
      '1': 'use_stream_caching',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 0,
      '10': 'useStreamCaching',
      '17': true
    },
    {
      '1': 'default_view',
      '3': 4,
      '4': 1,
      '5': 13,
      '9': 1,
      '10': 'defaultView',
      '17': true
    },
    {
      '1': 'volume',
      '3': 5,
      '4': 1,
      '5': 13,
      '9': 2,
      '10': 'volume',
      '17': true
    },
    {
      '1': 'refresh_on_start',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 3,
      '10': 'refreshOnStart',
      '17': true
    },
    {
      '1': 'default_sort',
      '3': 10,
      '4': 1,
      '5': 13,
      '9': 4,
      '10': 'defaultSort',
      '17': true
    },
  ],
  '8': [
    {'1': '_use_stream_caching'},
    {'1': '_default_view'},
    {'1': '_volume'},
    {'1': '_refresh_on_start'},
    {'1': '_default_sort'},
  ],
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxIxChJ1c2Vfc3RyZWFtX2NhY2hpbmcYAyABKAhIAFIQdXNlU3RyZWFtQ2FjaG'
    'luZ4gBARImCgxkZWZhdWx0X3ZpZXcYBCABKA1IAVILZGVmYXVsdFZpZXeIAQESGwoGdm9sdW1l'
    'GAUgASgNSAJSBnZvbHVtZYgBARItChByZWZyZXNoX29uX3N0YXJ0GAYgASgISANSDnJlZnJlc2'
    'hPblN0YXJ0iAEBEiYKDGRlZmF1bHRfc29ydBgKIAEoDUgEUgtkZWZhdWx0U29ydIgBAUIVChNf'
    'dXNlX3N0cmVhbV9jYWNoaW5nQg8KDV9kZWZhdWx0X3ZpZXdCCQoHX3ZvbHVtZUITChFfcmVmcm'
    'VzaF9vbl9zdGFydEIPCg1fZGVmYXVsdF9zb3J0');

@$core.Deprecated('Use filtersDescriptor instead')
const Filters$json = {
  '1': 'Filters',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'query', '17': true},
    {'1': 'source_ids', '3': 2, '4': 3, '5': 3, '10': 'sourceIds'},
    {
      '1': 'media_types',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.generated_proto.MediaType',
      '10': 'mediaTypes'
    },
    {
      '1': 'view_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.generated_proto.ViewType',
      '10': 'viewType'
    },
    {'1': 'page', '3': 5, '4': 1, '5': 13, '10': 'page'},
    {
      '1': 'series_id',
      '3': 6,
      '4': 1,
      '5': 3,
      '9': 1,
      '10': 'seriesId',
      '17': true
    },
    {
      '1': 'group_id',
      '3': 7,
      '4': 1,
      '5': 3,
      '9': 2,
      '10': 'groupId',
      '17': true
    },
    {'1': 'use_keywords', '3': 8, '4': 1, '5': 8, '10': 'useKeywords'},
    {'1': 'sort', '3': 9, '4': 1, '5': 13, '10': 'sort'},
    {
      '1': 'season',
      '3': 10,
      '4': 1,
      '5': 3,
      '9': 3,
      '10': 'season',
      '17': true
    },
  ],
  '8': [
    {'1': '_query'},
    {'1': '_series_id'},
    {'1': '_group_id'},
    {'1': '_season'},
  ],
};

/// Descriptor for `Filters`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List filtersDescriptor = $convert.base64Decode(
    'CgdGaWx0ZXJzEhkKBXF1ZXJ5GAEgASgJSABSBXF1ZXJ5iAEBEh0KCnNvdXJjZV9pZHMYAiADKA'
    'NSCXNvdXJjZUlkcxI7CgttZWRpYV90eXBlcxgDIAMoDjIaLmdlbmVyYXRlZF9wcm90by5NZWRp'
    'YVR5cGVSCm1lZGlhVHlwZXMSNgoJdmlld190eXBlGAQgASgOMhkuZ2VuZXJhdGVkX3Byb3RvLl'
    'ZpZXdUeXBlUgh2aWV3VHlwZRISCgRwYWdlGAUgASgNUgRwYWdlEiAKCXNlcmllc19pZBgGIAEo'
    'A0gBUghzZXJpZXNJZIgBARIeCghncm91cF9pZBgHIAEoA0gCUgdncm91cElkiAEBEiEKDHVzZV'
    '9rZXl3b3JkcxgIIAEoCFILdXNlS2V5d29yZHMSEgoEc29ydBgJIAEoDVIEc29ydBIbCgZzZWFz'
    'b24YCiABKANIA1IGc2Vhc29uiAEBQggKBl9xdWVyeUIMCgpfc2VyaWVzX2lkQgsKCV9ncm91cF'
    '9pZEIJCgdfc2Vhc29u');

@$core.Deprecated('Use toggle_favoriteDescriptor instead')
const toggle_favorite$json = {
  '1': 'toggle_favorite',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 3, '10': 'channelId'},
    {'1': 'favorite', '3': 2, '4': 1, '5': 8, '10': 'favorite'},
  ],
};

/// Descriptor for `toggle_favorite`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toggle_favoriteDescriptor = $convert.base64Decode(
    'Cg90b2dnbGVfZmF2b3JpdGUSHQoKY2hhbm5lbF9pZBgBIAEoA1IJY2hhbm5lbElkEhoKCGZhdm'
    '9yaXRlGAIgASgIUghmYXZvcml0ZQ==');

@$core.Deprecated('Use id_messageDescriptor instead')
const id_message$json = {
  '1': 'id_message',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 3, '10': 'value'},
  ],
};

/// Descriptor for `id_message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List id_messageDescriptor =
    $convert.base64Decode('CgppZF9tZXNzYWdlEhQKBXZhbHVlGAEgASgDUgV2YWx1ZQ==');

@$core.Deprecated('Use movie_positionDescriptor instead')
const movie_position$json = {
  '1': 'movie_position',
  '2': [
    {'1': 'channel_id', '3': 1, '4': 1, '5': 3, '10': 'channelId'},
    {'1': 'position', '3': 2, '4': 1, '5': 3, '10': 'position'},
  ],
};

/// Descriptor for `movie_position`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List movie_positionDescriptor = $convert.base64Decode(
    'Cg5tb3ZpZV9wb3NpdGlvbhIdCgpjaGFubmVsX2lkGAEgASgDUgljaGFubmVsSWQSGgoIcG9zaX'
    'Rpb24YAiABKANSCHBvc2l0aW9u');

@$core.Deprecated('Use strMessageDescriptor instead')
const StrMessage$json = {
  '1': 'StrMessage',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `StrMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List strMessageDescriptor =
    $convert.base64Decode('CgpTdHJNZXNzYWdlEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use boolMessageDescriptor instead')
const BoolMessage$json = {
  '1': 'BoolMessage',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `BoolMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boolMessageDescriptor =
    $convert.base64Decode('CgtCb29sTWVzc2FnZRIUCgV2YWx1ZRgBIAEoCFIFdmFsdWU=');

@$core.Deprecated('Use getMoviePositionDescriptor instead')
const GetMoviePosition$json = {
  '1': 'GetMoviePosition',
  '2': [
    {
      '1': 'position',
      '3': 1,
      '4': 1,
      '5': 3,
      '9': 0,
      '10': 'position',
      '17': true
    },
  ],
  '8': [
    {'1': '_position'},
  ],
};

/// Descriptor for `GetMoviePosition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMoviePositionDescriptor = $convert.base64Decode(
    'ChBHZXRNb3ZpZVBvc2l0aW9uEh8KCHBvc2l0aW9uGAEgASgDSABSCHBvc2l0aW9uiAEBQgsKCV'
    '9wb3NpdGlvbg==');

@$core.Deprecated('Use initMessageDescriptor instead')
const InitMessage$json = {
  '1': 'InitMessage',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '9': 0, '10': 'path', '17': true},
  ],
  '8': [
    {'1': '_path'},
  ],
};

/// Descriptor for `InitMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initMessageDescriptor = $convert.base64Decode(
    'CgtJbml0TWVzc2FnZRIXCgRwYXRoGAEgASgJSABSBHBhdGiIAQFCBwoFX3BhdGg=');

@$core.Deprecated('Use fFIResultDescriptor instead')
const FFIResult$json = {
  '1': 'FFIResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {
      '1': 'error_message',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'errorMessage',
      '17': true
    },
    {
      '1': 'settings',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.generated_proto.Settings',
      '9': 0,
      '10': 'settings'
    },
    {
      '1': 'source',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.generated_proto.Source',
      '9': 0,
      '10': 'source'
    },
    {
      '1': 'channel_list',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.generated_proto.ChannelList',
      '9': 0,
      '10': 'channelList'
    },
    {
      '1': 'bool_message',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.generated_proto.BoolMessage',
      '9': 0,
      '10': 'boolMessage'
    },
    {
      '1': 'movie_position',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.generated_proto.GetMoviePosition',
      '9': 0,
      '10': 'moviePosition'
    },
  ],
  '8': [
    {'1': 'data'},
    {'1': '_error_message'},
  ],
};

/// Descriptor for `FFIResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fFIResultDescriptor = $convert.base64Decode(
    'CglGRklSZXN1bHQSGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2VzcxIoCg1lcnJvcl9tZXNzYWdlGA'
    'IgASgJSAFSDGVycm9yTWVzc2FnZYgBARI3CghzZXR0aW5ncxgDIAEoCzIZLmdlbmVyYXRlZF9w'
    'cm90by5TZXR0aW5nc0gAUghzZXR0aW5ncxIxCgZzb3VyY2UYBCABKAsyFy5nZW5lcmF0ZWRfcH'
    'JvdG8uU291cmNlSABSBnNvdXJjZRJBCgxjaGFubmVsX2xpc3QYBiABKAsyHC5nZW5lcmF0ZWRf'
    'cHJvdG8uQ2hhbm5lbExpc3RIAFILY2hhbm5lbExpc3QSQQoMYm9vbF9tZXNzYWdlGAcgASgLMh'
    'wuZ2VuZXJhdGVkX3Byb3RvLkJvb2xNZXNzYWdlSABSC2Jvb2xNZXNzYWdlEkoKDm1vdmllX3Bv'
    'c2l0aW9uGAggASgLMiEuZ2VuZXJhdGVkX3Byb3RvLkdldE1vdmllUG9zaXRpb25IAFINbW92aW'
    'VQb3NpdGlvbkIGCgRkYXRhQhAKDl9lcnJvcl9tZXNzYWdl');
