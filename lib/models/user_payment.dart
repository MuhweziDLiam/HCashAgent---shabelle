class UserPayment {
  final bool? status;
  final String? response;
  final String? responseMessage;
  final String? transactionId;

  UserPayment(
      {this.status, this.response, this.responseMessage, this.transactionId});

  factory UserPayment.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final response = json['status'];
    final transactionId = json['transactionId'] ?? '';
    final responseMessage = json['message'] ?? '';

    return UserPayment(
      status: status,
      response: response,
      transactionId: transactionId,
      responseMessage: responseMessage,
    );
  }
}

class UserCashOut {
  final bool? status;
  final String? response;
  final String? accountName;
  final String? amount;
  final String? phoneNumber;
  final String? responseMessage;
  final String? transactionId;

  UserCashOut(
      {this.status,
      this.response,
      this.responseMessage,
      this.transactionId,
      this.accountName,
      this.amount,
      this.phoneNumber});

  factory UserCashOut.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final response = json['status'];
    final accountName = json['walletName'];
    final amount = json['transactionAmount'];
    final phoneNumber = json['phoneNumber'];
    final transactionId = json['appReference'] ?? '';
    final responseMessage = json['message'] ?? '';

    return UserCashOut(
      status: status,
      response: response,
      accountName: accountName,
      amount: amount,
      phoneNumber: phoneNumber,
      transactionId: transactionId,
      responseMessage: responseMessage,
    );
  }
}
