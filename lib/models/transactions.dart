class Transactions {
  final bool? status;
  List<Transaction>? transactionList;
  final String? responseMessage;

  Transactions({
    this.status,
    this.responseMessage,
    this.transactionList,
  });

  factory Transactions.fromjson(Map<String, dynamic> json) {
    final status = json['success'];
    final responseMessage = json['message'] ?? '';
    final transactionList = json['transactions'] as List<dynamic>;
    final transactionListData = status == true
        ? transactionList.map((e) => Transaction.fromjson(e)).toList()
        : <Transaction>[];

    return Transactions(
      status: status,
      responseMessage: responseMessage,
      transactionList: transactionListData,
    );
  }
}

class Transaction {
  final String fromAccount;
  final String senderName;
  final String appReference;
  final String serviceName;
  final String toAccount;
  final String narration;
  final String processedDate;
  final String fromAmount;
  final String recipientName;
  final String fromCurrency;
  final String addendum1;
  final String units;
  final String billerCharge;
  final String addendum2;
  final String recipietNo;
  final String tranStatus;
  final String serviceAction;

  Transaction({
    this.fromAccount = '',
    this.senderName = '',
    this.appReference = '',
    this.serviceName = '',
    this.toAccount = '',
    this.narration = '',
    this.processedDate = '',
    this.fromAmount = '0',
    this.recipientName = '',
    this.fromCurrency = '',
    this.addendum1 = '',
    this.units = '',
    this.billerCharge = '0',
    this.addendum2 = '',
    this.recipietNo = '',
    this.tranStatus = '',
    this.serviceAction = '',
  });

  factory Transaction.fromjson(Map<String, dynamic> json) {
    final fromAccount = json['from_account'];
    final senderName = json['sender_name'];
    final appReference = json['app_reference'];
    final serviceName = json['service_name'];
    final toAccount = json['to_account'];
    final narration = json['narration'];
    final processedDate = json['processed_date'];
    final fromAmount = json['from_amount'];
    final recipientName = json['recepient_name'];
    final fromCurrency = json['from_currency'];
    final addendum1 = json['addendum1'];
    final units = json['units'];
    final billerCharge = json['biller_charge'];
    final addendum2 = json['addendum2'];
    final recipietNo = json['receipt_no'];
    final tranStatus = json['tran_status'];
    final serviceAction = json['service_action'];

    return Transaction(
      fromAccount: fromAccount,
      senderName: senderName,
      appReference: appReference,
      serviceName: serviceName,
      toAccount: toAccount,
      narration: narration,
      processedDate: processedDate,
      fromAmount: fromAmount,
      recipientName: recipientName,
      fromCurrency: fromCurrency,
      addendum1: addendum1,
      units: units ?? '',
      billerCharge: billerCharge,
      addendum2: addendum2 ?? '',
      recipietNo: recipietNo ?? '',
      tranStatus: tranStatus,
      serviceAction: serviceAction,
    );
  }
}
