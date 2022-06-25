import 'dart:convert';
import 'dart:io';

class Executer {
  static final Executer _singleton = Executer._internal();
  factory Executer() {
    //_singleton._process = null;
    return _singleton;
  }

  Process? _process = null;
  bool processing = false;
  String result = "";

  Future<String> run(String cmd) async {
    if (_process == null) {
      _process = await Process.start("d:\\Temp\\2022\\06-24\\main.exe", []);
      if (_process != null) {
        _process?.stdout
            .transform(utf8.decoder)
            .forEach((element) {
          print(">> $element");
          result = element;
          processing = false;
          //_process?.stdin.write("exit\n");
        },);
        _process?.exitCode.then((value) {
          print("Exit ${value}");
          _process = null;
        });
      }
    }

    if (_process != null) {
      processing = true;
      _process?.stdin.write("$cmd\n");
    }


    print("waiting");
    while(processing) {
        await Future.delayed(const Duration(milliseconds: 100));
        print("w $processing $result");
    }
    print("waiting ok");

    return result;
  }

  Executer._internal();
}
