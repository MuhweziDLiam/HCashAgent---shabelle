class ValidateAccount {
  final bool? status;
  final String? responseMessage;
  final String? accountName;
  final String? accountNumber;
  final String? accountUrl;

  ValidateAccount({
    this.status,
    this.responseMessage,
    this.accountNumber,
    this.accountName,
    this.accountUrl,
  });

  factory ValidateAccount.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountName = json['name'] ?? json['accountName'] ?? '';
    final accountNumber = json['accountNumber'];
    final responseMessage = json['message'] ?? '';
    final accountUrl = json['accountUrl'] ?? '';

    return ValidateAccount(
      status: status,
      accountName: accountName,
      accountNumber: accountNumber,
      responseMessage: responseMessage,
      accountUrl: accountUrl,
    );
  }
}

class ValidateBillAccount {
  final bool? status;
  final String? responseMessage;
  final String? accountName;
  final String? balance;
  final String? authCode;
  final String? serviceFee;
  final String? schoolCode;
  final String? schoolName;
  final String? schoolStream;
  final String? tranCharge;
  final String? packageDetails;

  ValidateBillAccount(
      {this.status,
      this.responseMessage,
      this.accountName,
      this.balance,
      this.authCode,
      this.schoolCode,
      this.schoolName,
      this.schoolStream,
      this.serviceFee,
      this.tranCharge,
      this.packageDetails});

  factory ValidateBillAccount.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountName = json['accountName'] ?? '';
    final responseMessage = json['message'] ?? '';
    final balance = json['outstandingBalance'] ?? '0';
    final authCode = json['authCode'];
    final schoolName = json['schoolName'] ?? '';
    final schoolCode = json['schoolCode'] ?? '';
    final schoolStream = json['schoolClass'] ?? '';
    final serviceFee = json['serviceFee'];
    final tranCharge = json['tranCharge'];
    final packageDetails = json['packageDetails'];

    return ValidateBillAccount(
        status: status,
        accountName: accountName,
        responseMessage: responseMessage,
        balance: balance,
        schoolCode: schoolCode,
        schoolName: schoolName,
        schoolStream: schoolStream,
        authCode: authCode,
        serviceFee: serviceFee,
        tranCharge: tranCharge,
        packageDetails: packageDetails);
  }
}

class ValidateBodaBanjaAccount {
  final bool? status;
  final String? responseMessage;
  final String? accountName;
  final String? balance;
  final String? authCode;
  final String? proposalNumber;
  final String? proposalCode;
  final String? productType;
  final String? userNumber;
  final String? tranCharge;

  ValidateBodaBanjaAccount({
    this.status,
    this.responseMessage,
    this.accountName,
    this.balance,
    this.authCode,
    this.proposalNumber,
    this.proposalCode,
    this.productType,
    this.userNumber,
    this.tranCharge,
  });

  factory ValidateBodaBanjaAccount.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountName = json['accountName'] ?? '';
    final responseMessage = json['message'] ?? '';
    final balance = json['outstandingBalance'] ?? '0';
    final authCode = json['authCode'];
    final proposalNumber = json['proposalNumber'] ?? '';
    final proposalCode = json['proposalCode'] ?? '';
    final productType = json['productType'] ?? '';
    final userNumber = json['userNumber'];
    final tranCharge = json['tranCharge'];

    return ValidateBodaBanjaAccount(
      status: status,
      accountName: accountName,
      responseMessage: responseMessage,
      balance: balance,
      proposalCode: proposalCode,
      proposalNumber: proposalNumber,
      productType: productType,
      authCode: authCode,
      userNumber: userNumber,
      tranCharge: tranCharge,
    );
  }
}

class ValidateWenrecoAccount {
  final bool? status;
  final String? responseMessage;
  final String? accountName;
  final String? balance;
  final String? tranCharge;

  ValidateWenrecoAccount({
    this.status,
    this.responseMessage,
    this.accountName,
    this.balance,
    this.tranCharge,
  });

  factory ValidateWenrecoAccount.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final accountName = json['accountName'] ?? '';
    final responseMessage = json['message'] ?? '';
    final balance = json['outstandingBalance'] ?? '0';
    final tranCharge = json['tranCharge'];

    return ValidateWenrecoAccount(
      status: status,
      accountName: accountName,
      responseMessage: responseMessage,
      balance: balance,
      tranCharge: tranCharge,
    );
  }
}
