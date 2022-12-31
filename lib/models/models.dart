import 'package:qingyin_music/api/api.dart';

class PlaylistInfo {
  late String coverImg;
  late String title;
  late int songs;
  late String songsLink;

  PlaylistInfo(
      {required this.coverImg,
      required this.title,
      required this.songs,
      required this.songsLink});

  PlaylistInfo.fromJson(Map<String, dynamic> json) {
    coverImg = json['coverImg'];
    title = json['title'];
    songs = json['songs'];
    songsLink = json['songs_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coverImg'] = coverImg;
    data['title'] = title;
    data['songs'] = songs;
    data['songs_link'] = songsLink;
    return data;
  }

  static Future<List<Object>> validName(path) async {
    try {
      var playlistInfo = await getPlayList(path: path);
      return [true, playlistInfo.title];
    } catch (e) {
      return [false, ""];
    }
  }

  @override
  String toString() {
    return "$title - $songs";
  }
}

class SongInfo {
  late String coverImg;
  late String title;
  late String singer;
  late String url;

  SongInfo({
    required this.coverImg,
    required this.title,
    required this.singer,
    required this.url,
  });

  SongInfo.fromJson(Map<String, dynamic> json) {
    coverImg = json['coverImg'];
    title = json['title'];
    singer = json['singer'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coverImg'] = coverImg;
    data['title'] = title;
    data['singer'] = singer;
    data['url'] = url;
    return data;
  }

  factory SongInfo.gen() {
    return SongInfo(
      coverImg: "https://water01.myh2o.top:1103/static/musics/cover/93.jpg",
      title: "一粒麦子",
      singer: "未知",
      url: "https://water01.myh2o.top:1103/static/musics/Songs/一粒麦子.mp3",
    );
  }

  @override
  String toString() {
    return "$title - $singer";
  }
}
