import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'main.dart';

class surahs_page extends StatefulWidget {
  final edition;

  const surahs_page({super.key, required this.edition});
  @override
  _surahs_pageState createState() {
    return _surahs_pageState();
  }
}

class _surahs_pageState extends State<surahs_page> {
  List _items = [];

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> readJson() async {
    final String response =
    await rootBundle.loadString('assets/json_data/surat.json');
    final data = await json.decode(response);
    setState(() {
      _items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(parent: null),
            shrinkWrap: true,
            itemCount: _items.length,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.fromLTRB(12, 1, 12, 5),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 60,
                width: 50,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => player_page(
                          widget.edition,
                          _items[index]["name"],
                          _items[index]["surah"],
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      '${_items[index]["name"]}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // subtitle: Text(
                    //   'Description $index',
                    //   style: TextStyle(
                    //     fontSize: 15,
                    //   ),
                    // ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
