import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../custom_control/custom_control.dart';
import '../custom_control/custom_widget.dart';

class CustomListViewWidget extends StatefulWidget {
  final CustomListViewControl _customListViewControl;
  final CustomListViewHeaderControl _customListViewHeaderControl = CustomListViewHeaderControl();

  CustomListViewWidget(this._customListViewControl, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CustomListViewWidgetState();
  }
}

class CustomListViewWidgetState extends State<CustomListViewWidget> {
  @override
  Widget build(BuildContext context) {
    widget._customListViewHeaderControl._dataSource = widget._customListViewControl._dataSource;
    widget._customListViewHeaderControl.scrollPosition = widget._customListViewControl.scrollPosition;
    widget._customListViewHeaderControl.xOffsetDisplay = true;
    widget._customListViewHeaderControl.canRequestFocus = false;
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: CustomWidget(
            widget._customListViewHeaderControl,
            scrollable: false,
          ),
        ),
        Expanded(
          child: CustomWidget(widget._customListViewControl),
        ),
      ],
    );
  }
}

class CustomListViewControl extends CustomControl {
  CustomListViewControl() : super() {
    defaultDataSource = CustomListViewDefaultDataSource();
    _dataSource = defaultDataSource;
    eventRowDoubleTap = null;
  }

  late CustomListViewDataSource _dataSource;
  late final CustomListViewDefaultDataSource defaultDataSource;
  bool showCurrentRowSelectionWhenInactive = true;

  late Function(CustomListViewRow row)? eventRowDoubleTap;

  double fontSize = 14;
  double cellContentPadding = 4;

  CustomListViewRow currentRow() {
    if (currentRowIndex >= 0 && currentRowIndex < _dataSource.rowCount()) {
      return _dataSource.row(currentRowIndex);
    }
    return CustomListViewRow([]);
  }

  double itemHeight() {
    return fontSize + cellContentPadding * 2;
  }

  @override
  void controlPaint(Canvas canvas, Size size, Rect visibleArea) {
    double colOffsetTemp = 0;
    List<double> columnsWidth = [];
    List<double> columnsOffsets = [];
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      var col = _dataSource.column(column);
      columnsWidth.add(col.width());
      columnsOffsets.add(colOffsetTemp);
      colOffsetTemp += col.width();
    }

    for (int row = 0; row < _dataSource.rowCount(); row++) {
      for (int column = 0; column < _dataSource.columnCount(); column++) {
        Rect cellRect = Rect.fromLTWH(columnsOffsets[column], row.toDouble() * itemHeight(), columnsWidth[column], itemHeight());
        if (visibleArea.intersect(cellRect).width > 0 || visibleArea.intersect(cellRect).height > 0) {
          canvas.save();
          canvas.clipRect(cellRect);
          String cellData = _dataSource.cellData(row, column);
          drawText(
              canvas,
              cellRect.left + cellContentPadding,
              cellRect.top + cellContentPadding,
              cellRect.width - cellContentPadding * 2,
              cellRect.height - cellContentPadding * 2,
              cellData,
              fontSize,
              Colors.green,
              TextAlign.left);
          canvas.restore();
        }
      }
      if (hasFocus || showCurrentRowSelectionWhenInactive) {
        if (row == currentRowIndex) {
          canvas.drawRect(
              Rect.fromLTWH(0, row.toDouble() * itemHeight(), size.width, itemHeight()),
              Paint()
                ..color = Colors.green.withOpacity(0.5)
                ..style = PaintingStyle.fill);
        }
      }
    }
  }

  @override
  void controlOnTap() {}

  @override
  void controlOnDoubleTap() {
    if (eventRowDoubleTap != null) {
      eventRowDoubleTap!(currentRow());
    }
  }

  @override
  void controlOnPointerDown(Offset offset) {
    int clickedItemIndex = findItemByPoint(offset);
    if (clickedItemIndex >= 0) {
      currentRowIndex = clickedItemIndex;
      ensureVisibleItem(currentRowIndex);
    }
  }

  @override
  KeyEventResult controlOnKey(RawKeyEvent ev) {
    if (ev is RawKeyDownEvent) {
      if (ev.logicalKey == LogicalKeyboardKey.arrowUp) {
        up();
      }
      if (ev.logicalKey == LogicalKeyboardKey.arrowDown) {
        down();
      }
      if (ev.logicalKey == LogicalKeyboardKey.home) {
        selectFirstElement();
      }
      if (ev.logicalKey == LogicalKeyboardKey.end) {
        selectLastElement();
      }

      if (ev.logicalKey == LogicalKeyboardKey.pageUp) {
        pageUp();
      }
      if (ev.logicalKey == LogicalKeyboardKey.pageDown) {
        pageDown();
      }
      //items.add(CustomListViewItem(ev.logicalKey.toString()));
    }
    return KeyEventResult.ignored;
  }

  @override
  Size size() {
    double width = 0;
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      width += _dataSource.column(column).width();
    }
    return Size(width, _dataSource.rowCount().toDouble() * itemHeight());
  }

  void ensureVisibleItem(int index) {
    ensureVisible(Offset(0, index * itemHeight()));
    ensureVisible(Offset(0, index * itemHeight() + itemHeight()));
  }

  int findItemByPoint(Offset offset) {
    var index = offset.dy ~/ itemHeight();
    return index;
  }

  int currentRowIndex = 0;
  void up() {
    currentRowIndex--;
    if (currentRowIndex < 0) {
      currentRowIndex = 0;
    }
    ensureVisibleItem(currentRowIndex);
  }

  void down() {
    currentRowIndex++;
    if (currentRowIndex >= _dataSource.rowCount()) {
      currentRowIndex = _dataSource.rowCount() - 1;
    }
    ensureVisibleItem(currentRowIndex);
  }

  void selectFirstElement() {
    currentRowIndex = 0;
    ensureVisibleItem(currentRowIndex);
  }

  void selectLastElement() {
    currentRowIndex = _dataSource.rowCount() - 1;
    if (currentRowIndex < 0) {
      currentRowIndex = 0;
    }
    ensureVisibleItem(currentRowIndex);
  }

  void pageUp() {
    int delta = (lastWidgetSize.height / itemHeight()).round();
    currentRowIndex -= delta;
    if (currentRowIndex < 0) {
      currentRowIndex = 0;
    }
    ensureVisibleItem(currentRowIndex);
  }

  void pageDown() {
    int delta = (lastWidgetSize.height / itemHeight()).round();
    currentRowIndex += delta;
    if (currentRowIndex >= _dataSource.rowCount()) {
      currentRowIndex = _dataSource.rowCount() - 1;
    }
    ensureVisibleItem(currentRowIndex);
  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    canvas.save();
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        overflow: TextOverflow.fade,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align, maxLines: 1, ellipsis: "...");
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    //textPainter.paint(canvas, Offset(x, y));
    canvas.restore();
  }
}

class CustomListViewColumn {
  String _title = "";
  double _width = 100;

  CustomListViewColumn(this._title, this._width);

  void setTitle(String title) {
    _title = title;
  }

  String title() {
    return _title;
  }

  void setWidth(double width) {
    _width = width;
  }

  double width() {
    return _width;
  }
}

class CustomListViewRow {
  CustomListViewRow(List<String> cells) {
    for (int i = 0; i < cells.length; i++) {
      _cells[i] = cells[i];
    }
  }

  final Map<int, String> _cells = {};

  String cellValue(int column) {
    if (_cells.containsKey(column)) {
      String? res = _cells[column];
      return res ?? "";
    }
    return "";
  }

  void setCellValue(int column, String value) {
    _cells[column] = value;
  }
}

abstract class CustomListViewDataSource {
  int columnCount();
  int rowCount();
  CustomListViewRow row(int rowIndex);
  String cellData(int row, int column);
  void cellDraw(Canvas cnv, Size size, int row, int column) {}
  CustomListViewColumn column(int column);
}

class CustomListViewDefaultDataSource extends CustomListViewDataSource {
  final List<CustomListViewColumn> _columns = [];
  final List<CustomListViewRow> _rows = [];

  @override
  String cellData(int row, int column) {
    if (row < 0 || row > _rows.length) {
      return "";
    }
    var item = _rows.elementAt(row);
    return item.cellValue(column);
  }

  @override
  int columnCount() {
    return _columns.length;
  }

  @override
  int rowCount() {
    return _rows.length;
  }

  void addRow(List<String> cells) {
    _rows.add(CustomListViewRow(cells));
  }

  @override
  CustomListViewRow row(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= _rows.length) {
      return CustomListViewRow([]);
    }
    return _rows[rowIndex];
  }

  void removeRow(int row) {
    if (row < 0 || row >= _rows.length) {
      return;
    }
    _rows.removeAt(row);
  }

  void removeAllRows() {
    _rows.clear();
  }

  void setCell(int row, int column, String value) {
    if (row < 0 || row >= _rows.length) {
      return;
    }
    _rows[row].setCellValue(column, value);
  }

  String cellValue(int row, int column) {
    if (row < 0 || row >= _rows.length) {
      return "";
    }
    return _rows[row].cellValue(column);
  }

  void addColumn(String title, double width) {
    _columns.add(CustomListViewColumn(title, width));
  }

  @override
  CustomListViewColumn column(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= _columns.length) {
      return CustomListViewColumn("", 0);
    }
    return _columns[columnIndex];
  }

  void removeColumn(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= _columns.length) {
      return;
    }
    _columns.removeAt(columnIndex);
  }
}

class CustomListViewHeaderControl extends CustomControl {
  CustomListViewHeaderControl() : super();

  late CustomListViewDataSource _dataSource;

  double itemHeight = 20;

  @override
  void controlPaint(Canvas canvas, Size size, Rect visibleArea) {
    double colOffsetTemp = 0;
    List<double> columnsWidth = [];
    List<double> columnsOffsets = [];
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      var col = _dataSource.column(column);
      columnsWidth.add(col.width());
      columnsOffsets.add(colOffsetTemp);
      colOffsetTemp += col.width();
    }

    for (int column = 0; column < _dataSource.columnCount(); column++) {
      Rect cellRect = Rect.fromLTWH(columnsOffsets[column], 0 * itemHeight, columnsWidth[column], itemHeight);
      canvas.save();
      canvas.clipRect(cellRect);

      String cellData = _dataSource.column(column).title();
      drawText(canvas, columnsOffsets[column], 0, size.width, itemHeight, cellData, 12, Colors.orange, TextAlign.left);
      canvas.restore();
    }
  }

  @override
  Size size() {
    double width = 0;
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      width += _dataSource.column(column).width();
    }
    return Size(width, 1 * itemHeight);
  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    canvas.save();
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    //textPainter.paint(canvas, Offset(x, y));
    canvas.restore();
  }
}
