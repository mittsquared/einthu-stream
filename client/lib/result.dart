import 'package:einthu_stream/adapter.dart';
import 'package:einthu_stream/details.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class Result {
  String title;
  String coverImageUrl;
  int year;
  List<String> qualities;
  bool hasSubtitles;
  String _description;
  double rating;
  String language;
  bool isPopular;
  Class genre;
  String wiki;
  String trailer;
  List<Professionals> professionals;
  String id;

  Result(
      {this.title,
      this.coverImageUrl,
      this.year,
      this.qualities,
      this.hasSubtitles,
      this.rating,
      this.language,
      this.isPopular,
      this.genre,
      this.wiki,
      this.trailer,
      this.professionals,
      this.id});

  void setDescription(String d) {
    this._description = d;
  }

  Future<String> get description async {
    if (this._description == null) {
      final d = await Adapter.describe(this.id);
      this._description = d;
    }
    return this._description;
  }

  Widget build(BuildContext context) {
    final line2 = <String>[
      this.language,
      this.year.toString(),
      this.genre.toString().split('.').last
    ].join(' • ');

    final q = this.qualities.map((i) {
      switch (i) {
        case 'sd':
          return 'SD';
        case 'hd':
          return 'HD';
        case 'ultrahd':
          return '4K';
      }
    }).join(' • ');

    final l3 = <String>[q];
    if (this.hasSubtitles) l3.add('CC');
    final line3 = l3.join(' • ');

    final l4 = <String>[
      this.rating == 0 ? 'Unrated' : '${this.rating.toString()} ★',
    ];
    if (this.isPopular) l4.add('Popular');
    final line4 = l4.join(' • ');

    return Card(
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              // fullscreenDialog: true,
              builder: (context) => DetailScreen(movie: this),
            ),
          );

          // final url = await Adapter.resolve(this.id);
          // await launcher.launch(url);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CoverHero(
                  movie: this,
                  width: 120,
                  height: 180,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          this.title,
                          style: TextStyle(fontSize: 24),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        Text(line2, style: TextStyle(fontSize: 16)),
                        Text(line3, style: TextStyle(fontSize: 16)),
                        Text(line4, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: Text('Download'),
                          value: 0,
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          child: Text('Watch trailer'),
                          value: 1,
                          enabled: this.trailer != null,
                        ),
                        PopupMenuItem(
                          child: Text('Visit wiki page'),
                          value: 2,
                          enabled: this.wiki != null,
                        ),
                      ],
                  onSelected: (i) async {
                    switch (i) {
                      case 0:
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("Downloads coming soon ..."),
                        ));
                        break;
                      case 1:
                        await launcher.launch(this.trailer);
                        break;
                      case 2:
                        await launcher.launch(this.wiki);
                        break;
                      default:
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Result.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    coverImageUrl = json['coverImageUrl'];
    year = json['year'];
    qualities = json['qualities'].cast<String>();
    hasSubtitles = json['hasSubtitles'];
    _description = json['description'];
    rating = json['rating'];
    language = json['language'];
    isPopular = json['isPopular'];
    genre = Class.values[json['genre'] + 1];
    wiki = json['wiki'];
    trailer = json['trailer'];
    if (json['professionals'] != null) {
      professionals = List<Professionals>();
      json['professionals'].forEach((v) {
        professionals.add(Professionals.fromJson(v));
      });
    }
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['title'] = this.title;
    data['coverImageUrl'] = this.coverImageUrl;
    data['year'] = this.year;
    data['qualities'] = this.qualities;
    data['hasSubtitles'] = this.hasSubtitles;
    data['description'] = this._description;
    data['rating'] = this.rating;
    data['language'] = this.language;
    data['isPopular'] = this.isPopular;
    data['genre'] = this.genre.index - 1;
    data['wiki'] = this.wiki;
    data['trailer'] = this.trailer;
    if (this.professionals != null) {
      data['professionals'] =
          this.professionals.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    return data;
  }
}

enum Class { Unknown, Action, Comedy, Romance }

class Professionals {
  String name;
  String role;
  String avatar;

  Professionals({this.name, this.role, this.avatar});

  Professionals.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    role = json['role'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['role'] = this.role;
    data['avatar'] = this.avatar;
    return data;
  }
}

class CoverHero extends StatelessWidget {
  CoverHero({Key key, this.movie, this.width, this.height}) : super(key: key);

  final Result movie;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: movie.id,
      child: FadeInImage.assetNetwork(
        image: movie.coverImageUrl,
        placeholder: 'assets/placeholder.png',
        width: this.width,
        height: this.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
