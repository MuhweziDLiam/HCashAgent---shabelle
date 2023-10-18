import 'package:intl/intl.dart';

class User {
  final bool? status;
  final String? accountType;
  final String? accountNumber;
  final String? agentName;
  final String? userName;
  final String? phoneNumber;
  final String? accountBalance;
  final String? currencyCode;
  final String? responseMessage;

  User({
    this.status,
    this.accountType,
    this.accountNumber,
    this.agentName,
    this.userName,
    this.phoneNumber,
    this.accountBalance,
    this.responseMessage,
    this.currencyCode,
  });

  factory User.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountType = json['account_type'];
    final accountNumber = json['account_no'];
    final agentName = json['agentName'];
    final phoneNumber = json['agentPhone'] ?? '+256708384495';
    final responseMessage = json['message'] ?? '';
    final accountBalance = json['account_balance'] ?? '0';
    final currencyCode = json['currency_code'] ?? 'ETB';

    return User(
      status: status,
      accountType: accountType,
      accountNumber: accountNumber,
      agentName: agentName,
      responseMessage: responseMessage,
      phoneNumber: phoneNumber,
      accountBalance: accountBalance,
      currencyCode: currencyCode,
    );
  }
}

class GoogleUser {
  final bool? status;
  final String? responseMessage;
  final String? gender;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? dob;
  final String? phoneNumber;
  final String? profilePicture;

  GoogleUser({
    this.firstName,
    this.lastName,
    this.gender,
    this.dob,
    this.status,
    this.responseMessage,
    this.email,
    this.phoneNumber,
    this.profilePicture,
  });

  factory GoogleUser.fromjson(Map<String, dynamic> json) {
    NumberFormat formatter = NumberFormat('00');
    final firstName = json['names'] != null
        ? (json['names'] as List<dynamic>).elementAt(0)['givenName']
        : '';

    final lastName = json['names'] != null
        ? (json['names'] as List<dynamic>).elementAt(0)['familyName']
        : '';

    final email = json['emailAddresses'] != null
        ? (json['emailAddresses'] as List<dynamic>).elementAt(0)['value']
        : '';

    final dob = json['birthdays'] != null
        ? '${(json['birthdays'] as List<dynamic>).elementAt(1)['date']['year']}-${formatter.format((json['birthdays'] as List<dynamic>).elementAt(1)['date']['month'])}-${formatter.format((json['birthdays'] as List<dynamic>).elementAt(1)['date']['day'])}'
        : '';

    final phoneNumber = json['phoneNumbers'] != null
        ? (json['phoneNumbers'] as List<dynamic>).elementAt(0)['canonicalForm']
        : '';

    final profilePicture = json['photos'] != null
        ? (json['photos'] as List<dynamic>).elementAt(0)['url']
        : '';

    final gender = json['genders'] != null
        ? (json['genders'] as List<dynamic>).elementAt(0)['formattedValue']
        : '';
    final status = json['status'] ?? true;

    final responseMessage = json['responseMessage'] ?? '';

    return GoogleUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      dob: dob,
      status: status,
      responseMessage: responseMessage,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
    );
  }
}

class RegisterResponse {
  final bool? status;
  final int? accountNumber;
  final String? responseMessage;

  RegisterResponse({this.status, this.responseMessage, this.accountNumber});

  factory RegisterResponse.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountNumber = json['accountNumber'];
    final responseMessage = json['message'];
    return RegisterResponse(
      status: status,
      accountNumber: accountNumber,
      responseMessage: responseMessage,
    );
  }
}
