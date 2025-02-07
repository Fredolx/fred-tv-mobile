class ChannelHttpHeaders {
  int? id;
  int? channelId;
  String? referrer;
  String? userAgent;
  String? httpOrigin;
  String? ignoreSSL;

  ChannelHttpHeaders(
      {this.id,
      this.channelId,
      this.referrer,
      this.userAgent,
      this.httpOrigin,
      this.ignoreSSL});
}
