class UserBalance {
  final bool? status;
  final String? response;
  final String? accountBalance;
  final String? schoolFeesLoan;
  final String? hijjaSavings;

  UserBalance({
    this.status,
    this.response,
    this.accountBalance,
    this.schoolFeesLoan,
    this.hijjaSavings,
  });

  factory UserBalance.fromjson(Map<String, dynamic> json) {
    final status = json['success'];

    final response = json['message'] ?? '';
    final accountBalance = json['balance'] ?? '0';
    final schoolFeesLoan = json['schoolFeesLoan'];
    final hijjaSavings = json['hijjaSavings'];

    return UserBalance(
      status: status,
      response: response,
      accountBalance: accountBalance,
      schoolFeesLoan: schoolFeesLoan,
      hijjaSavings: hijjaSavings,
    );
  }
}
