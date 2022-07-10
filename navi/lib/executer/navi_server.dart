import 'dart:convert';

import 'package:navi/executer/executer.dart';

typedef FromJsonFunc = dynamic Function(Map<String, dynamic> json);

class NaviServer extends Executer {
  static final NaviServer _singleton = NaviServer._internal();
  factory NaviServer() {
    return _singleton;
  }

  Future<NaviServerDirectoryContentResponse> directoryContent(String path) async {
    return fetch<NaviServerDirectoryContentRequest, NaviServerDirectoryContentResponse>(
      NaviServerDirectoryContentRequest(path),
      (Map<String, dynamic> json) => NaviServerDirectoryContentResponse.fromJson(json),
    );
  }

  Future<NaviServerDirectoryCreateResponse> directoryCreate(String path) async {
    return fetch<NaviServerDirectoryCreateRequest, NaviServerDirectoryCreateResponse>(
      NaviServerDirectoryCreateRequest(path),
          (Map<String, dynamic> json) => NaviServerDirectoryCreateResponse.fromJson(json),
    );
  }

  Future<TResp> fetch<TReq, TResp>(TReq request, FromJsonFunc fromJson) async {
    var req = jsonEncode(request);
    var resp = await run(req);
    return fromJson(jsonDecode(resp));
  }

  NaviServer._internal();
}

class NaviServerDirectoryContentRequest {
  String path;
  NaviServerDirectoryContentRequest(this.path);
  Map<String, dynamic> toJson() => {
        'f': 'directory-content',
        'path': path,
      };
}

class NaviServerDirectoryContentResponseItem {
  bool isDirectory;
  String path;
  String baseName;
  int size;
  String sizeString;
  String modifiedDT;
  NaviServerDirectoryContentResponseItem(this.isDirectory, this.path, this.baseName, this.size, this.sizeString, this.modifiedDT);
  factory NaviServerDirectoryContentResponseItem.fromJson(Map<String, dynamic> json) {
    return NaviServerDirectoryContentResponseItem(
      json['is_directory'],
      json['path'],
      json['basename'],
      json['size'],
      json['size_string'],
      json['modified_dt'],
    );
  }
}

class NaviServerDirectoryContentResponse {
  List<NaviServerDirectoryContentResponseItem> items;
  NaviServerDirectoryContentResponse(this.items);
  factory NaviServerDirectoryContentResponse.fromJson(Map<String, dynamic> json) {
    return NaviServerDirectoryContentResponse(
      List<NaviServerDirectoryContentResponseItem>.from(
        json['entries'].map((model) => NaviServerDirectoryContentResponseItem.fromJson(model)),
      ),
    );
  }
}

class NaviServerDirectoryCreateRequest {
  String path;
  NaviServerDirectoryCreateRequest(this.path);
  Map<String, dynamic> toJson() => {
    'f': 'directory-create',
    'path': path,
  };
}

class NaviServerDirectoryCreateResponse {
  NaviServerDirectoryCreateResponse();
  factory NaviServerDirectoryCreateResponse.fromJson(Map<String, dynamic> json) {
    return NaviServerDirectoryCreateResponse();
  }
}
