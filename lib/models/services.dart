class ServiceList {
  final List<Service>? serviceList;

  const ServiceList({
    this.serviceList,
  });

  factory ServiceList.fromJson(List<dynamic> json) {
    final serviceList = json;
    final serviceListData =
        serviceList.map((e) => Service.fromJson(e)).toList();

    return ServiceList(
      serviceList: serviceListData,
    );
  }
}

class Service {
  final String? serviceCode;
  final String? serviceName;
  final String? serviceDescription;
  final String? serviceImg;

  const Service({
    this.serviceCode,
    this.serviceName,
    this.serviceDescription,
    this.serviceImg,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceCode: json['serviceCode'],
      serviceName: json['serviceName'],
      serviceDescription: json['serviceDescription'],
      serviceImg: json['serviceImg'],
    );
  }
}
