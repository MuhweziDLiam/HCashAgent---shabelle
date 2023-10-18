class AuthorizeTransaction {
  final bool? status;
  final String? response;
  final String? responseMessage;

  AuthorizeTransaction({this.status, this.response, this.responseMessage});

  factory AuthorizeTransaction.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final response = json['status'];
    final responseMessage =
        json['message'] ?? 'Something occured, please try again.';

    return AuthorizeTransaction(
      status: status,
      response: response,
      responseMessage: responseMessage,
    );
  }
}

class SendOTP {
  final bool? status;
  final String? responseMessage;

  SendOTP({this.status, this.responseMessage});

  factory SendOTP.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'];
    return SendOTP(status: status, responseMessage: responseMessage);
  }
}
