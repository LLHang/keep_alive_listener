import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class KeepAliveListener extends SingleChildRenderObjectWidget {
  final Function(bool isKeptAlive) keepAliveListener;

  const KeepAliveListener(
      {Key? key, required this.keepAliveListener, Widget? child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderKeepAliveListener()..keepAliveListener = keepAliveListener;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderKeepAliveListener renderObject) {
    renderObject.keepAliveListener = keepAliveListener;
    super.updateRenderObject(context, renderObject);
  }
}

class RenderKeepAliveListener extends RenderProxyBox {
  Function(bool isKeptAlive)? keepAliveListener;

  RenderObject? findParentDataObject() {
    RenderObject? parent = this.parent as RenderObject?;
    while (parent != null) {
      if (parent.parentData is KeepAliveParentDataMixin) {
        return parent;
      }
      parent = parent.parent as RenderObject?;
    }
    return null;
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _checkKeepAlive();
  }

  void _checkKeepAlive() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final data = findParentDataObject()?.parentData;
      if (data is KeepAliveParentDataMixin) {
        keepAliveListener?.call(data.keptAlive);
      }
    });
  }
}

class DefaultKeepAliveNotifier extends StatefulWidget {
  final Widget child;

  static bool isKeptAlive(BuildContext context) {
    return mayBeOf(context)?.value ?? false;
  }

  static ValueNotifier<bool>? mayBeOf(BuildContext context) {
    final notifier =
    context.dependOnInheritedWidgetOfExactType<_DefaultKeepAliveNotifierScope>();
    return notifier?.notifier;
  }

  static ValueNotifier<bool> of(BuildContext context) {
    final notifier =
    context.dependOnInheritedWidgetOfExactType<_DefaultKeepAliveNotifierScope>();
    assert(notifier != null, '未找到上层 KeptAliveNotifier');
    return notifier?.notifier ?? ValueNotifier(false);
  }

  const DefaultKeepAliveNotifier({required this.child, super.key});

  @override
  State<DefaultKeepAliveNotifier> createState() => _DefaultKeepAliveNotifierState();
}

class _DefaultKeepAliveNotifierState extends State<DefaultKeepAliveNotifier> {
  late ValueNotifier<bool> _keepAliveNotifier;

  @override
  void initState() {
    super.initState();
    _keepAliveNotifier = ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveListener(
        keepAliveListener: (isKeptAlive) =>
        _keepAliveNotifier.value = isKeptAlive,
        child: _DefaultKeepAliveNotifierScope(
          notifier: _keepAliveNotifier,
          child: widget.child,
        ));
  }

  @override
  void dispose() {
    _keepAliveNotifier.dispose();
    super.dispose();
  }
}

class _DefaultKeepAliveNotifierScope extends InheritedWidget {
  final ValueNotifier<bool> notifier;

  const _DefaultKeepAliveNotifierScope({required this.notifier, required super.child});

  @override
  bool updateShouldNotify(covariant _DefaultKeepAliveNotifierScope oldWidget) {
    return oldWidget.notifier != notifier;
  }
}

