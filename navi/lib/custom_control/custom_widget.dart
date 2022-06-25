import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'custom_control.dart';

class CustomWidget extends StatefulWidget {
  final CustomControl customControl;
  final bool scrollable;
  //final bool focusable;
  const CustomWidget(
    this.customControl, {
    Key? key,
    this.scrollable = true,
    //this.focusable = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomWidgetState();
  }
}

class CustomWidgetState extends State<CustomWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.customControl.scrollable = widget.scrollable;
    return Focus(
      canRequestFocus: widget.customControl.canRequestFocus,
      focusNode: _focusNode,
      autofocus: widget.customControl.autoFocus,
      onFocusChange: (value) {
        widget.customControl.hasFocus = value;
        setState(() {});
      },
      //focusNode: _focusNode,
      onKey: (node, event) {
        var res = widget.customControl.onKey(event);
        setState(() {});
        return res;
      },
      child: GestureDetector(
        onTap: () {
          widget.customControl.onTap();
        },
        onDoubleTap: () {
          widget.customControl.onDoubleTap();
        },
        child: Listener(
          onPointerDown: (PointerDownEvent ev) {
            _focusNode.requestFocus();
            widget.customControl.onPointerDown(ev);
            setState(() {});
          },
          onPointerMove: (PointerMoveEvent ev) {
            widget.customControl.onPointerMove(ev);
            setState(() {});
          },
          onPointerUp: (PointerUpEvent ev) {
            widget.customControl.onPointerUp(ev);
            setState(() {});
          },
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              widget.customControl.onScroll(event);
              setState(() {});
            }
          },
          child: CustomPaint(
            painter: CustomWidgetPainter(widget.customControl),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class CustomWidgetPainter extends CustomPainter {
  CustomControl control;

  CustomWidgetPainter(this.control);
  @override
  void paint(Canvas canvas, Size size) {
    control.onPaint(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
