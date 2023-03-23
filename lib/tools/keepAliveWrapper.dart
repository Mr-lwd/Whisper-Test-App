import 'package:flutter/material.dart';

class keepAliveWrapper extends StatefulWidget {
  final Widget? child;
  final bool keepAlive;

  const keepAliveWrapper(
      {super.key, @required this.child, this.keepAlive = true});

  @override
  State<keepAliveWrapper> createState() => _keepAliveWrapperState();
}

class _keepAliveWrapperState extends State<keepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant keepAliveWrapper oldWidget) {
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }
}
