import 'package:flutter/material.dart';
import 'package:pivotpay/components/dialogs/dialog.dart';
import 'package:pivotpay/utils/resources.dart';
import 'package:pivotpay/utils/style.dart';

const _sizeK = 50.0;

// ignore: must_be_immutable
class StylishDialogUI extends StatefulWidget {
  StylishDialogUI({
    Key? key,
    this.context,
    this.alertType,
    this.animationLoop,
    this.titleText,
    this.contentText,
    this.confirmText,
    this.cancelText,
    this.confirmPressEvent,
    this.cancelPressEvent,
    this.addView,
    this.confirmButton,
    this.cancelButton,
    this.color,
    this.titleStyle,
    this.contentStyle,
  }) : super(key: key);

  final BuildContext? context;
  final StylishDialogType? alertType;
  final bool? animationLoop;
  String? titleText;
  String? contentText;
  String? confirmText;
  String? cancelText;
  VoidCallback? confirmPressEvent;
  VoidCallback? cancelPressEvent;
  Widget? addView;

  //
  Widget? confirmButton;
  Widget? cancelButton;
  Color? color;
  TextStyle? titleStyle;
  TextStyle? contentStyle;

  @override
  _StylishDialogState createState() => _StylishDialogState();
}

class _StylishDialogState extends State<StylishDialogUI>
    with TickerProviderStateMixin {
  final _key = GlobalKey<NavigatorState>();

  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(covariant StylishDialogUI oldWidget) {
    super.didUpdateWidget(oldWidget);

    ///dispose current active controller and
    /// create new one for changeAlertType
    _controller!.dispose();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    //Default values of Confirm Button Text
    widget.confirmText = 'Confirm';
    //Default values of Cancel Button Text
    widget.cancelText = 'Cancel';

    return Dialog(
      key: (widget.key ?? _key),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: _stylishContentBox(),
    );
  }

  Widget _stylishContentBox() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stylishDialogChange(),
        if (widget.titleText != null) _titleTextWidget(widget.titleText),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Insets.lg),
          child: const Divider(
            color: Color.fromRGBO(3, 76, 129, 1),
          ),
        ),
        if (widget.contentText != null) _contentTextWidget(widget.contentText),
        if (widget.alertType == StylishDialogType.NORMAL &&
            widget.addView != null)
          Container(
            padding: const EdgeInsets.only(left: 10, top: 8, bottom: 4, right: 10),
            child: widget.addView,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ///Cancel
            if (widget.cancelButton != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: widget.cancelButton,
              )
            else if (widget.cancelPressEvent != null)
              _pressButtonWidget(
                  widget.cancelPressEvent, Colors.red, widget.cancelText,),

            ///Confirm
            if (widget.confirmButton != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: widget.confirmButton,
              )
            else if (widget.confirmPressEvent != null)
              _pressButtonWidget(
                  widget.confirmPressEvent, AppColors.primaryColor, widget.confirmText,),
          ],
        ),
      ],
    );
  }

  //Text widget for title text
  Widget _titleTextWidget(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0, left: 8, right: 8, bottom: 8),
      child: Text(
        '$text',
        textAlign: TextAlign.center,
        style: widget.titleStyle ?? TextStyle(color: AppColors.primaryColor),
      ),
    );
  }

  //Text widget for content text
  Widget _contentTextWidget(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, left: 20, right: 20, bottom: 10),
      child: Text(
        '$text',
        textAlign: TextAlign.center,
        style: widget.contentStyle ?? TextStyle(color: AppColors.primaryColor),
      ),
    );
  }

  //Button widget for confirm and cancel buttons
  Widget _pressButtonWidget(pressEvent, Color color, text) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextButton(
          onPressed: () async {
            pressEvent();
          },
          // ignore: sort_child_properties_last
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 4.0, top: 4, bottom: 4),
            child: Text(
              '$text',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
          ),
        ),
      ),
    );
  }

  _playAnimation() {
    if (widget.animationLoop!) {
      _controller!.repeat();
    } else {
      _controller!.forward();
    }
  }

  Widget _stylishDialogChange() {
    switch (widget.alertType) {
      case StylishDialogType.NORMAL:
        return Container(
          width: 0,
        );
      case StylishDialogType.PROGRESS:
        return Padding(
          padding:
              const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
          child: CircularProgressIndicator(
            color: widget.color,
          ),
        );
      case StylishDialogType.SUCCESS:
        _playAnimation();
        return Padding(
          padding:
              const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
          child: Container(
            alignment: Alignment.center,
            width: _sizeK,
            height: _sizeK,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              color: Colors.white,
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4.0),
            child: SizeTransition(
                sizeFactor: _animation!,
                axis: Axis.horizontal,
                axisAlignment: -1,
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 40,
                ),),
          ),
        );
      case StylishDialogType.INFO:
        _playAnimation();
        return Padding(
          padding:
              const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
          child: ScaleTransition(
              scale: _animation!,
              child: const Icon(
                Icons.info_outlined,
                color: Colors.blue,
                size: 44,
              ),),
        );
      case StylishDialogType.WARNING:
        _playAnimation();
        return Padding(
          padding:
              const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
          child: ScaleTransition(
              scale: _animation!,
              child: const Icon(
                Icons.info_outlined,
                color: Colors.amber,
                size: 44,
              ),),
        );
      case StylishDialogType.ERROR:
        _playAnimation();
        return Padding(
          padding:
              const EdgeInsets.only(top: 12.0, left: 8, right: 8, bottom: 8),
          child: Container(
            alignment: Alignment.center,
            width: _sizeK,
            height: _sizeK,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              color: Colors.white,
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(4.0),
            child: ScaleTransition(
                scale: _animation!,
                child: const Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 40,
                ),),
          ),
        );

      default:
        return Container(
          width: 0,
        );
    }
  }
}
