import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navi/create_directory_dialog.dart';
import 'package:navi/error_dialog.dart';
import 'package:navi/main.dart';

import '../custom_listview/custom_listview.dart';
import 'package:path/path.dart' as p;

import '../executer/navi_server.dart';

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
  TextEditingController createDirectoryTextController = TextEditingController();

  String currentPath = "d:\\";

  @override
  void initState() {
    super.initState();

    _customListViewControl.defaultDataSource.addColumn("Name", 400);
    _customListViewControl.defaultDataSource.addColumn("Ext", 70);
    _customListViewControl.defaultDataSource.addColumn("Size", 150);
    _customListViewControl.defaultDataSource.addColumn("Date", 160);
    _customListViewControl.defaultDataSource.addColumn("Attr", 100);

    _customListViewControl.defaultDataSource.column(0).setAlign(TextAlign.start);
    _customListViewControl.defaultDataSource.column(1).setAlign(TextAlign.start);
    _customListViewControl.defaultDataSource.column(2).setAlign(TextAlign.end);

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
        showSelector();
      }

      if (ev.logicalKey == LogicalKeyboardKey.f2) {
        loadDirectory(currentPath, "");
      }

      if (ev.logicalKey == LogicalKeyboardKey.f7) {
        createDirectoryTextController.text = "";
        showCreateDirectoryDialog(context, createDirectoryTextController).then((dialogRes) {
          print("dialogRes: $dialogRes");
          if (dialogRes != null) {
            String dirName = createDirectoryTextController.text;
            NaviServer().directoryCreate("$currentPath/$dirName").then((v) {
              loadDirectory(currentPath, dirName);
            }).catchError((err) {
              showErrorDialog(context, err.toString());
            });
          }
        });
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

  bool extIsExecutable(String ext) {
    switch (ext) {
      case ".exe":
      case ".com":
      case ".bat":
      case ".cmd":
        return true;
    }
    return false;
  }

  bool extIsArchive(String ext) {
    switch (ext) {
      case ".zip":
      case ".rar":
      case ".tar":
      case ".gz":
        return true;
    }
    return false;
  }

  bool extIsPicture(String ext) {
    switch (ext) {
      case ".png":
      case ".jpg":
      case ".ico":
      case ".bmp":
        return true;
    }
    return false;
  }

  bool extIsDocument(String ext) {
    switch (ext) {
      case ".doc":
      case ".docx":
      case ".csv":
      case ".pdf":
        return true;
    }
    return false;
  }

  Color colorByType(NaviServerDirectoryContentResponseItem item) {
    if (item.isDirectory) {
      return const Color.fromARGB(255, 200, 200, 200);
    }
    if (extIsExecutable(p.extension(item.baseName))) {
      return Colors.greenAccent;
    }
    if (extIsArchive(p.extension(item.baseName))) {
      return Colors.purpleAccent;
    }
    if (extIsDocument(p.extension(item.baseName))) {
      return Colors.amberAccent;
    }
    if (extIsPicture(p.extension(item.baseName))) {
      return Colors.yellow;
    }
    return Colors.grey;
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
    NaviServer().directoryContent(destPath).then((value) {
      //print("OK");

      _customListViewControl.currentRowIndex = 0;
      _customListViewControl.defaultDataSource.removeAllRows();

      if (!isRoot(destPath)) {
        _customListViewControl.defaultDataSource.addRow(["[..]", "", "<DIR>", "", "--- --- ---"]);
      }

      for (var entry in value.items) {
        //var stat = entry.statSync();
        if (entry.isDirectory) {
          String name = p.basename(entry.path);
          String modTime = entry.modifiedDT;
          var row = _customListViewControl.defaultDataSource.addRow(["[$name]", "", "<DIR>", modTime, "--- --- ---"]);
          row.setColor(colorByType(entry));
          row.setCellFontSize(3, 12);
        }
      }
      for (var entry in value.items) {
        //var stat = entry.statSync();
        if (!entry.isDirectory) {
          String name = p.basenameWithoutExtension(entry.path);
          String ext = p.extension(entry.path);
          if (ext.startsWith(".")) {
            ext = ext.substring(1);
          }
          String modTime = entry.modifiedDT;
          String sizeStr = entry.sizeString;
          var row = _customListViewControl.defaultDataSource.addRow([name, ext, sizeStr, modTime, "--- --- ---"]);
          Color rowColor = colorByType(entry);
          row.setColor(rowColor);
          row.setCellColor(3, rowColor.withOpacity(0.3));
          row.setCellFontSize(3, 12);
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
      showErrorDialog(context, err.toString());
    });
    return;
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

