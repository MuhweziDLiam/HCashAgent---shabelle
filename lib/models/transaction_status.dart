class TransactionStatus {
  final bool? status;
  final String? response;
  final String? responseMessage;

  TransactionStatus({this.status, this.response, this.responseMessage});

  factory TransactionStatus.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final response = json['status'];
    final responseMessage = json['message'];

    return TransactionStatus(
      status: status,
      response: response,
      responseMessage: responseMessage,
    );
  }
}
