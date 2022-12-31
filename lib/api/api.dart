import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:qingyin_music/models/models.dart';
import 'package:qingyin_music/storages/storages.dart';

Future<PlaylistInfo> getPlayList({String path = "__Songs.json"}) async {
  String baseUrl = Storage.get("BASE_URL") ?? "http://example.com/";
  final rsp = await http.get(Uri.parse(("$baseUrl$path")));
  if (rsp.statusCode == 200) {
    Utf8Decoder decode = const Utf8Decoder();
    Map<String, dynamic> json = jsonDecode(decode.convert(rsp.bodyBytes));
    return PlaylistInfo.fromJson(json);
  } else {
    throw Exception('invalid baseurl: $baseUrl \n or path: $path');
  }
}

Future<List<SongInfo>> getSongs({
  String url = "https://water01.myh2o.top:1103/static/musics/Songs.json",
}) async {
  final rsp = await http.get(Uri.parse(url));
  if (rsp.statusCode == 200) {
    Utf8Decoder decode = const Utf8Decoder();
    List datas = jsonDecode(decode.convert(rsp.bodyBytes));
    List<SongInfo> songs = [];
    for (var data in datas) {
      songs.add(SongInfo.fromJson(data));
    }
    return songs;
  } else {
    throw Exception('Failed to load data');
  }
}
