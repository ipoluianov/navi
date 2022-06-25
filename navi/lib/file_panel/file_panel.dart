import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi/main.dart';

import '../custom_listview/custom_listview.dart';
import 'package:path/path.dart' as p;

import '../executer/executer.dart';

class FilePanel extends StatefulWidget {
  final bool autoFocus;
  final Function(int n) onShowSelector;
  final FilePanelContext filePanelContext;
  const FilePanel(this.autoFocus, this.onShowSelector, this.filePanelContext, {Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FilePanelState();
  }
}

class FilePanelContext {
  bool buildSelectorVisible = false;
}

class FilePanelState extends State<FilePanel> {
  final CustomListViewControl _customListViewControl = CustomListViewControl();

  String currentPath = "d:\\";

  @override
  void initState() {
    super.initState();

    _customListViewControl.defaultDataSource.addColumn("Name", 400);
    _customListViewControl.defaultDataSource.addColumn("Ext", 100);
    _customListViewControl.defaultDataSource.addColumn("Size", 120);
    _customListViewControl.defaultDataSource.addColumn("Date", 170);
    _customListViewControl.defaultDataSource.addColumn("Attr", 100);
    _customListViewControl.autoFocus = widget.autoFocus;
    _customListViewControl.showCurrentRowSelectionWhenInactive = false;

    _customListViewControl.eventRowDoubleTap = (CustomListViewRow row) {
      mainAction();
    };

    _customListViewControl.eventOnKey = (RawKeyEvent ev) {
      if (ev is! RawKeyDownEvent) {
        return KeyEventResult.ignored;
      }

      if (ev.logicalKey == LogicalKeyboardKey.enter || ev.logicalKey == LogicalKeyboardKey.numpadEnter) {
        mainAction();
      }

      if (ev.logicalKey == LogicalKeyboardKey.backspace) {
        var lastDirName = p.basename(currentPath);
        var newCurrentPath = p.dirname(currentPath);
        newCurrentPath = p.normalize(newCurrentPath);
        loadDirectory(newCurrentPath, lastDirName);

        return KeyEventResult.handled;
      }

      if (ev.logicalKey == LogicalKeyboardKey.f1 && ev.isAltPressed) {
        widget.onShowSelector(0);
        //showSelector();
      }

      if (ev.logicalKey == LogicalKeyboardKey.f2 && ev.isAltPressed) {
        widget.onShowSelector(1);
        //showSelector();
      }

      if (ev.logicalKey == LogicalKeyboardKey.f3) {
        Executer().run("Hello").then((value) {
          print("RESULT: $value");
        });
        //showSelector();
      }

      return KeyEventResult.ignored;
    };

    loadDirectory(currentPath, "");
  }

  void showSelector() {
    setState(() {
      textEditingController.text = currentPath;
      widget.filePanelContext.buildSelectorVisible = true;
      selectorFocusNode.requestFocus();
    });
  }

  KeyEventResult mainAction() {
    CustomListViewRow row = _customListViewControl.currentRow();
    if (!row.cellValue(0).startsWith("[")) {
      return KeyEventResult.ignored;
    }

    if (row.cellValue(0) == "[..]") {
      var lastDirName = p.basename(currentPath);
      var newCurrentPath = p.dirname(currentPath);
      newCurrentPath = p.normalize(newCurrentPath);
      loadDirectory(newCurrentPath, lastDirName);
      return KeyEventResult.handled;
    }

    var newCurrentPath = p.join(currentPath, row.cellValue(0).replaceAll("[", "").replaceAll("]", ""));
    newCurrentPath = p.normalize(newCurrentPath);
    loadDirectory(newCurrentPath, "");
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    super.dispose();
    selectorFocusNode.dispose();
  }

  bool isRoot(String path) {
    if (path.length < 4) {
      return true;
    }
    return false;
  }

  List<String> roots() {
    List<String> result = [];
    result.add("C:\\");
    result.add("D:\\");
    result.add("E:\\");
    result.add("F:\\");
    return result;
  }

  void loadDirectory(String destPath, String selectItem) {
    final dir = Directory(destPath);
    dir.list().toList().then((value) {
      _customListViewControl.currentRowIndex = 0;
      _customListViewControl.defaultDataSource.removeAllRows();

      if (!isRoot(destPath)) {
        _customListViewControl.defaultDataSource.addRow(["[..]", "", "<DIR>", "", "--- --- ---"]);
      }

      for (var entry in value) {
        var stat = entry.statSync();
        if (stat.type == FileSystemEntityType.directory) {
          String name = p.basename(entry.path);
          String modTime = stat.changed.toString();
          _customListViewControl.defaultDataSource.addRow(["[$name]", "", "<DIR>", modTime, "--- --- ---"]);
        }
      }
      for (var entry in value) {
        var stat = entry.statSync();
        if (stat.type != FileSystemEntityType.directory) {
          String name = p.basenameWithoutExtension(entry.path);
          String ext = p.extension(entry.path);
          if (ext.startsWith(".")) {
            ext = ext.substring(1);
          }
          String modTime = stat.changed.toString();
          String sizeStr = stat.size.toString();
          _customListViewControl.defaultDataSource.addRow([name, ext, sizeStr, modTime, "--- --- ---"]);
        }
      }
      for (int i = 0; i < _customListViewControl.defaultDataSource.rowCount(); i++) {
        var row = _customListViewControl.defaultDataSource.row(i);
        if (row.cellValue(0) == "[$selectItem]") {
          _customListViewControl.currentRowIndex = i;
          break;
        }
      }
      currentPath = destPath;
      setState(() {});
    }).catchError((err) {
      print("loadDirectory error: $err");
    });
  }

  TextEditingController textEditingController = TextEditingController();
  FocusNode selectorFocusNode = FocusNode();

  Widget buildSelector() {
    if (!widget.filePanelContext.buildSelectorVisible) {
      return Container();
    }
    textEditingController.text = currentPath;
    return Center(
      child: Container(
        color: Colors.black54,
        width: 200,
        height: 300,
        child: FocusScope(
          onFocusChange: (value) {
            if (!value) {
              setState(() {
                widget.filePanelContext.buildSelectorVisible = false;
              });
            }
            //print("LOST FOCUS $value");
          },
          child: Column(
            children: [
              TextField(
                autofocus: true,
                focusNode: selectorFocusNode,
                controller: textEditingController,
              ),
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      loadDirectory(textEditingController.text, "");
                      widget.filePanelContext.buildSelectorVisible = false;
                    });
                  },
                  child: Text("Set"))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //final bool hasPrimary = Focus.of(context).hasPrimaryFocus;
    //_customListViewControl.canRequestFocus = !buildSelectorVisible;

    return Container(
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          Text(currentPath),
          Expanded(
            child: Stack(
              children: [
                CustomListViewWidget(
                  _customListViewControl,
                  //autoFocus: widget.autoFocus,
                  //showCurrentRowSelectionWhenInactive: false,
                ),
                buildSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

