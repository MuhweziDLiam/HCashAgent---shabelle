class Packages {
  final String? providerId;
  final String? packageName;
  final String? packagePrice;
  final String? packageColor;
  final List<String>? packageDetails;
  final List<String>? paymentPlans;

  Packages({
    this.providerId,
    this.packageName,
    this.packagePrice,
    this.packageColor,
    this.packageDetails,
    this.paymentPlans,
  });

  factory Packages.fromjson(Map<String, dynamic> json) {
    final providerId = json['providerId'];
    final packageName = json['packageName'];
    final packagePrice = json['packagePrice'];
    final packageColor = json['packageColor'];
    final packageDetailsData = List<String>.from(json['packageDetails']);
    final paymentPlans = List<String>.from(json['paymentPlans']);

    return Packages(
      providerId: providerId,
      packageName: packageName,
      packagePrice: packagePrice,
      packageColor: packageColor,
      packageDetails: packageDetailsData,
      paymentPlans: paymentPlans,
    );
  }
}

class PackagesList {
  final List<Packages>? packagesList;

  const PackagesList({
    this.packagesList,
  });

  factory PackagesList.fromJson(List<dynamic> json) {
    final packagesList = json;
    final packagesListData =
        packagesList.map((e) => Packages.fromjson(e)).toList();

    return PackagesList(
      packagesList: packagesListData,
    );
  }
}
