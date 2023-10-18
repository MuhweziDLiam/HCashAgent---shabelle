class PinModel {
  final bool? status;
  final String? reponseMessage;

  PinModel({this.status, this.reponseMessage});

  factory PinModel.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final reponseMessage = json['message'];
    return PinModel(status: status, reponseMessage: reponseMessage);
  }
}
