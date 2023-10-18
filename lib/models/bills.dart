class Bills {
  final String? billerId;
  final String? billerCategory;
  final String? billerName;
  final String? billerAmount;
  final String billerLogo;

  Bills({
    this.billerId,
    this.billerCategory,
    this.billerName,
    this.billerAmount,
    this.billerLogo = '',
  });

  factory Bills.fromjson(Map<String, dynamic> json) {
    final billerId = json['biller_id'];
    final billerCategory = json['bill_category'];
    final billerName = json['bill_name'];
    String billerAmount = json['bill_amount'].toString();
    final billerLogo = json['biller_logo'] ?? '';

    return Bills(
      billerId: billerId,
      billerCategory: billerCategory,
      billerName: billerName,
      billerAmount: billerAmount,
      billerLogo: billerLogo,
    );
  }

  factory Bills.fromMap(Map<String, dynamic> json) {
    final billerId = json['biller_code'];
    final billerCategory = json['biller_category'];
    final billerName = json['biller_name'];
    final billerAmount = json['biller_amount'];
    final billerLogo = json['biller_logo'];

    return Bills(
      billerId: billerId,
      billerCategory: billerCategory,
      billerName: billerName,
      billerAmount: billerAmount,
      billerLogo: billerLogo,
    );
  }

  Map<String, String> toMap() {
    return {
      'biller_code': billerId!,
      'biller_name': billerName!,
      'biller_category': billerCategory!,
      'biller_amount': billerAmount!,
      'biller_logo': billerLogo
    };
  }
}

class ConfigBills {
  final String? billerCode;
  final String? billerName;
  final String? billerLogo;
  final String? billCategory;
  final bool? hasPackages;

  ConfigBills(
      {this.billerCode,
      this.billerName,
      this.billerLogo,
      this.hasPackages,
      this.billCategory});

  factory ConfigBills.fromjson(Map<String, dynamic> json) {
    final billerCode = json['billerCode'];
    final billerName = json['billerName'];
    final billerLogo = json['billerLogo'];
    final billCategory = json['billCategory'];
    final hasPackages = json['hasPackages'];

    return ConfigBills(
      billerCode: billerCode,
      billerName: billerName,
      billerLogo: billerLogo,
      billCategory: billCategory,
      hasPackages: hasPackages,
    );
  }
}

class ConfigBillsList {
  final List<ConfigBills>? configBillsList;

  const ConfigBillsList({
    this.configBillsList,
  });

  factory ConfigBillsList.fromJson(List<dynamic> json) {
    final configBillsList = json;
    final configBillsListData =
        configBillsList.map((e) => ConfigBills.fromjson(e)).toList();

    return ConfigBillsList(
      configBillsList: configBillsListData,
    );
  }
}

class BillCategory {
  final String? billName;
  final String? billId;

  BillCategory({
    this.billName,
    this.billId,
  });

  factory BillCategory.fromjson(Map<String, dynamic> json) {
    final billName = json['billName'];
    final billId = json['billId'];

    return BillCategory(
      billId: billId,
      billName: billName,
    );
  }
}

class BillCategoryList {
  final List<BillCategory>? billCategoryList;

  const BillCategoryList({
    this.billCategoryList,
  });

  factory BillCategoryList.fromJson(List<dynamic> json) {
    final billCategoryList = json;
    final billCategoryListData =
        billCategoryList.map((e) => BillCategory.fromjson(e)).toList();

    return BillCategoryList(
      billCategoryList: billCategoryListData,
    );
  }
}
