class Beneficiaries {
  final bool? status;
  List<Beneficiary>? beneficiaryList;
  final String? responseMessage;

  Beneficiaries({
    this.status,
    this.responseMessage,
    this.beneficiaryList,
  });

  factory Beneficiaries.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'] ?? '';
    final beneficiariesList = json['beneficiaries'] as List<dynamic>;
    final beneficiariesListData = status == true
        ? beneficiariesList.map((e) => Beneficiary.fromjson(e)).toList()
        : <Beneficiary>[];

    return Beneficiaries(
      status: status,
      responseMessage: responseMessage,
      beneficiaryList: beneficiariesListData,
    );
  }
}

class Beneficiary {
  final String? beneficiaryName;
  final String? accountUrl;
  final String? beneficiaryAccount;
  final String? serviceName;

  Beneficiary({
    this.beneficiaryName,
    this.beneficiaryAccount,
    this.accountUrl,
    this.serviceName,
  });

  factory Beneficiary.fromjson(Map<String, dynamic> json) {
    final beneficiaryName = json['beneficiaryName'];
    final beneficiaryAccount = json['beneficiaryAccount'];
    final accountUrl = json['accountUrl'];
    final serviceName = json['serviceName'];

    return Beneficiary(
        beneficiaryName: beneficiaryName,
        beneficiaryAccount: beneficiaryAccount,
        accountUrl: accountUrl,
        serviceName: serviceName);
  }

  @override
  String toString() {
    return 'beneficiaryName: $beneficiaryName, beneficiaryAccount: $beneficiaryAccount, serviceName: $serviceName, accountUrl: $accountUrl';
  }
}
