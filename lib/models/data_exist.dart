class DeviceId {
  final bool? status;
  final String? responseMessage;

  DeviceId({this.status, this.responseMessage});

  factory DeviceId.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'];
    return DeviceId(status: status, responseMessage: responseMessage);
  }
}

class PhoneNumber {
  final bool? status;
  final String? responseMessage;

  PhoneNumber({this.status, this.responseMessage});

  factory PhoneNumber.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'];
    return PhoneNumber(status: status, responseMessage: responseMessage);
  }
}

class AccountNumber {
  final bool? status;
  final String? responseMessage;

  AccountNumber({
    this.status,
    this.responseMessage,
  });

  factory AccountNumber.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'];
    return AccountNumber(
      status: status,
      responseMessage: responseMessage,
    );
  }
}

class AccountDetails {
  final bool? status;
  final String? responseMessage, countryCode, email, phoneNumber;

  AccountDetails({
    this.status,
    this.responseMessage,
    this.countryCode,
    this.email,
    this.phoneNumber,
  });

  factory AccountDetails.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final countryCode = json['country_code'];
    final email = json['email'];
    final phoneNumber = json['phone_number'];
    final responseMessage = json['message'];
    return AccountDetails(
      status: status,
      responseMessage: responseMessage,
      countryCode: countryCode,
      email: email,
      phoneNumber: phoneNumber,
    );
  }
}
