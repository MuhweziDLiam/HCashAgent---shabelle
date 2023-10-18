class ConvertAmount {
  final bool? status;
  final String? response;
  final String? convertedAmount;
  final String? conversionCharge;

  ConvertAmount(
      {this.status,
      this.response,
      this.convertedAmount,
      this.conversionCharge});

  factory ConvertAmount.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final response = json['message'] ?? '';
    final convertedAmount = json['convertedAmount'];
    final conversionCharge = json['conversionCharge'];

    return ConvertAmount(
      status: status,
      response: response,
      convertedAmount: convertedAmount,
      conversionCharge: conversionCharge,
    );
  }
}
