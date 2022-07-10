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

  double fontSize = 16;
  double cellContentPadding = 4;
  bool allowDeselectAllRows = false;

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
    List<TextAlign> columnsAligns = [];
    List<double> columnsOffsets = [];
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      var col = _dataSource.column(column);
      columnsWidth.add(col.width());
      columnsOffsets.add(colOffsetTemp);
      columnsAligns.add(col.textAlign());
      colOffsetTemp += col.width();
    }

    for (int row = 0; row < _dataSource.rowCount(); row++) {
      canvas.drawLine(Offset(0, row * itemHeight()), Offset(size.width, row * itemHeight()), Paint()
          ..color = Colors.green
          ..strokeWidth = 0.1
      );
      for (int column = 0; column < _dataSource.columnCount(); column++) {
        Rect cellRect = Rect.fromLTWH(columnsOffsets[column], row.toDouble() * itemHeight(), columnsWidth[column], itemHeight());
        if (visibleArea.intersect(cellRect).width > 0 || visibleArea.intersect(cellRect).height > 0) {
          canvas.save();
          canvas.clipRect(cellRect);
          String cellData = _dataSource.cellData(row, column);
          Color cellColor = _dataSource.cellColor(row, column);
          double cellFontSize = _dataSource.cellFontSize(row, column);
          drawText(canvas, cellRect.left + cellContentPadding, cellRect.top + cellContentPadding, cellRect.width - cellContentPadding * 2, cellRect.height - cellContentPadding * 2, cellData, cellFontSize,
              cellColor, columnsAligns[column]);
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

    for (int column = 0; column < _dataSource.columnCount(); column++) {
      canvas.drawLine(Offset(columnsOffsets[column], 0), Offset(columnsOffsets[column], itemHeight() * _dataSource.rowCount()), Paint()
        ..color = Colors.green
        ..strokeWidth = 0.1
      );
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
    if (index >= 0 && index < _dataSource.rowCount()) {
      return index;
    }
    return -1;
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
    Size s = measureText(canvas, x, y, width, height, text, size, color, align);

    if (s.width >= width - 5) {
      Size s1 = measureText(canvas, x, y, width, height, "W", size, color, align);
      int needLen = (width ~/ s1.width) - 3;
      text = "${text.substring(0, needLen)}...";
    }

    s = measureText(canvas, x, y, width, height, text, size, color, align);

    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontFamily: "RobotoMono",
        fontSize: size,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    );
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );

    textPainter.paint(canvas, Offset(x, y + (height / 2) - (s.height / 2)));
  }
}

Size measureText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
  var textSpan = TextSpan(
    text: text,
    style: TextStyle(
      color: color,
      fontFamily: "RobotoMono",
      fontSize: size,
    ),
  );
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
    textAlign: align,
    maxLines: 1,
    //ellipsis: "."
  );
  textPainter.layout(
    minWidth: width,
    maxWidth: width,
  );

  return Size(textPainter.maxIntrinsicWidth, textPainter.height);
}

class CustomListViewColumn {
  String _title = "";
  double _width = 100;
  TextAlign _textAlign = TextAlign.start;

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

  TextAlign textAlign() {
    return _textAlign;
  }

  void setAlign(TextAlign textAlign) {
    _textAlign = textAlign;
  }
}

class CustomListViewRow {
  CustomListViewRow(List<String> cells) {
    for (int i = 0; i < cells.length; i++) {
      _cells[i] = cells[i];
    }
  }

  final Map<int, String> _cells = {};
  final Map<int, Color?> _cellsColors = {};
  final Map<int, double?> _cellsFontSizes = {};

  String cellValue(int column) {
    if (_cells.containsKey(column)) {
      String? res = _cells[column];
      return res ?? "";
    }
    return "";
  }

  Color cellColor(int column) {
    Color res = _color;
    if (_cellsColors.containsKey(column)) {
      res = _cellsColors[column] ?? _color;
    }
    return res;
  }

  double cellFontSize(int column) {
    double res = _fontSize;
    if (_cellsFontSizes.containsKey(column)) {
      res = _cellsFontSizes[column] ?? _fontSize;
    }
    return res;
  }

  void setCellValue(int column, String value) {
    _cells[column] = value;
  }

  void setCellColor(int column, Color? color) {
    _cellsColors[column] = color;
  }

  void setCellFontSize(int column, double fontSize) {
    _cellsFontSizes[column] = fontSize;
  }

  Color _color = Colors.grey;
  double _fontSize = 16;

  void setColor(Color color) {
    _color = color;
  }

  Color color() {
    return _color;
  }

  void setFontSize(double fontSize) {
    _fontSize = fontSize;
  }

  double fontSize() {
    return _fontSize;
  }
}

abstract class CustomListViewDataSource {
  int columnCount();
  int rowCount();
  CustomListViewRow row(int rowIndex);
  String cellData(int row, int column);
  Color cellColor(int row, int column) { return Colors.grey; }
  double cellFontSize(int row, int column) { return 14; }
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

  CustomListViewRow addRow(List<String> cells) {
    CustomListViewRow row = CustomListViewRow(cells);
    _rows.add(row);
    return row;
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

  @override
  Color cellColor(int row, int column) {
    Color col = Colors.grey;

    if (row < 0 || row >= _rows.length) {
      return col;
    }

    return _rows[row].cellColor(column);
  }

  @override
  double cellFontSize(int row, int column) {
    double col = 14;

    if (row < 0 || row >= _rows.length) {
      return col;
    }

    return _rows[row].cellFontSize(column);
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

  double cellContentPadding = 4;
  double itemHeight = 20;

  @override
  void controlPaint(Canvas canvas, Size size, Rect visibleArea) {
    double colOffsetTemp = 0;
    List<double> columnsWidth = [];
    List<double> columnsOffsets = [];
    List<TextAlign> columnsAligns = [];
    for (int column = 0; column < _dataSource.columnCount(); column++) {
      var col = _dataSource.column(column);
      columnsWidth.add(col.width());
      columnsOffsets.add(colOffsetTemp);
      columnsAligns.add(col.textAlign());
      colOffsetTemp += col.width();
    }

    for (int column = 0; column < _dataSource.columnCount(); column++) {
      Rect cellRect = Rect.fromLTWH(columnsOffsets[column], 0 * itemHeight, columnsWidth[column], itemHeight);
      canvas.save();
      canvas.clipRect(cellRect);

      String cellData = _dataSource.column(column).title();
      drawText(canvas, columnsOffsets[column] + cellContentPadding, cellContentPadding, columnsWidth[column] - cellContentPadding * 2, itemHeight - cellContentPadding * 2, cellData, 14, Colors.orange, columnsAligns[column]);
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
    Size s = measureText(canvas, x, y, width, height, text, size, color, align);

    if (s.width >= width - 5) {
      Size s1 = measureText(canvas, x, y, width, height, "W", size, color, align);
      int needLen = (width ~/ s1.width) - 3;
      int needLen1 = needLen ~/ 2;
      int needLen2 = needLen ~/ 2;

      String text1 = text.substring(0, needLen1);
      String text2 = text.substring(text.length - needLen2);
      text = "$text1...$text2";
    }

    s = measureText(canvas, x, y, width, height, text, size, color, align);

    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontFamily: "RobotoMono",
        fontSize: size,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    );
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );

    textPainter.paint(canvas, Offset(x, y + (height / 2) - (s.height / 2)));
  }

  Size measureText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontFamily: "RobotoMono",
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
      //ellipsis: "."
    );
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );

    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }
}
