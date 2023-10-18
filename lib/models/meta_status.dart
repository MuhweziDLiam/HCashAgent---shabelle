class MetaStatus {
  final bool? status;
  final String? metaStatus;
  final String? responseMessage;

  MetaStatus({this.status, this.metaStatus, this.responseMessage});

  factory MetaStatus.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final metaStatus = json['identity'] ?? '';
    final responseMessage = json['message'] ?? '';

    return MetaStatus(
      status: status,
      metaStatus: metaStatus,
      responseMessage: responseMessage,
    );
  }
}
