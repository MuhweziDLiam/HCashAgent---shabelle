import 'package:pivotpay/models/bills.dart';

class AppInfo {
  final bool? status;
  final String? appVersion;
  final String? cardUrl;
  final String? reviewStatus;
  final String? email;
  final String? mtnSupportLine;
  final String? airtelSupportLine;
  final String? whatsapp;
  final String? facebook;
  final String? twitter;
  final String? website;
  final String? supportedCurrencies;
  List<Bills>? billList;
  final String? responseMessage;

  AppInfo({
    this.status,
    this.appVersion,
    this.cardUrl,
    this.reviewStatus,
    this.email,
    this.mtnSupportLine,
    this.airtelSupportLine,
    this.whatsapp,
    this.facebook,
    this.twitter,
    this.website,
    this.responseMessage,
    this.billList,
    this.supportedCurrencies,
  });

  factory AppInfo.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final appVersion = json['appVersion'];
    final cardUrl = json['cardUrl'];
    final email = json['email'];
    final reviewStatus = json['reviewStatus'];
    final mtnSupportLine = json['MTNSupportLine'];
    final airtelSupportLine = json['AIRTELSupportLine'];
    final whatsapp = json['whatsapp'];
    final facebook = json['facebook'];
    final twitter = json['twitter'];
    final website = json['website'];
    final responseMessage = json['message'];
    final supportedCurrencies = json['currencies'];
    final bill = json['bills'] as List<dynamic>;
    final billList = bill.isNotEmpty
        ? bill.map((e) => Bills.fromjson(e)).toList()
        : <Bills>[];

    return AppInfo(
      status: status,
      appVersion: appVersion,
      cardUrl: cardUrl,
      reviewStatus: reviewStatus,
      mtnSupportLine: mtnSupportLine,
      email: email,
      airtelSupportLine: airtelSupportLine,
      whatsapp: whatsapp,
      facebook: facebook,
      twitter: twitter,
      responseMessage: responseMessage,
      website: website,
      billList: billList,
      supportedCurrencies: supportedCurrencies,
    );
  }
}
