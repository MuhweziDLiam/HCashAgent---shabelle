import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pivotpay/functions/shared_modules.dart';
import 'package:pivotpay/models/aml.dart';
import 'package:pivotpay/models/app_info.dart';
import 'package:pivotpay/models/authorize_transaction.dart';
import 'package:pivotpay/models/beneficiary.dart';
import 'package:pivotpay/models/change_pin.dart';
import 'package:pivotpay/models/convert_amount.dart';
import 'package:pivotpay/models/country_details.dart';
import 'package:pivotpay/models/data_exist.dart';
import 'package:pivotpay/models/disbursment_countries.dart';
import 'package:pivotpay/models/meta_status.dart';
import 'package:pivotpay/models/onboarding_countries.dart';
import 'package:pivotpay/models/transaction_status.dart';
import 'package:pivotpay/models/transactions.dart';
import 'package:pivotpay/models/user.dart';
import 'package:pivotpay/models/user_balance.dart';
import 'package:pivotpay/models/user_payment.dart';
import 'package:pivotpay/models/validate_account.dart';
import 'package:pivotpay/utils/apis.dart';

Future<DeviceId> checkDeviceId(BuildContext context, Map data) async {
  const String url = baseUrl + checkDeviceIdEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return DeviceId.fromjson(json);
  } else {
    return DeviceId(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<PhoneNumber> checkPhoneNumber(BuildContext context, Map data) async {
  const String url = baseUrl + checkPhoneNumberEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return PhoneNumber.fromjson(json);
  } else {
    return PhoneNumber(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<SendOTP> sendOTP(BuildContext context, Map data) async {
  const String url = baseUrl2 + sendOTPEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return SendOTP.fromjson(json);
  } else {
    return SendOTP(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<AccountNumber> checkUserNameExists(
    BuildContext context, Map data) async {
  const String url = baseUrl + checkUserNameEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return AccountNumber.fromjson(json);
  } else {
    return AccountNumber(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<AccountDetails> checkUserName(BuildContext context, Map data) async {
  const String url = baseUrl + checkUserEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return AccountDetails.fromjson(json);
  } else {
    return AccountDetails(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<RegisterResponse> registerUserAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl + registerUserEndPoint;
  final json = await customNetworkPostCall(
      context: context, data, url, showMessage: false);
  if (json != null) {
    return RegisterResponse.fromjson(json);
  } else {
    return RegisterResponse(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<PinModel> changePin(BuildContext context, Map data) async {
  const String url = baseUrl + changePinEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return PinModel.fromjson(json);
  } else {
    return PinModel(
        status: false, reponseMessage: 'Something occured, Please try again');
  }
}

Future<PinModel> resetPin(BuildContext context, Map data) async {
  const String url = baseUrl + resetPinEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return PinModel.fromjson(json);
  } else {
    return PinModel(
        status: false, reponseMessage: 'Something occured, Please try again');
  }
}

Future<User> userLogin(BuildContext context, Map data) async {
  const String url = baseUrl2 + loginEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return User.fromjson(json);
  } else {
    return User(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserPayment> processUserPayment(BuildContext context, Map data) async {
  const String url = baseUrl2 + processUserPaymentEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserPayment.fromjson(json);
  } else {
    return UserPayment(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserPayment> processAgentTransaction(
    BuildContext context, Map data) async {
  const String url = baseUrl2 + processCashOutEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserPayment.fromjson(json);
  } else {
    return UserPayment(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserCashOut> getCashOutDetails(BuildContext context, Map data) async {
  const String url = baseUrl2 + requestCashOutEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserCashOut.fromjson(json);
  } else {
    return UserCashOut(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserPayment> processBillPayment(BuildContext context, Map data) async {
  const String url = baseUrl + processBillPaymentEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserPayment.fromjson(json);
  } else {
    return UserPayment(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserPayment> processLoanRepayment(BuildContext context, Map data) async {
  const String url = baseUrl + processLoanRepaymentEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserPayment.fromjson(json);
  } else {
    return UserPayment(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserPayment> processWenrecoPayment(
    BuildContext context, Map data) async {
  const String url = baseUrl + processWenrecoPaymentEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserPayment.fromjson(json);
  } else {
    return UserPayment(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateAccount> validateHcashAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl2 + validatePivotPayAccountEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateAccount.fromjson(json);
  } else {
    return ValidateAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<Transactions> getAgentStatement(BuildContext context, Map data) async {
  const String url = baseUrl2 + getAgentStatementEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return Transactions.fromjson(json);
  } else {
    return Transactions(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateBillAccount> validateBillAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl + validateGenericBillEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateBillAccount.fromjson(json);
  } else {
    return ValidateBillAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateBillAccount> validateBankAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl + validateBankAccountEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateBillAccount.fromjson(json);
  } else {
    return ValidateBillAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateBodaBanjaAccount> validateBodaBanjaAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl + validateBBBEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateBodaBanjaAccount.fromjson(json);
  } else {
    return ValidateBodaBanjaAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateWenrecoAccount> validateWenrecoAccount(
    BuildContext context, Map data) async {
  const String url = baseUrl + validateWenrecoEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateWenrecoAccount.fromjson(json);
  } else {
    return ValidateWenrecoAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<ValidateAccount> validatePhoneNumber(
    BuildContext context, Map data) async {
  const String url = baseUrl + validatePhoneNumberEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ValidateAccount.fromjson(json);
  } else {
    return ValidateAccount(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<CountryDetails> getCountryDetails(BuildContext context, Map data) async {
  const String url = baseUrl + getCountryDetailsEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return CountryDetails.fromjson(json);
  } else {
    return CountryDetails(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<UserBalance> getUserBalances(BuildContext context, Map data) async {
  const String url = baseUrl2 + getWalletBalanceEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return UserBalance.fromjson(json);
  } else {
    return UserBalance(
        status: false, response: 'Something occured, Please try again');
  }
}

Future<ConvertAmount> convertAmount(BuildContext context, Map data) async {
  const String url = baseUrl + convertCurrencyEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return ConvertAmount.fromjson(json);
  } else {
    return ConvertAmount(
        status: false, response: 'Something occured, Please try again');
  }
}

Future<TransactionStatus> getTransactionStatus(Map data) async {
  const String url = baseUrl2 + getTransactionStatusEndPoint;
  final json = await customNetworkPostCall(
    data,
    url,
    showMessage: false,
  );
  if (json != null) {
    return TransactionStatus.fromjson(json);
  } else {
    return TransactionStatus(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<DisbursementCountries> getDisbursementCountries(
  BuildContext context,
) async {
  const String url = baseUrl + getDisbursmentCountriesEndPoint;
  final json = await customNetworkGetCall(
    context,
    url,
  );
  if (json != null) {
    return DisbursementCountries.fromjson(json);
  } else {
    return DisbursementCountries(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<GoogleUser> getGoogleUserDetails(
  BuildContext context,
  GoogleSignInAccount user,
) async {
  const String url = googlePeopleAPI + personFields;
  final json = await customGooglePeopleApi(
    context,
    user,
    url,
  );
  if (json != null) {
    return GoogleUser.fromjson(json);
  } else {
    return GoogleUser(
        status: false,
        responseMessage:
            'Something occured, Failed to get details from your google Account.');
  }
}

Future<OnboardingCountries> getOnboardingCountries(
  BuildContext context,
) async {
  const String url = baseUrl + getOnboardingCountriesEndPoint;
  final json = await customNetworkGetCall(
    context,
    url,
  );
  if (json != null) {
    return OnboardingCountries.fromjson(json);
  } else {
    return OnboardingCountries(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<AuthorizeTransaction> authorizeTransaction(
    BuildContext context, Map data) async {
  const String url = baseUrl + authorizeTransactionEndPoint;
  final json = await customNetworkPostCall(context: context, data, url);
  if (json != null) {
    return AuthorizeTransaction.fromjson(json);
  } else {
    return AuthorizeTransaction(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<AppInfo> appInfo(BuildContext context, Map data) async {
  const String url = baseUrl + getAppInfoEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return AppInfo.fromjson(json);
  } else {
    return AppInfo(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<MetaStatus> checkMetaStatus(BuildContext context, Map data) async {
  const String url = baseUrl + checkMetaStatusEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return MetaStatus.fromjson(json);
  } else {
    return MetaStatus(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<AMLList> getLimitDetails(BuildContext context, Map data) async {
  const String url = baseUrl + getAMLRecordsEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return AMLList.fromJson(json);
  } else {
    return const AMLList(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}

Future<Beneficiaries> getBeneficiaries(BuildContext context, Map data) async {
  const String url = baseUrl + beneficiariesEndPoint;
  final json = await customNetworkPostCall(
    context: context,
    data,
    url,
  );
  if (json != null) {
    return Beneficiaries.fromjson(json);
  } else {
    return Beneficiaries(
        status: false, responseMessage: 'Something occured, Please try again');
  }
}
