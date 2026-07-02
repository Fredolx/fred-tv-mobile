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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    $core.String? mpvParams,
    $core.bool? useStreamCaching,
    $core.int? defaultView,
    $core.int? volume,
    $core.bool? refreshOnStart,
    $core.int? zoom,
    $core.int? defaultSort,
  }) {
    final result = create();
    if (mpvParams != null) result.mpvParams = mpvParams;
    if (useStreamCaching != null) result.useStreamCaching = useStreamCaching;
    if (defaultView != null) result.defaultView = defaultView;
    if (volume != null) result.volume = volume;
    if (refreshOnStart != null) result.refreshOnStart = refreshOnStart;
    if (zoom != null) result.zoom = zoom;
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
    ..aOS(2, _omitFieldNames ? '' : 'mpvParams')
    ..aOB(3, _omitFieldNames ? '' : 'useStreamCaching')
    ..aI(4, _omitFieldNames ? '' : 'defaultView',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'volume', fieldType: $pb.PbFieldType.OU3)
    ..aOB(6, _omitFieldNames ? '' : 'refreshOnStart')
    ..aI(9, _omitFieldNames ? '' : 'zoom', fieldType: $pb.PbFieldType.OU3)
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

  @$pb.TagNumber(2)
  $core.String get mpvParams => $_getSZ(0);
  @$pb.TagNumber(2)
  set mpvParams($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasMpvParams() => $_has(0);
  @$pb.TagNumber(2)
  void clearMpvParams() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get useStreamCaching => $_getBF(1);
  @$pb.TagNumber(3)
  set useStreamCaching($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(3)
  $core.bool hasUseStreamCaching() => $_has(1);
  @$pb.TagNumber(3)
  void clearUseStreamCaching() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get defaultView => $_getIZ(2);
  @$pb.TagNumber(4)
  set defaultView($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultView() => $_has(2);
  @$pb.TagNumber(4)
  void clearDefaultView() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get volume => $_getIZ(3);
  @$pb.TagNumber(5)
  set volume($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasVolume() => $_has(3);
  @$pb.TagNumber(5)
  void clearVolume() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get refreshOnStart => $_getBF(4);
  @$pb.TagNumber(6)
  set refreshOnStart($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(6)
  $core.bool hasRefreshOnStart() => $_has(4);
  @$pb.TagNumber(6)
  void clearRefreshOnStart() => $_clearField(6);

  @$pb.TagNumber(9)
  $core.int get zoom => $_getIZ(5);
  @$pb.TagNumber(9)
  set zoom($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(9)
  $core.bool hasZoom() => $_has(5);
  @$pb.TagNumber(9)
  void clearZoom() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get defaultSort => $_getIZ(6);
  @$pb.TagNumber(10)
  set defaultSort($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(10)
  $core.bool hasDefaultSort() => $_has(6);
  @$pb.TagNumber(10)
  void clearDefaultSort() => $_clearField(10);
}

enum FFIResult_Data { settings, source, notSet }

class FFIResult extends $pb.GeneratedMessage {
  factory FFIResult({
    $core.bool? success,
    $core.String? errorMessage,
    Settings? settings,
    Source? source,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (settings != null) result.settings = settings;
    if (source != null) result.source = source;
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
    0: FFIResult_Data.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FFIResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'generated_proto'),
      createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<Settings>(3, _omitFieldNames ? '' : 'settings',
        subBuilder: Settings.create)
    ..aOM<Source>(4, _omitFieldNames ? '' : 'source', subBuilder: Source.create)
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
  FFIResult_Data whichData() => _FFIResult_DataByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
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
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
