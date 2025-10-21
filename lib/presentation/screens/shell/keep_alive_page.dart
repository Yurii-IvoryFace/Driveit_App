import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  final String keyValue;

  const KeepAlivePage({super.key, required this.child, required this.keyValue});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Logger.log('KeepAlivePage initState: ${widget.keyValue}', tag: 'KeepAlive');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    Logger.log('KeepAlivePage build: ${widget.keyValue}', tag: 'KeepAlive');
    return widget.child;
  }

  @override
  void dispose() {
    Logger.log('KeepAlivePage dispose: ${widget.keyValue}', tag: 'KeepAlive');
    super.dispose();
  }
}
