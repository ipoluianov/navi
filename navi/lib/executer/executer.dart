import 'dart:convert';
import 'dart:io';

class ExecuterTransaction {
  String transaction = "";
  bool processing = false;
  String result = "";
  String error = "";
}

class Executer {
  Process? _process;
  String inputBuffer = "";
  //bool processing = false;
  //String result = "";
  int transactionId = 1;
  bool processStarting = false;
  Map<String, ExecuterTransaction> transactions = <String, ExecuterTransaction>{};

  Future<String> run(String cmd) async {
    DateTime dtBeginFunction = DateTime.now();
    while (processStarting) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (DateTime.now().difference(dtBeginFunction).inMilliseconds > 2000) {
        return "";
      }
    }
    print("run $cmd");

    if (_process == null) {
      processStarting = true;
      _process = await Process.start("c:\\src\\p\\navi\\naviserver\\naviserver.exe", []);
      inputBuffer = "";
      if (_process != null) {
        _process?.stdout.transform(utf8.decoder).forEach(
          (el) {
            inputBuffer += el;

            var indexOfRet = inputBuffer.indexOf("\n");
            while (indexOfRet > 0) {
              var element = inputBuffer.substring(0, indexOfRet);
              inputBuffer = inputBuffer.substring(indexOfRet + 1);

              element = utf8.decode(base64Decode(element));
              int indexOfSplitter = element.indexOf(":");
              if (indexOfSplitter >= 1) {
                String transactionId = element.substring(0, indexOfSplitter);

                if (transactions.containsKey(transactionId)) {
                  ExecuterTransaction? executerTransaction = transactions[transactionId];
                  if (executerTransaction != null) {
                    int indexOfErrorSplitter = element.indexOf("!", indexOfSplitter);
                    if (indexOfErrorSplitter >= 0) {
                      executerTransaction.error = element.substring(indexOfErrorSplitter + 1);
                      executerTransaction.processing = false;
                    } else {
                      int indexOfRegularSplitter = element.indexOf("=", indexOfSplitter);
                      if (indexOfRegularSplitter >= 1) {
                        String response = element.substring(indexOfRegularSplitter + 1);
                        executerTransaction.result = response;
                        executerTransaction.processing = false;
                      }
                    }
                  }
                }
              }
              indexOfRet = inputBuffer.indexOf("\n");
            }

            //result = element;
            //processing = false;
            //_process?.stdin.write("exit\n");
          },
        );
        _process?.exitCode.then((value) {
          print("Exit ${value}");
          _process = null;
          inputBuffer = "";
        });
      }
    }

    processStarting = false;

    ExecuterTransaction tr = ExecuterTransaction();

    if (_process != null) {
      transactionId++;
      tr.processing = true;
      tr.transaction = transactionId.toString();
      transactions[tr.transaction.toString()] = tr;
      var b64 = base64Encode(utf8.encode("${tr.transaction}:$cmd"));
      _process?.stdin.write("$b64\n");
    }

    DateTime dtBegin = DateTime.now();
    print("waiting");
    while (tr.processing) {
      await Future.delayed(const Duration(milliseconds: 20));
      print("w ${tr.transaction} ${tr.processing}");

      if (DateTime.now().difference(dtBegin).inMilliseconds > 1000) {
        print("timeout");
        break;
      }
    }
    print("waiting ok ${_process!.pid}");

    if (tr.error.isNotEmpty) {
      throw Exception(tr.error);
    }

    return tr.result;
  }
}
