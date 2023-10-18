import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pivotpay/components/others/text.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/style.dart';

class BaseTextField extends StatelessWidget {
  final String? labelText;
  final String? hintText, helperText;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final Widget? suffixIcon, prefixIcon;
  final String? initialValue;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool? optionField;
  final bool? readOnly, isOnboardingField;
  final Function? onTap;
  final FormFieldSetter<String>? onChanged;
  final InputDecoration? decoration;

  BaseTextField({
    this.labelText,
    this.hintText,
    this.helperText,
    this.inputFormatters,
    this.readOnly,
    this.onTap,
    this.decoration,
    this.focusNode,
    this.onSaved,
    this.validator,
    this.controller,
    this.initialValue,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
    this.isOnboardingField,
    this.obscureText = false,
    this.optionField,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: optionField!
          ? isOnboardingField!
              ? BorderRadius.circular(10)
              : BorderRadius.circular(10)
          : const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      borderSide: BorderSide(
        color: AppColors.lightGrey,
        width: 1.2,
      ),
    );

    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      readOnly: readOnly ?? false,
      onSaved: onSaved,
      validator: validator,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onTap: () => onTap!(),
      onChanged: onChanged,
      style: TextStyles.body1
          .copyWith(color: Colors.black, fontSize: FontSizes.s14),
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        errorStyle: TextStyles.caption.copyWith(color: AppColors.errorColor),
        labelStyle: TextStyles.caption.copyWith(color: AppColors.greyColor),
        hintStyle: TextStyles.body1
            .copyWith(color: AppColors.greyColor, fontFamily: 'WorkSans'),
        helperStyle: TextStyles.caption.copyWith(color: AppColors.primaryColor),
        isDense: true,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 5.0),
                child: prefixIcon,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(end: 5.0),
                child: suffixIcon,
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 0.8,
          ),
        ),
        errorBorder: border,
        focusedErrorBorder: border,
      ),
    );
  }
}

class TextInputField extends BaseTextField {
  TextInputField({
    @required FormFieldSetter<String>? onSaved,
    InputDecoration? decoration,
    String? labelText,
    String? hintText,
    String? helperText,
    FocusNode? focusNode,
    TextEditingController? controller,
    Function? onTap,
    List<TextInputFormatter>? inputFormatters,
    String Function(String?)? onChanged,
    required String? Function(String?)? validator,
    String? initialValue,
    bool? isOnboardingField,
    bool? optionField,
    bool? readOnly,
    bool? obsecureText,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType? keyboardType,
  }) : super(
          decoration: decoration,
          labelText: labelText,
          hintText: hintText,
          inputFormatters: [],
          optionField: optionField ?? true,
          controller: controller,
          helperText: helperText,
          focusNode: focusNode,
          onSaved: onSaved,
          onTap: onTap ?? () {},
          readOnly: readOnly,
          obscureText: obsecureText ?? false,
          onChanged: onChanged,
          isOnboardingField: isOnboardingField ?? false,
          initialValue: initialValue,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          validator: validator,
          keyboardType: keyboardType ?? TextInputType.text,
        );
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SmallText(
              labelText!,
              color: AppColors.primaryColor,
            ),
          ),
        super.build(context)
      ],
    );
  }
}

class DropDownItem {
  final String? title;
  final String? value;
  final String? imgUrl;
  final String? amount;
  const DropDownItem({this.title, this.value, this.imgUrl, this.amount});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DropDownItem &&
        o.title == title &&
        o.value == value &&
        o.amount == amount &&
        o.imgUrl == imgUrl;
  }

  @override
  int get hashCode =>
      title.hashCode ^ value.hashCode ^ imgUrl.hashCode ^ amount.hashCode;
}

class DropDownTextInputField extends StatefulWidget {
  final String? labelText;
  final String? hintText, helperText;
  final FormFieldSetter<DropDownItem>? onSaved;
  final Function? onTap;
  final Function(DropDownItem value)? onChanged;
  final FormFieldValidator<DropDownItem>? validator;
  final Widget? suffixIcon, prefixIcon;
  final bool isOnboardingField;
  final List<DropDownItem>? items;

  DropDownTextInputField({
    this.labelText,
    this.hintText,
    this.helperText,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.items,
    this.isOnboardingField = false,
  }) : super();

  @override
  _DropDownTextInputFieldState createState() => _DropDownTextInputFieldState();
}

class _DropDownTextInputFieldState extends State<DropDownTextInputField> {
  DropDownItem? item;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: widget.isOnboardingField
          ? BorderRadius.circular(14)
          : BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.lightGrey,
        width: 1.2,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmallText(widget.labelText!),
          ),
        DropdownButtonFormField<DropDownItem>(
          items: widget.items!.map((e) {
            return DropdownMenuItem<DropDownItem>(
              value: e,
              child: Row(
                children: <Widget>[
                  Image.asset(
                    e.imgUrl!,
                    height: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SmallText(e.title!)
                ],
              ),
            );
          }).toList(),
          itemHeight: 50,
          value: item ?? widget.items!.first,
          onChanged: (value) {
            item = value!;
            widget.onChanged!(value);
          },
          icon: ImageIcon(
            AssetImage(AppIcons.caretDown),
            color: AppColors.primaryColor,
            size: 10,
          ),
          onSaved: widget.onSaved,
          onTap: () => OnTap,
          validator: widget.validator,
          style: TextStyles.body1
              .copyWith(color: Colors.black, fontSize: FontSizes.s16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorStyle:
                TextStyles.caption.copyWith(color: AppColors.errorColor),
            labelStyle: TextStyles.caption.copyWith(color: AppColors.greyColor),
            hintStyle: TextStyles.body1.copyWith(color: AppColors.greyColor),
            helperStyle:
                TextStyles.caption.copyWith(color: AppColors.primaryColor),
            isDense: true,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 0.8,
              ),
            ),
            errorBorder: border,
            focusedErrorBorder: border,
          ),
        ),
      ],
    );
  }
}

class DropDownItemSub {
  final String? title;
  final String? value;
  final String? imgUrl;
  final String? amount;
  const DropDownItemSub({this.title, this.value, this.imgUrl, this.amount});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DropDownItemSub &&
        o.title == title &&
        o.value == value &&
        o.imgUrl == imgUrl &&
        o.amount == amount;
  }

  @override
  int get hashCode =>
      title.hashCode ^ value.hashCode ^ imgUrl.hashCode ^ amount.hashCode;
}

class DropDownTextInputFieldSub extends StatefulWidget {
  final String? labelText;
  final String? hintText, helperText;
  final FormFieldSetter<DropDownItemSub>? onSaved;
  final Function? onTap;
  final FormFieldValidator<DropDownItemSub>? validator;
  final Widget? suffixIcon, prefixIcon;
  final bool isOnboardingField;
  final List<DropDownItemSub>? items;

  DropDownTextInputFieldSub({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.onSaved,
    this.onTap,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.items,
    this.isOnboardingField = false,
  }) : super();

  @override
  _DropDownTextInputFieldStateSub createState() =>
      _DropDownTextInputFieldStateSub();
}

class _DropDownTextInputFieldStateSub extends State<DropDownTextInputFieldSub> {
  DropDownItemSub? item;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: widget.isOnboardingField
          ? BorderRadius.circular(25)
          : BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.lightGrey,
        width: 1.2,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmallText(widget.labelText!),
          ),
        DropdownButtonFormField<DropDownItemSub>(
          items: widget.items!.map((e) {
            return DropdownMenuItem<DropDownItemSub>(
              value: e,
              child: Row(
                children: <Widget>[
                  Image.asset(
                    e.imgUrl!,
                    width: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SmallText(e.title!)
                ],
              ),
            );
          }).toList(),
          itemHeight: 70,
          value: item,
          onChanged: (value) => setState(() {
            item = value;
          }),
          icon: ImageIcon(
            AssetImage(AppIcons.caretDown),
            color: AppColors.primaryColor,
          ),
          onSaved: widget.onSaved,
          validator: widget.validator,
          style: TextStyles.body1
              .copyWith(color: Colors.black, fontSize: FontSizes.s16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorStyle:
                TextStyles.caption.copyWith(color: AppColors.errorColor),
            labelStyle: TextStyles.caption.copyWith(color: AppColors.greyColor),
            hintStyle: TextStyles.body1.copyWith(color: AppColors.greyColor),
            helperStyle:
                TextStyles.caption.copyWith(color: AppColors.primaryColor),
            isDense: true,
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 0.8,
              ),
            ),
            errorBorder: border,
            focusedErrorBorder: border,
          ),
        ),
      ],
    );
  }
}
