import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Data {
  final String title;
  final String locationType;
  final int woeid;
  final String lattlong;

  Data({this.title, this.locationType, this.woeid, this.lattlong});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
        title: json['title'],
        locationType: json['location_type'],
        woeid: json['woeid'],
        lattlong: json['latt_long']);
  }
}

class Weather extends StatefulWidget {
  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  // This holds a list of fiction users
  // You can use data fetched from a database or cloud as well
  Future<Null> fetchData() async {
    final response = await http
        .get('https://www.metaweather.com/api/location/search/?query=ba');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(
        () {
          for (Map data in jsonResponse) {
            locatioData.add(Data.fromJson(data));
          }
        },
      );
    } else {
      throw Exception('Unexpected error occured!');
    }
  }

  // This list holds the data for the list view
  List<Data> _foundResult = [];
  List<Data> locatioData = [];

  @override
  initState() {
    // at the beginning, all users are shown
    super.initState();
    fetchData();
    _foundResult = locatioData;
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Data> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = locatioData;
    } else {
      results = locatioData
          .where((user) =>
              user.title.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

      // we use the toLowerCase() method to make it case-insensitive
    }

    // Refresh the UI
    setState(() {
      _foundResult = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.black),
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  labelText: 'Search Location', suffixIcon: Icon(Icons.search)),
            ),
            Expanded(
              child: _foundResult.length > 0
                  ? ListView.builder(
                      itemCount: _foundResult.length,
                      itemBuilder: (context, index) => Card(
                        color: Colors.blue,
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.location_city,
                                size: 60,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 15, bottom: 5),
                                    child: Text(
                                      _foundResult[index].woeid.toString(),
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      _foundResult[index].title,
                                      style: TextStyle(
                                          fontSize: 19, color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      '${_foundResult[index].locationType.toString()}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      "longitute: " +
                                          '${_foundResult[index].lattlong.toString()}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          'No results found',
                          style: TextStyle(fontSize: 24, color: Colors.blue),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
