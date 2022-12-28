import 'dart:convert';

import 'package:http/http.dart' as http;

class Song {
  final String url;
  final String id;
  final String title;
  final String album;

  const Song(
      {required this.url,
      required this.id,
      required this.title,
      required this.album});

  factory Song.fromJson(Map<String, dynamic> json) {
    return const Song(
      id: "json['id'].toString()",
      title: "json['name']",
      url: "json['url']",
      album: 'json["singer"]',
    );
  }
}

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
}

class DemoPlaylist extends PlaylistRepository {
  List<Song> allSongs = [];

  Future<void> getAllSongs() async {
    final response = await http.get(
        Uri.parse("https://water01.myh2o.top:1103/static/musics/Hymns.json"));
    if (response.statusCode == 200) {
      Utf8Decoder decode = const Utf8Decoder();
      Map<String, dynamic> json =
          jsonDecode(decode.convert(response.bodyBytes));
      for (var song in json["songs"]) {
        allSongs.add(Song(
            album: song["singer"],
            url: song["url"],
            id: song["id"].toString(),
            title: song["name"]));
      }
    } else {
      // If the call was not successful, throw an error
      throw Exception('Failed to load data');
    }
  }

  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist() async {
    // return List.generate(length, (index) => _nextSong());
    return formatAllSongs();
  }

  Future<List<Map<String, String>>> formatAllSongs() async {
    await getAllSongs();
    List<Map<String, String>> s = [];
    for (var song in allSongs) {
      s.add({
        'id': song.id,
        'title': song.title,
        'album': song.album,
        'url': song.url,
      });
    }
    return s;
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;

  Map<String, String> _nextSong() {
    _songIndex++;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'url':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
    };
  }
}
