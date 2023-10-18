class AMLList {
  final bool? status;
  final List<AML>? amlList;
  final String? responseMessage;

  const AMLList({
    this.status,
    this.amlList,
    this.responseMessage,
  });

  factory AMLList.fromJson(Map<String, dynamic> json) {
    final status = json['success'];
    final amlList = json['amlConfigObjList'] as List;
    final amlListData =
        status == true ? amlList.map((e) => AML.fromJson(e)).toList() : <AML>[];
    final responseMessage = json['message'] ?? '';

    return AMLList(
      status: status,
      amlList: amlListData,
      responseMessage: responseMessage,
    );
  }
}

class AML {
  final String? configKey;
  final String? description;
  final String? tranType;
  final String? configValue;

  const AML({
    this.configKey,
    this.description,
    this.tranType,
    this.configValue,
  });

  factory AML.fromJson(Map<String, dynamic> json) {
    return AML(
      configKey: json['config_key'],
      description: json['config_description'],
      tranType: json['tran_type'],
      configValue: json['config_value'],
    );
  }
}
