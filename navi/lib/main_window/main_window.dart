import 'package:flutter/material.dart';
import 'package:navi/file_panel/file_panel.dart';

class MainWindow extends StatefulWidget {
  const MainWindow({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MainWindowState();
  }
}

class MainWindowState extends State<MainWindow> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSelector(int n) {
    setState(() {
      if (n == 0) {
        filePanelContext1.buildSelectorVisible = true;
      }
      if (n == 1) {
        filePanelContext2.buildSelectorVisible = true;
      }
    });
  }

  FilePanelContext filePanelContext1 = FilePanelContext();
  FilePanelContext filePanelContext2 = FilePanelContext();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusScope(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FilePanel(true, showSelector, filePanelContext1),
                  ),
                  Expanded(
                    child: FilePanel(false, showSelector, filePanelContext2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
