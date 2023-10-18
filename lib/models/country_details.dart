class CountryDetails {
  final bool? status;
  final String? responseMessage;
  final String? currency;

  CountryDetails({
    this.status,
    this.responseMessage,
    this.currency,
  });

  factory CountryDetails.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final currency = json['currency'];
    final responseMessage = json['message'] ?? '';

    return CountryDetails(
      status: status,
      currency: currency,
      responseMessage: responseMessage,
    );
  }
}
