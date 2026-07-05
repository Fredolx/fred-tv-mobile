// This is a generated file - do not edit.
//
// Generated from generated_proto.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'generated_proto.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'generated_proto.pbenum.dart';

class Channel extends $pb.GeneratedMessage {
  factory Channel({
    $fixnum.Int64? id,
    $core.String? name,
    $core.String? url,
    $core.String? group,
    $core.String? image,
    $core.int? mediaType,
    $fixnum.Int64? sourceId,
    $fixnum.Int64? seriesId,
    $fixnum.Int64? groupId,
    $core.bool? favorite,
    $fixnum.Int64? streamId,
    $core.bool? tvArchive,
    $fixnum.Int64? seasonId,
    $fixnum.Int64? episodeNum,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (group != null) result.group = group;
    if (image != null) result.image = image;
    if (mediaType != null) result.mediaType = mediaType;
    if (sourceId != null) result.sourceId = sourceId;
    if (seriesId != null) result.seriesId = seriesId;
    if (groupId != null) result.groupId = groupId;
    if (favorite != null) result.favorite = favorite;
    if (streamId != null) result.streamId = streamId;
    if (tvArchive != null) result.tvArchive = tvArchive;
    if (seasonId != null) result.seasonId = seasonId;
    if (episodeNum != null) result.episodeNum = episodeNum;
    return result;
  }

  Channel._();

  factory Channel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Channel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Channel',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'group')
    ..aOS(5, _omitFieldNames ? '' : 'image')
    ..aI(6, _omitFieldNames ? '' : 'mediaType', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(7, _omitFieldNames ? '' : 'sourceId')
    ..a<$fixnum.Int64>(
        8, _omitFieldNames ? '' : 'seriesId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(9, _omitFieldNames ? '' : 'groupId')
    ..aOB(10, _omitFieldNames ? '' : 'favorite')
    ..a<$fixnum.Int64>(
        11, _omitFieldNames ? '' : 'streamId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(12, _omitFieldNames ? '' : 'tvArchive')
    ..aInt64(13, _omitFieldNames ? '' : 'seasonId')
    ..aInt64(14, _omitFieldNames ? '' : 'episodeNum')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Channel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Channel copyWith(void Function(Channel) updates) =>
      super.copyWith((message) => updates(message as Channel)) as Channel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Channel create() => Channel._();
  @$core.override
  Channel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Channel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Channel>(create);
  static Channel? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get group => $_getSZ(3);
  @$pb.TagNumber(4)
  set group($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGroup() => $_has(3);
  @$pb.TagNumber(4)
  void clearGroup() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get image => $_getSZ(4);
  @$pb.TagNumber(5)
  set image($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasImage() => $_has(4);
  @$pb.TagNumber(5)
  void clearImage() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get mediaType => $_getIZ(5);
  @$pb.TagNumber(6)
  set mediaType($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMediaType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMediaType() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get sourceId => $_getI64(6);
  @$pb.TagNumber(7)
  set sourceId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourceId() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceId() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get seriesId => $_getI64(7);
  @$pb.TagNumber(8)
  set seriesId($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSeriesId() => $_has(7);
  @$pb.TagNumber(8)
  void clearSeriesId() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get groupId => $_getI64(8);
  @$pb.TagNumber(9)
  set groupId($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGroupId() => $_has(8);
  @$pb.TagNumber(9)
  void clearGroupId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get favorite => $_getBF(9);
  @$pb.TagNumber(10)
  set favorite($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFavorite() => $_has(9);
  @$pb.TagNumber(10)
  void clearFavorite() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get streamId => $_getI64(10);
  @$pb.TagNumber(11)
  set streamId($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStreamId() => $_has(10);
  @$pb.TagNumber(11)
  void clearStreamId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get tvArchive => $_getBF(11);
  @$pb.TagNumber(12)
  set tvArchive($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTvArchive() => $_has(11);
  @$pb.TagNumber(12)
  void clearTvArchive() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get seasonId => $_getI64(12);
  @$pb.TagNumber(13)
  set seasonId($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSeasonId() => $_has(12);
  @$pb.TagNumber(13)
  void clearSeasonId() => $_clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get episodeNum => $_getI64(13);
  @$pb.TagNumber(14)
  set episodeNum($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasEpisodeNum() => $_has(13);
  @$pb.TagNumber(14)
  void clearEpisodeNum() => $_clearField(14);
}

class ChannelList extends $pb.GeneratedMessage {
  factory ChannelList({
    $core.Iterable<Channel>? channels,
  }) {
    final result = create();
    if (channels != null) result.channels.addAll(channels);
    return result;
  }

  ChannelList._();

  factory ChannelList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..pPM<Channel>(1, _omitFieldNames ? '' : 'channels',
        subBuilder: Channel.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelList copyWith(void Function(ChannelList) updates) =>
      super.copyWith((message) => updates(message as ChannelList))
          as ChannelList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelList create() => ChannelList._();
  @$core.override
  ChannelList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelList>(create);
  static ChannelList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Channel> get channels => $_getList(0);
}

class Source extends $pb.GeneratedMessage {
  factory Source({
    $fixnum.Int64? id,
    $core.String? name,
    $core.String? url,
    $core.String? urlOrigin,
    $core.String? username,
    $core.String? password,
    $core.int? sourceType,
    $core.bool? enabled,
    $core.String? userAgent,
    $core.String? streamUserAgent,
    $fixnum.Int64? lastUpdated,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (url != null) result.url = url;
    if (urlOrigin != null) result.urlOrigin = urlOrigin;
    if (username != null) result.username = username;
    if (password != null) result.password = password;
    if (sourceType != null) result.sourceType = sourceType;
    if (enabled != null) result.enabled = enabled;
    if (userAgent != null) result.userAgent = userAgent;
    if (streamUserAgent != null) result.streamUserAgent = streamUserAgent;
    if (lastUpdated != null) result.lastUpdated = lastUpdated;
    return result;
  }

  Source._();

  factory Source.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Source.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Source',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'urlOrigin')
    ..aOS(5, _omitFieldNames ? '' : 'username')
    ..aOS(6, _omitFieldNames ? '' : 'password')
    ..aI(7, _omitFieldNames ? '' : 'sourceType', fieldType: $pb.PbFieldType.OU3)
    ..aOB(9, _omitFieldNames ? '' : 'enabled')
    ..aOS(10, _omitFieldNames ? '' : 'userAgent')
    ..aOS(12, _omitFieldNames ? '' : 'streamUserAgent')
    ..aInt64(13, _omitFieldNames ? '' : 'lastUpdated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Source clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Source copyWith(void Function(Source) updates) =>
      super.copyWith((message) => updates(message as Source)) as Source;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Source create() => Source._();
  @$core.override
  Source createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Source getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Source>(create);
  static Source? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get urlOrigin => $_getSZ(3);
  @$pb.TagNumber(4)
  set urlOrigin($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUrlOrigin() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrlOrigin() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get username => $_getSZ(4);
  @$pb.TagNumber(5)
  set username($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUsername() => $_has(4);
  @$pb.TagNumber(5)
  void clearUsername() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get password => $_getSZ(5);
  @$pb.TagNumber(6)
  set password($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPassword() => $_has(5);
  @$pb.TagNumber(6)
  void clearPassword() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get sourceType => $_getIZ(6);
  @$pb.TagNumber(7)
  set sourceType($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSourceType() => $_has(6);
  @$pb.TagNumber(7)
  void clearSourceType() => $_clearField(7);

  @$pb.TagNumber(9)
  $core.bool get enabled => $_getBF(7);
  @$pb.TagNumber(9)
  set enabled($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(9)
  $core.bool hasEnabled() => $_has(7);
  @$pb.TagNumber(9)
  void clearEnabled() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get userAgent => $_getSZ(8);
  @$pb.TagNumber(10)
  set userAgent($core.String value) => $_setString(8, value);
  @$pb.TagNumber(10)
  $core.bool hasUserAgent() => $_has(8);
  @$pb.TagNumber(10)
  void clearUserAgent() => $_clearField(10);

  @$pb.TagNumber(12)
  $core.String get streamUserAgent => $_getSZ(9);
  @$pb.TagNumber(12)
  set streamUserAgent($core.String value) => $_setString(9, value);
  @$pb.TagNumber(12)
  $core.bool hasStreamUserAgent() => $_has(9);
  @$pb.TagNumber(12)
  void clearStreamUserAgent() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get lastUpdated => $_getI64(10);
  @$pb.TagNumber(13)
  set lastUpdated($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(13)
  $core.bool hasLastUpdated() => $_has(10);
  @$pb.TagNumber(13)
  void clearLastUpdated() => $_clearField(13);
}

class Settings extends $pb.GeneratedMessage {
  factory Settings({
    $core.bool? useStreamCaching,
    $core.int? defaultView,
    $core.int? volume,
    $core.bool? refreshOnStart,
    $core.int? defaultSort,
  }) {
    final result = create();
    if (useStreamCaching != null) result.useStreamCaching = useStreamCaching;
    if (defaultView != null) result.defaultView = defaultView;
    if (volume != null) result.volume = volume;
    if (refreshOnStart != null) result.refreshOnStart = refreshOnStart;
    if (defaultSort != null) result.defaultSort = defaultSort;
    return result;
  }

  Settings._();

  factory Settings.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Settings.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Settings',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOB(3, _omitFieldNames ? '' : 'useStreamCaching')
    ..aI(4, _omitFieldNames ? '' : 'defaultView',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'volume', fieldType: $pb.PbFieldType.OU3)
    ..aOB(6, _omitFieldNames ? '' : 'refreshOnStart')
    ..aI(10, _omitFieldNames ? '' : 'defaultSort',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Settings copyWith(void Function(Settings) updates) =>
      super.copyWith((message) => updates(message as Settings)) as Settings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Settings create() => Settings._();
  @$core.override
  Settings createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Settings getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Settings>(create);
  static Settings? _defaultInstance;

  @$pb.TagNumber(3)
  $core.bool get useStreamCaching => $_getBF(0);
  @$pb.TagNumber(3)
  set useStreamCaching($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(3)
  $core.bool hasUseStreamCaching() => $_has(0);
  @$pb.TagNumber(3)
  void clearUseStreamCaching() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get defaultView => $_getIZ(1);
  @$pb.TagNumber(4)
  set defaultView($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultView() => $_has(1);
  @$pb.TagNumber(4)
  void clearDefaultView() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get volume => $_getIZ(2);
  @$pb.TagNumber(5)
  set volume($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(5)
  $core.bool hasVolume() => $_has(2);
  @$pb.TagNumber(5)
  void clearVolume() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get refreshOnStart => $_getBF(3);
  @$pb.TagNumber(6)
  set refreshOnStart($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(6)
  $core.bool hasRefreshOnStart() => $_has(3);
  @$pb.TagNumber(6)
  void clearRefreshOnStart() => $_clearField(6);

  @$pb.TagNumber(10)
  $core.int get defaultSort => $_getIZ(4);
  @$pb.TagNumber(10)
  set defaultSort($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultSort() => $_has(4);
  @$pb.TagNumber(10)
  void clearDefaultSort() => $_clearField(10);
}

class Filters extends $pb.GeneratedMessage {
  factory Filters({
    $core.String? query,
    $core.Iterable<$fixnum.Int64>? sourceIds,
    $core.Iterable<MediaType>? mediaTypes,
    ViewType? viewType,
    $core.int? page,
    $fixnum.Int64? seriesId,
    $fixnum.Int64? groupId,
    $core.bool? useKeywords,
    $core.int? sort,
    $fixnum.Int64? season,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (sourceIds != null) result.sourceIds.addAll(sourceIds);
    if (mediaTypes != null) result.mediaTypes.addAll(mediaTypes);
    if (viewType != null) result.viewType = viewType;
    if (page != null) result.page = page;
    if (seriesId != null) result.seriesId = seriesId;
    if (groupId != null) result.groupId = groupId;
    if (useKeywords != null) result.useKeywords = useKeywords;
    if (sort != null) result.sort = sort;
    if (season != null) result.season = season;
    return result;
  }

  Filters._();

  factory Filters.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Filters.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Filters',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..p<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'sourceIds', $pb.PbFieldType.K6)
    ..pc<MediaType>(3, _omitFieldNames ? '' : 'mediaTypes', $pb.PbFieldType.KE,
        valueOf: MediaType.valueOf,
        enumValues: MediaType.values,
        defaultEnumValue: MediaType.MEDIA_TYPE_LIVESTREAM)
    ..aE<ViewType>(4, _omitFieldNames ? '' : 'viewType',
        enumValues: ViewType.values)
    ..aI(5, _omitFieldNames ? '' : 'page', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(6, _omitFieldNames ? '' : 'seriesId')
    ..aInt64(7, _omitFieldNames ? '' : 'groupId')
    ..aOB(8, _omitFieldNames ? '' : 'useKeywords')
    ..aI(9, _omitFieldNames ? '' : 'sort', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(10, _omitFieldNames ? '' : 'season')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Filters clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Filters copyWith(void Function(Filters) updates) =>
      super.copyWith((message) => updates(message as Filters)) as Filters;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Filters create() => Filters._();
  @$core.override
  Filters createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Filters getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Filters>(create);
  static Filters? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$fixnum.Int64> get sourceIds => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<MediaType> get mediaTypes => $_getList(2);

  @$pb.TagNumber(4)
  ViewType get viewType => $_getN(3);
  @$pb.TagNumber(4)
  set viewType(ViewType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasViewType() => $_has(3);
  @$pb.TagNumber(4)
  void clearViewType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get page => $_getIZ(4);
  @$pb.TagNumber(5)
  set page($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPage() => $_has(4);
  @$pb.TagNumber(5)
  void clearPage() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get seriesId => $_getI64(5);
  @$pb.TagNumber(6)
  set seriesId($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeriesId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeriesId() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get groupId => $_getI64(6);
  @$pb.TagNumber(7)
  set groupId($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGroupId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGroupId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get useKeywords => $_getBF(7);
  @$pb.TagNumber(8)
  set useKeywords($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUseKeywords() => $_has(7);
  @$pb.TagNumber(8)
  void clearUseKeywords() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get sort => $_getIZ(8);
  @$pb.TagNumber(9)
  set sort($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSort() => $_has(8);
  @$pb.TagNumber(9)
  void clearSort() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get season => $_getI64(9);
  @$pb.TagNumber(10)
  set season($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSeason() => $_has(9);
  @$pb.TagNumber(10)
  void clearSeason() => $_clearField(10);
}

class ToggleFavorite extends $pb.GeneratedMessage {
  factory ToggleFavorite({
    $fixnum.Int64? channelId,
    $core.bool? favorite,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (favorite != null) result.favorite = favorite;
    return result;
  }

  ToggleFavorite._();

  factory ToggleFavorite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ToggleFavorite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToggleFavorite',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'channelId')
    ..aOB(2, _omitFieldNames ? '' : 'favorite')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToggleFavorite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToggleFavorite copyWith(void Function(ToggleFavorite) updates) =>
      super.copyWith((message) => updates(message as ToggleFavorite))
          as ToggleFavorite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToggleFavorite create() => ToggleFavorite._();
  @$core.override
  ToggleFavorite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ToggleFavorite getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ToggleFavorite>(create);
  static ToggleFavorite? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get channelId => $_getI64(0);
  @$pb.TagNumber(1)
  set channelId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get favorite => $_getBF(1);
  @$pb.TagNumber(2)
  set favorite($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFavorite() => $_has(1);
  @$pb.TagNumber(2)
  void clearFavorite() => $_clearField(2);
}

class IdMessage extends $pb.GeneratedMessage {
  factory IdMessage({
    $fixnum.Int64? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  IdMessage._();

  factory IdMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdMessage copyWith(void Function(IdMessage) updates) =>
      super.copyWith((message) => updates(message as IdMessage)) as IdMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdMessage create() => IdMessage._();
  @$core.override
  IdMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdMessage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<IdMessage>(create);
  static IdMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get value => $_getI64(0);
  @$pb.TagNumber(1)
  set value($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class MoviePosition extends $pb.GeneratedMessage {
  factory MoviePosition({
    $fixnum.Int64? channelId,
    $fixnum.Int64? position,
  }) {
    final result = create();
    if (channelId != null) result.channelId = channelId;
    if (position != null) result.position = position;
    return result;
  }

  MoviePosition._();

  factory MoviePosition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MoviePosition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MoviePosition',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'channelId')
    ..aInt64(2, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoviePosition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MoviePosition copyWith(void Function(MoviePosition) updates) =>
      super.copyWith((message) => updates(message as MoviePosition))
          as MoviePosition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MoviePosition create() => MoviePosition._();
  @$core.override
  MoviePosition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MoviePosition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MoviePosition>(create);
  static MoviePosition? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get channelId => $_getI64(0);
  @$pb.TagNumber(1)
  set channelId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get position => $_getI64(1);
  @$pb.TagNumber(2)
  set position($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPosition() => $_has(1);
  @$pb.TagNumber(2)
  void clearPosition() => $_clearField(2);
}

class StrMessage extends $pb.GeneratedMessage {
  factory StrMessage({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  StrMessage._();

  factory StrMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StrMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StrMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StrMessage copyWith(void Function(StrMessage) updates) =>
      super.copyWith((message) => updates(message as StrMessage)) as StrMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StrMessage create() => StrMessage._();
  @$core.override
  StrMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StrMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StrMessage>(create);
  static StrMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class OptStrMessage extends $pb.GeneratedMessage {
  factory OptStrMessage({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  OptStrMessage._();

  factory OptStrMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OptStrMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OptStrMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OptStrMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OptStrMessage copyWith(void Function(OptStrMessage) updates) =>
      super.copyWith((message) => updates(message as OptStrMessage))
          as OptStrMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OptStrMessage create() => OptStrMessage._();
  @$core.override
  OptStrMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OptStrMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OptStrMessage>(create);
  static OptStrMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class BoolMessage extends $pb.GeneratedMessage {
  factory BoolMessage({
    $core.bool? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  BoolMessage._();

  factory BoolMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BoolMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoolMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolMessage copyWith(void Function(BoolMessage) updates) =>
      super.copyWith((message) => updates(message as BoolMessage))
          as BoolMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BoolMessage create() => BoolMessage._();
  @$core.override
  BoolMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BoolMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoolMessage>(create);
  static BoolMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get value => $_getBF(0);
  @$pb.TagNumber(1)
  set value($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class GetMoviePosition extends $pb.GeneratedMessage {
  factory GetMoviePosition({
    $fixnum.Int64? position,
  }) {
    final result = create();
    if (position != null) result.position = position;
    return result;
  }

  GetMoviePosition._();

  factory GetMoviePosition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMoviePosition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetMoviePosition',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'position')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMoviePosition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMoviePosition copyWith(void Function(GetMoviePosition) updates) =>
      super.copyWith((message) => updates(message as GetMoviePosition))
          as GetMoviePosition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMoviePosition create() => GetMoviePosition._();
  @$core.override
  GetMoviePosition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMoviePosition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMoviePosition>(create);
  static GetMoviePosition? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get position => $_getI64(0);
  @$pb.TagNumber(1)
  set position($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPosition() => $_has(0);
  @$pb.TagNumber(1)
  void clearPosition() => $_clearField(1);
}

class InitMessage extends $pb.GeneratedMessage {
  factory InitMessage({
    $core.String? path,
  }) {
    final result = create();
    if (path != null) result.path = path;
    return result;
  }

  InitMessage._();

  factory InitMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InitMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InitMessage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitMessage copyWith(void Function(InitMessage) updates) =>
      super.copyWith((message) => updates(message as InitMessage))
          as InitMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitMessage create() => InitMessage._();
  @$core.override
  InitMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InitMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitMessage>(create);
  static InitMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);
}

class GetEpisodes extends $pb.GeneratedMessage {
  factory GetEpisodes({
    $fixnum.Int64? seriesId,
    $fixnum.Int64? sourceId,
    $core.String? fallbackImage,
  }) {
    final result = create();
    if (seriesId != null) result.seriesId = seriesId;
    if (sourceId != null) result.sourceId = sourceId;
    if (fallbackImage != null) result.fallbackImage = fallbackImage;
    return result;
  }

  GetEpisodes._();

  factory GetEpisodes.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetEpisodes.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEpisodes',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'seriesId')
    ..aInt64(2, _omitFieldNames ? '' : 'sourceId')
    ..aOS(3, _omitFieldNames ? '' : 'fallbackImage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEpisodes clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEpisodes copyWith(void Function(GetEpisodes) updates) =>
      super.copyWith((message) => updates(message as GetEpisodes))
          as GetEpisodes;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEpisodes create() => GetEpisodes._();
  @$core.override
  GetEpisodes createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetEpisodes getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEpisodes>(create);
  static GetEpisodes? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get seriesId => $_getI64(0);
  @$pb.TagNumber(1)
  set seriesId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeriesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeriesId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sourceId => $_getI64(1);
  @$pb.TagNumber(2)
  set sourceId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fallbackImage => $_getSZ(2);
  @$pb.TagNumber(3)
  set fallbackImage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFallbackImage() => $_has(2);
  @$pb.TagNumber(3)
  void clearFallbackImage() => $_clearField(3);
}

class ChannelHttpHeaders extends $pb.GeneratedMessage {
  factory ChannelHttpHeaders({
    $fixnum.Int64? id,
    $fixnum.Int64? channelId,
    $core.String? referrer,
    $core.String? userAgent,
    $core.String? httpOrigin,
    $core.bool? ignoreSsl,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (channelId != null) result.channelId = channelId;
    if (referrer != null) result.referrer = referrer;
    if (userAgent != null) result.userAgent = userAgent;
    if (httpOrigin != null) result.httpOrigin = httpOrigin;
    if (ignoreSsl != null) result.ignoreSsl = ignoreSsl;
    return result;
  }

  ChannelHttpHeaders._();

  factory ChannelHttpHeaders.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChannelHttpHeaders.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChannelHttpHeaders',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'channelId')
    ..aOS(3, _omitFieldNames ? '' : 'referrer')
    ..aOS(4, _omitFieldNames ? '' : 'userAgent')
    ..aOS(5, _omitFieldNames ? '' : 'httpOrigin')
    ..aOB(6, _omitFieldNames ? '' : 'ignoreSsl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelHttpHeaders clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChannelHttpHeaders copyWith(void Function(ChannelHttpHeaders) updates) =>
      super.copyWith((message) => updates(message as ChannelHttpHeaders))
          as ChannelHttpHeaders;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChannelHttpHeaders create() => ChannelHttpHeaders._();
  @$core.override
  ChannelHttpHeaders createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChannelHttpHeaders getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChannelHttpHeaders>(create);
  static ChannelHttpHeaders? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get channelId => $_getI64(1);
  @$pb.TagNumber(2)
  set channelId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChannelId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChannelId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get referrer => $_getSZ(2);
  @$pb.TagNumber(3)
  set referrer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReferrer() => $_has(2);
  @$pb.TagNumber(3)
  void clearReferrer() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get userAgent => $_getSZ(3);
  @$pb.TagNumber(4)
  set userAgent($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUserAgent() => $_has(3);
  @$pb.TagNumber(4)
  void clearUserAgent() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get httpOrigin => $_getSZ(4);
  @$pb.TagNumber(5)
  set httpOrigin($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHttpOrigin() => $_has(4);
  @$pb.TagNumber(5)
  void clearHttpOrigin() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get ignoreSsl => $_getBF(5);
  @$pb.TagNumber(6)
  set ignoreSsl($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIgnoreSsl() => $_has(5);
  @$pb.TagNumber(6)
  void clearIgnoreSsl() => $_clearField(6);
}

class GetEnabledSourcesMinimal extends $pb.GeneratedMessage {
  factory GetEnabledSourcesMinimal({
    $core.Iterable<$fixnum.Int64>? listId,
  }) {
    final result = create();
    if (listId != null) result.listId.addAll(listId);
    return result;
  }

  GetEnabledSourcesMinimal._();

  factory GetEnabledSourcesMinimal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetEnabledSourcesMinimal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetEnabledSourcesMinimal',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..p<$fixnum.Int64>(1, _omitFieldNames ? '' : 'listId', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnabledSourcesMinimal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetEnabledSourcesMinimal copyWith(
          void Function(GetEnabledSourcesMinimal) updates) =>
      super.copyWith((message) => updates(message as GetEnabledSourcesMinimal))
          as GetEnabledSourcesMinimal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetEnabledSourcesMinimal create() => GetEnabledSourcesMinimal._();
  @$core.override
  GetEnabledSourcesMinimal createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetEnabledSourcesMinimal getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetEnabledSourcesMinimal>(create);
  static GetEnabledSourcesMinimal? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$fixnum.Int64> get listId => $_getList(0);
}

class SourceList extends $pb.GeneratedMessage {
  factory SourceList({
    $core.Iterable<Source>? sources,
  }) {
    final result = create();
    if (sources != null) result.sources.addAll(sources);
    return result;
  }

  SourceList._();

  factory SourceList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SourceList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SourceList',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..pPM<Source>(1, _omitFieldNames ? '' : 'sources',
        subBuilder: Source.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SourceList copyWith(void Function(SourceList) updates) =>
      super.copyWith((message) => updates(message as SourceList)) as SourceList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SourceList create() => SourceList._();
  @$core.override
  SourceList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SourceList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SourceList>(create);
  static SourceList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Source> get sources => $_getList(0);
}

class SetSourceEnabled extends $pb.GeneratedMessage {
  factory SetSourceEnabled({
    $fixnum.Int64? sourceId,
    $core.bool? enabled,
  }) {
    final result = create();
    if (sourceId != null) result.sourceId = sourceId;
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  SetSourceEnabled._();

  factory SetSourceEnabled.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetSourceEnabled.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetSourceEnabled',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'sourceId')
    ..aOB(2, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSourceEnabled clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetSourceEnabled copyWith(void Function(SetSourceEnabled) updates) =>
      super.copyWith((message) => updates(message as SetSourceEnabled))
          as SetSourceEnabled;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetSourceEnabled create() => SetSourceEnabled._();
  @$core.override
  SetSourceEnabled createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetSourceEnabled getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetSourceEnabled>(create);
  static SetSourceEnabled? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sourceId => $_getI64(0);
  @$pb.TagNumber(1)
  set sourceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSourceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSourceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enabled => $_getBF(1);
  @$pb.TagNumber(2)
  set enabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnabled() => $_clearField(2);
}

enum FFIResult_Data {
  settings,
  source,
  channelList,
  boolMessage,
  moviePosition,
  headers,
  enabledSourcesMinimal,
  sourceList,
  notSet
}

class FFIResult extends $pb.GeneratedMessage {
  factory FFIResult({
    $core.bool? success,
    $core.String? errorMessage,
    Settings? settings,
    Source? source,
    ChannelList? channelList,
    BoolMessage? boolMessage,
    GetMoviePosition? moviePosition,
    ChannelHttpHeaders? headers,
    GetEnabledSourcesMinimal? enabledSourcesMinimal,
    SourceList? sourceList,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (settings != null) result.settings = settings;
    if (source != null) result.source = source;
    if (channelList != null) result.channelList = channelList;
    if (boolMessage != null) result.boolMessage = boolMessage;
    if (moviePosition != null) result.moviePosition = moviePosition;
    if (headers != null) result.headers = headers;
    if (enabledSourcesMinimal != null)
      result.enabledSourcesMinimal = enabledSourcesMinimal;
    if (sourceList != null) result.sourceList = sourceList;
    return result;
  }

  FFIResult._();

  factory FFIResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FFIResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, FFIResult_Data> _FFIResult_DataByTag = {
    3: FFIResult_Data.settings,
    4: FFIResult_Data.source,
    6: FFIResult_Data.channelList,
    7: FFIResult_Data.boolMessage,
    8: FFIResult_Data.moviePosition,
    9: FFIResult_Data.headers,
    10: FFIResult_Data.enabledSourcesMinimal,
    11: FFIResult_Data.sourceList,
    0: FFIResult_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FFIResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..oo(0, [3, 4, 6, 7, 8, 9, 10, 11])
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<Settings>(3, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.create)
    ..aOM<Source>(4, _omitFieldNames ? '' : 'source', subBuilder: Source.create)
    ..aOM<ChannelList>(6, _omitFieldNames ? '' : 'channelList',
        subBuilder: ChannelList.create)
    ..aOM<BoolMessage>(7, _omitFieldNames ? '' : 'boolMessage',
        subBuilder: BoolMessage.create)
    ..aOM<GetMoviePosition>(8, _omitFieldNames ? '' : 'moviePosition',
        subBuilder: GetMoviePosition.create)
    ..aOM<ChannelHttpHeaders>(9, _omitFieldNames ? '' : 'headers',
        subBuilder: ChannelHttpHeaders.create)
    ..aOM<GetEnabledSourcesMinimal>(
        10, _omitFieldNames ? '' : 'enabledSourcesMinimal',
        subBuilder: GetEnabledSourcesMinimal.create)
    ..aOM<SourceList>(11, _omitFieldNames ? '' : 'sourceList',
        subBuilder: SourceList.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FFIResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FFIResult copyWith(void Function(FFIResult) updates) =>
      super.copyWith((message) => updates(message as FFIResult)) as FFIResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FFIResult create() => FFIResult._();
  @$core.override
  FFIResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FFIResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FFIResult>(create);
  static FFIResult? _defaultInstance;

  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  FFIResult_Data whichData() => _FFIResult_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearData() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get errorMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set errorMessage($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  Settings get settings => $_getN(2);
  @$pb.TagNumber(3)
  set settings(Settings value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSettings() => $_has(2);
  @$pb.TagNumber(3)
  void clearSettings() => $_clearField(3);
  @$pb.TagNumber(3)
  Settings ensureSettings() => $_ensure(2);

  @$pb.TagNumber(4)
  Source get source => $_getN(3);
  @$pb.TagNumber(4)
  set source(Source value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearSource() => $_clearField(4);
  @$pb.TagNumber(4)
  Source ensureSource() => $_ensure(3);

  @$pb.TagNumber(6)
  ChannelList get channelList => $_getN(4);
  @$pb.TagNumber(6)
  set channelList(ChannelList value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasChannelList() => $_has(4);
  @$pb.TagNumber(6)
  void clearChannelList() => $_clearField(6);
  @$pb.TagNumber(6)
  ChannelList ensureChannelList() => $_ensure(4);

  @$pb.TagNumber(7)
  BoolMessage get boolMessage => $_getN(5);
  @$pb.TagNumber(7)
  set boolMessage(BoolMessage value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasBoolMessage() => $_has(5);
  @$pb.TagNumber(7)
  void clearBoolMessage() => $_clearField(7);
  @$pb.TagNumber(7)
  BoolMessage ensureBoolMessage() => $_ensure(5);

  @$pb.TagNumber(8)
  GetMoviePosition get moviePosition => $_getN(6);
  @$pb.TagNumber(8)
  set moviePosition(GetMoviePosition value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasMoviePosition() => $_has(6);
  @$pb.TagNumber(8)
  void clearMoviePosition() => $_clearField(8);
  @$pb.TagNumber(8)
  GetMoviePosition ensureMoviePosition() => $_ensure(6);

  @$pb.TagNumber(9)
  ChannelHttpHeaders get headers => $_getN(7);
  @$pb.TagNumber(9)
  set headers(ChannelHttpHeaders value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasHeaders() => $_has(7);
  @$pb.TagNumber(9)
  void clearHeaders() => $_clearField(9);
  @$pb.TagNumber(9)
  ChannelHttpHeaders ensureHeaders() => $_ensure(7);

  @$pb.TagNumber(10)
  GetEnabledSourcesMinimal get enabledSourcesMinimal => $_getN(8);
  @$pb.TagNumber(10)
  set enabledSourcesMinimal(GetEnabledSourcesMinimal value) =>
      $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasEnabledSourcesMinimal() => $_has(8);
  @$pb.TagNumber(10)
  void clearEnabledSourcesMinimal() => $_clearField(10);
  @$pb.TagNumber(10)
  GetEnabledSourcesMinimal ensureEnabledSourcesMinimal() => $_ensure(8);

  @$pb.TagNumber(11)
  SourceList get sourceList => $_getN(9);
  @$pb.TagNumber(11)
  set sourceList(SourceList value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSourceList() => $_has(9);
  @$pb.TagNumber(11)
  void clearSourceList() => $_clearField(11);
  @$pb.TagNumber(11)
  SourceList ensureSourceList() => $_ensure(9);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
