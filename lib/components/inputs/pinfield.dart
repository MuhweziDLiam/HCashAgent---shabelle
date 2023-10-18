import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:pivotpay/utils/resources.dart';

class PinInputField extends StatelessWidget {
  final int count;
  final ValueChanged<String>? onSubmit;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  TextEditingController? controller;
  PinInputField({
    super.key,
    this.count = 4,
    this.controller,
    this.validator,
    this.onSaved,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      key: key,
      length: count,
      obscureText: true,
      controller: controller,
      androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
      listenForMultipleSmsOnAndroid: true,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      onSubmitted: onSubmit,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      submittedPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(fontSize: 18),
        decoration: buildBoxDecoration(),
      ),
      followingPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(fontSize: 18),
        decoration: buildBoxDecoration(),
      ),
      focusedPinTheme: PinTheme(
        width: 50,
        height: 50,
        textStyle: const TextStyle(fontSize: 18),
        decoration: buildBoxDecoration().copyWith(
          border: Border.all(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: AppColors.lightGrey,
      ),
    );
  }
}
