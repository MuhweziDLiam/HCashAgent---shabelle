class OnboardingCountries {
  final bool? status;
  final String? responseMessage;
  List<OnboardingCountry>? countryList;

  OnboardingCountries({
    this.status,
    this.responseMessage,
    this.countryList,
  });

  factory OnboardingCountries.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'] ?? '';
    final countriesList =
        json['supportedCountries']['idTypes'] as List<dynamic>;
    final countriesListData = status == true
        ? countriesList.map((e) => OnboardingCountry.fromjson(e)).toList()
        : <OnboardingCountry>[];

    return OnboardingCountries(
      status: status,
      countryList: countriesListData,
      responseMessage: responseMessage,
    );
  }
}

class OnboardingCountry {
  final String? code;
  final String? name;
  final String? countryStatus;

  OnboardingCountry({this.code, this.name, this.countryStatus});

  factory OnboardingCountry.fromjson(Map<String, dynamic> json) {
    final code = json['country_code'];
    final name = json['country_name'];
    final countryStatus = json['status'];

    return OnboardingCountry(
      code: code,
      countryStatus: countryStatus,
      name: name,
    );
  }
}
