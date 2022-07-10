import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

abstract class CustomControl {
  CustomControl() {
    eventOnKey = null;
  }

  // Virtual Interface
  void controlPaint(Canvas canvas, Size size, Rect visibleArea);
  Size size();

  void controlOnTap() {}
  void controlOnDoubleTap() {}
  void controlOnPointerDown(Offset offset) {}
  void controlOnPointerMove(Offset offset) {}
  void controlOnPointerUp(Offset offset) {}

  KeyEventResult controlOnKey(RawKeyEvent ev) {
    return KeyEventResult.ignored;
  }

  DateTime lastMouseDownTime = DateTime.now();
  Offset lastMouseDownPos = const Offset(0, 0);

  Color _scrollColor = Colors.grey.withOpacity(0.5);

  // Private section
  bool _scrollDragX = false;
  bool _scrollDragY = false;
  double _scrollDragBeginOffset = 0;

  bool scrollable = false;
  bool xOffsetDisplay = false;
  bool yOffsetDisplay = false;

  bool hasFocus = false;
  bool autoFocus = false;
  bool canRequestFocus = true;

  void setScrollColor(Color scrollColor) {
    _scrollColor = scrollColor;
  }

  // Handlers
  @nonVirtual
  void onScroll(PointerScrollEvent ev) {
    scrollPosition.yOffset = scrollPosition.yOffset + ev.scrollDelta.dy;
    checkMinMaxScrollOffset();
  }

  @nonVirtual
  void onTap() {
    controlOnTap();
  }

  @nonVirtual
  void onDoubleTap() {
    //controlOnDoubleTap();
  }

  late KeyEventResult Function(RawKeyEvent ev)? eventOnKey;

  @nonVirtual
  void onPointerDown(PointerDownEvent ev) {
    var now = DateTime.now();
    if (now.difference(lastMouseDownTime).inMilliseconds < 300 && (lastMouseDownPos.dx - ev.localPosition.dx).abs() < 10 && (lastMouseDownPos.dy - ev.localPosition.dy).abs() < 10) {
      controlOnDoubleTap();
      lastMouseDownTime = DateTime(now.year);
      lastMouseDownPos = const Offset(0, 0);
      return;
    }

    lastMouseDownTime = now;
    lastMouseDownPos = ev.localPosition;

    bool processed = false;
    if (_verticalScrollVisible && getVerticalScrollRect().contains(ev.localPosition)) {
      processed = true;
      _scrollDragY = true;
      _scrollDragBeginOffset = ev.localPosition.dy - getVerticalScrollRect().top;
    }

    if (_horizontalScrollVisible && getHorizontalScrollRect().contains(ev.localPosition)) {
      processed = true;
      _scrollDragX = true;
      _scrollDragBeginOffset = ev.localPosition.dx - getHorizontalScrollRect().left;
    }

    if (!processed) {
      if (scrollable) {
        controlOnPointerDown(ev.localPosition.translate(scrollPosition.xOffset, scrollPosition.yOffset));
      } else {
        controlOnPointerDown(ev.localPosition);
      }
    }
  }

  @nonVirtual
  void onPointerMove(PointerMoveEvent ev) {
    bool processed = false;
    if (_scrollDragY && scrollable) {
      processed = true;
      double displayK = lastWidgetSize.height / size().height;
      scrollPosition.yOffset = (ev.localPosition.dy - _scrollDragBeginOffset) / displayK;
      checkMinMaxScrollOffset();
    }

    if (_scrollDragX && scrollable) {
      processed = true;
      double displayK = lastWidgetSize.width / size().width;
      scrollPosition.xOffset = (ev.localPosition.dx - _scrollDragBeginOffset) / displayK;
      checkMinMaxScrollOffset();
    }

    if (!processed) {
      if (scrollable) {
        controlOnPointerMove(ev.localPosition.translate(scrollPosition.xOffset, scrollPosition.yOffset));
      } else {
        controlOnPointerMove(ev.localPosition);
      }
    }
  }

  @nonVirtual
  void onPointerUp(PointerUpEvent ev) {
    bool processed = false;

    if (_scrollDragY) {
      processed = true;
      _scrollDragY = false;
    }

    if (_scrollDragX) {
      processed = true;
      _scrollDragX = false;
    }

    if (!processed) {
      if (scrollable) {
        controlOnPointerUp(ev.localPosition.translate(scrollPosition.xOffset, scrollPosition.yOffset));
      } else {
        controlOnPointerUp(ev.localPosition);
      }
    }
  }

  KeyEventResult onKey(RawKeyEvent ev) {
    var res = controlOnKey(ev);
    if (res == KeyEventResult.ignored) {
      if (eventOnKey != null) {
        res = eventOnKey!(ev);
      }
    }
    return res;
  }

  void ensureVisible(Offset offset) {
    if (!scrollable) {
      return;
    }
    if (scrollPosition.yOffset > offset.dy) {
      scrollPosition.yOffset = offset.dy;
    }

    if (scrollPosition.yOffset < offset.dy - lastWidgetSize.height) {
      scrollPosition.yOffset = offset.dy - lastWidgetSize.height;
    }
  }

  void checkMinMaxScrollOffset() {
    if (!scrollable) {
      return;
    }
    if (scrollPosition.yOffset > maxYOffset()) {
      scrollPosition.yOffset = maxYOffset();
    }
    if (scrollPosition.yOffset < 0) {
      scrollPosition.yOffset = 0;
    }

    if (scrollPosition.xOffset > maxXOffset()) {
      scrollPosition.xOffset = maxXOffset();
    }
    if (scrollPosition.xOffset < 0) {
      scrollPosition.xOffset = 0;
    }
  }

  double maxXOffset() {
    Size contentSize = size();
    return contentSize.width - lastWidgetSize.width;
  }

  double maxYOffset() {
    Size contentSize = size();
    return contentSize.height - lastWidgetSize.height;
  }

  double scrollWidth = 20;

  Rect getVerticalScrollRect() {
    if (!scrollable) {
      return const Rect.fromLTWH(0, 0, 0, 0);
    }
    double displayK = lastWidgetSize.height / size().height;
    return Rect.fromLTWH(lastWidgetSize.width - scrollWidth, scrollPosition.yOffset * displayK, scrollWidth, lastWidgetSize.height * displayK);
  }

  Rect getHorizontalScrollRect() {
    if (!scrollable) {
      return const Rect.fromLTWH(0, 0, 0, 0);
    }
    double displayK = lastWidgetSize.width / size().width;
    return Rect.fromLTWH(scrollPosition.xOffset * displayK, lastWidgetSize.height - scrollWidth, lastWidgetSize.width * displayK, scrollWidth);
  }

  bool _horizontalScrollVisible = false;
  bool _verticalScrollVisible = false;
  void drawScrollBar(Canvas canvas, Size widgetSize) {
    if (!scrollable) {
      return;
    }

    Size contentSize = size();

    // Vertical scroll
    if (contentSize.height > lastWidgetSize.height) {
      _verticalScrollVisible = true;
      var scrollBarRect = getVerticalScrollRect();
      canvas.drawRect(
          scrollBarRect,
          Paint()
            ..color = _scrollColor
            ..style = PaintingStyle.fill);
    } else {
      _verticalScrollVisible = false;
    }

    // Horizontal scroll
    if (contentSize.width > lastWidgetSize.width) {
      _horizontalScrollVisible = true;
      var scrollBarRect = getHorizontalScrollRect();
      canvas.drawRect(
          scrollBarRect,
          Paint()
            ..color = _scrollColor
            ..style = PaintingStyle.fill);
    } else {
      _horizontalScrollVisible = false;
    }
  }

  void onPaint(Canvas canvas, Size widgetSize) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height));

    lastWidgetSize = widgetSize;
    checkMinMaxScrollOffset();

    Rect visibleArea = Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height);
    canvas.save();
    if (scrollable) {
      canvas.translate(-scrollPosition.xOffset, -scrollPosition.yOffset);
      visibleArea = Rect.fromLTWH(scrollPosition.xOffset, scrollPosition.yOffset, widgetSize.width, widgetSize.height);
    } else {
      if (xOffsetDisplay) {
        canvas.translate(-scrollPosition.xOffset, 0);
        visibleArea = Rect.fromLTWH(scrollPosition.xOffset, 0, widgetSize.width, widgetSize.height);
      }
      if (yOffsetDisplay) {
        canvas.translate(0, -scrollPosition.yOffset);
        visibleArea = Rect.fromLTWH(0, scrollPosition.yOffset, widgetSize.width, widgetSize.height);
      }
    }
    controlPaint(canvas, widgetSize, visibleArea);
    canvas.restore();

    paintAfter(canvas, widgetSize);
    canvas.restore();
  }

  ScrollPosition scrollPosition = ScrollPosition();

  Size lastWidgetSize = const Size(0, 0);

  double activeBorderWidth = 1;
  Color activeBorderColor = Colors.blueAccent;
  double inactiveBorderWidth = 1;
  Color inactiveBorderColor = Colors.white30;

  void paintAfter(Canvas canvas, Size widgetSize) {
    drawScrollBar(canvas, widgetSize);

    Color borderColor = inactiveBorderColor;
    double borderWidth = inactiveBorderWidth;

    if (hasFocus) {
      borderColor = activeBorderColor;
      borderWidth = activeBorderWidth;
    }

    canvas.drawRect(
        Rect.fromLTWH(0, 0, widgetSize.width, widgetSize.height),
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth);
  }
}

class ScrollPosition {
  double xOffset = 0;
  double yOffset = 0;
}
