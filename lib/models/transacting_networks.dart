class TransactingNetworks {
  List<TransactingNetwork>? transactingNetwork;

  TransactingNetworks({
    this.transactingNetwork,
  });

  factory TransactingNetworks.fromjson(List<dynamic> json) {
    final networksList = json;
    final networksListData =
        networksList.map((e) => TransactingNetwork.fromjson(e)).toList();
    return TransactingNetworks(
      transactingNetwork: networksListData,
    );
  }
}

class TransactingNetwork {
  final String? dailCode;
  final String? countryCode;
  final String? countryName;
  final List<Networks>? networks;

  TransactingNetwork(
      {this.dailCode, this.countryCode, this.countryName, this.networks});

  factory TransactingNetwork.fromjson(Map<String, dynamic> json) {
    final dailCode = json['dailCode'];
    final countryCode = json['countryCode'];
    final countryName = json['countryName'];
    final networks = json['networks'] as List<dynamic>;
    final networksData = networks.map((e) => Networks.fromjson(e)).toList();

    return TransactingNetwork(
      dailCode: dailCode,
      countryCode: countryCode,
      countryName: countryName,
      networks: networksData,
    );
  }
}

class Networks {
  final String? name;
  final String? img;

  Networks({
    this.name,
    this.img,
  });

  factory Networks.fromjson(Map<String, dynamic> json) {
    final name = json['networkName'];
    final img = json['networkImg'];

    return Networks(
      name: name,
      img: img,
    );
  }
}
