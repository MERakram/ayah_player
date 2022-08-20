import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'surah_list.dart';

class editions_page extends StatefulWidget {
  @override
  _editions_pageState createState() {
    return _editions_pageState();
  }
}

class _editions_pageState extends State<editions_page> {
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
        await rootBundle.loadString('assets/json_data/editions.json');
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
                        builder: (context) => surahs_page(
                          edition: _items[index]["identifier"],
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
