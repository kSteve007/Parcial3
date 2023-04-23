import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:parcial_api_flutter/models/Marverl.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const AppiRestFlutter());
}

class AppiRestFlutter extends StatefulWidget {
  const AppiRestFlutter({super.key});

  @override
  State<AppiRestFlutter> createState() => _AppiRestFlutterState();
}

class _AppiRestFlutterState extends State<AppiRestFlutter> {
  late Future<List<Marvel>> _listadoMarvel;

  Future<List<Marvel>> getMarvel() async {
    final response = await http.get(Uri.parse(
        "https://gateway.marvel.com/v1/public/characters?ts=1&apikey=d55f2041db3f4a57449a2598bbbc389e&hash=e92e32ecd6c07d535cce03a7852e2acf"));

    List<Marvel> marvelList = [];
    if (response.statusCode == 200) {
      String bodys = utf8.decode(response.bodyBytes);
      //print(bodys);

      final JsonData = jsonDecode(bodys);
      //print(JsonData["data"]["results"]);
      for (var item in JsonData["data"]["results"]) {
        marvelList.add(Marvel(item["name"],
            item["thumbnail"]["path"] + "." + item["thumbnail"]["extension"]));
      }
    } else {
      throw Exception("Falla en conectarse");
    }
    return marvelList;
  }

  @override
  void initState() {
    super.initState();
    _listadoMarvel = getMarvel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Api Rest",
      home: Scaffold(
        appBar: AppBar(
          title: Text("<-----Parcial 3 API MARVEL ---->"),
          actions: [Icon(Icons.toys)],
        ),
        body: FutureBuilder(
            future: _listadoMarvel,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //print(snapshot.data);
                return GridView.count(
                  crossAxisCount: 2,
                  children: _listadoMarvels(snapshot.requireData),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  List<Widget> _listadoMarvels(List<Marvel> data) {
    List<Widget> marvels = [];

    for (var item in data) {
      marvels.add(Card(
          child: Column(
        children: [
          Expanded(
            child: Image.network(
              item.url,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.name),
          ),
        ],
      )));
    }
    return marvels;
  }
}
