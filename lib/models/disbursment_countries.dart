class DisbursementCountries {
  final bool? status;
  final String? responseMessage;
  List<DisbursmentCountry>? countryList;

  DisbursementCountries({
    this.status,
    this.responseMessage,
    this.countryList,
  });

  factory DisbursementCountries.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'] ?? '';
    final countriesList = json['disbursmentCountries'] as List<dynamic>;
    final countriesListData = status == true
        ? countriesList.map((e) => DisbursmentCountry.fromjson(e)).toList()
        : <DisbursmentCountry>[];

    return DisbursementCountries(
      status: status,
      countryList: countriesListData,
      responseMessage: responseMessage,
    );
  }
}

class DisbursmentCountry {
  final String? code;
  final String? name;

  DisbursmentCountry({this.code, this.name});

  factory DisbursmentCountry.fromjson(Map<String, dynamic> json) {
    final code = json['code'];
    final name = json['name'];

    return DisbursmentCountry(
      code: code,
      name: name,
    );
  }
}
