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
      '1': 'mpv_params',
      '3': 2,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'mpvParams',
      '17': true
    },
    {
      '1': 'use_stream_caching',
      '3': 3,
      '4': 1,
      '5': 8,
      '9': 1,
      '10': 'useStreamCaching',
      '17': true
    },
    {
      '1': 'default_view',
      '3': 4,
      '4': 1,
      '5': 13,
      '9': 2,
      '10': 'defaultView',
      '17': true
    },
    {
      '1': 'volume',
      '3': 5,
      '4': 1,
      '5': 13,
      '9': 3,
      '10': 'volume',
      '17': true
    },
    {
      '1': 'refresh_on_start',
      '3': 6,
      '4': 1,
      '5': 8,
      '9': 4,
      '10': 'refreshOnStart',
      '17': true
    },
    {'1': 'zoom', '3': 9, '4': 1, '5': 13, '9': 5, '10': 'zoom', '17': true},
    {
      '1': 'default_sort',
      '3': 10,
      '4': 1,
      '5': 13,
      '9': 6,
      '10': 'defaultSort',
      '17': true
    },
  ],
  '8': [
    {'1': '_mpv_params'},
    {'1': '_use_stream_caching'},
    {'1': '_default_view'},
    {'1': '_volume'},
    {'1': '_refresh_on_start'},
    {'1': '_zoom'},
    {'1': '_default_sort'},
  ],
};

/// Descriptor for `Settings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List settingsDescriptor = $convert.base64Decode(
    'CghTZXR0aW5ncxIiCgptcHZfcGFyYW1zGAIgASgJSABSCW1wdlBhcmFtc4gBARIxChJ1c2Vfc3'
    'RyZWFtX2NhY2hpbmcYAyABKAhIAVIQdXNlU3RyZWFtQ2FjaGluZ4gBARImCgxkZWZhdWx0X3Zp'
    'ZXcYBCABKA1IAlILZGVmYXVsdFZpZXeIAQESGwoGdm9sdW1lGAUgASgNSANSBnZvbHVtZYgBAR'
    'ItChByZWZyZXNoX29uX3N0YXJ0GAYgASgISARSDnJlZnJlc2hPblN0YXJ0iAEBEhcKBHpvb20Y'
    'CSABKA1IBVIEem9vbYgBARImCgxkZWZhdWx0X3NvcnQYCiABKA1IBlILZGVmYXVsdFNvcnSIAQ'
    'FCDQoLX21wdl9wYXJhbXNCFQoTX3VzZV9zdHJlYW1fY2FjaGluZ0IPCg1fZGVmYXVsdF92aWV3'
    'QgkKB192b2x1bWVCEwoRX3JlZnJlc2hfb25fc3RhcnRCBwoFX3pvb21CDwoNX2RlZmF1bHRfc2'
    '9ydA==');

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
    'JvdG8uU291cmNlSABSBnNvdXJjZUIGCgRkYXRhQhAKDl9lcnJvcl9tZXNzYWdl');
