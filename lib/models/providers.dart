class Providers {
  final String? providerId;
  final String? providerName;
  final String? providerLogo;
  final String? selectedColor;

  Providers({
    this.providerId,
    this.providerName,
    this.providerLogo,
    this.selectedColor,
  });

  factory Providers.fromjson(Map<String, dynamic> json) {
    final providerId = json['providerId'];
    final providerName = json['providerName'];
    final providerLogo = json['providerLogo'];
    final selectedColor = json['selectedColor'];

    return Providers(
      providerId: providerId,
      providerName: providerName,
      providerLogo: providerLogo,
      selectedColor: selectedColor,
    );
  }
}

class ProvidersList {
  final List<Providers>? providersList;

  const ProvidersList({
    this.providersList,
  });

  factory ProvidersList.fromJson(List<dynamic> json) {
    final providersList = json;
    final providersListData =
        providersList.map((e) => Providers.fromjson(e)).toList();

    return ProvidersList(
      providersList: providersListData,
    );
  }
}
