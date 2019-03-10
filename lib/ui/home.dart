import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder<Map>(
      future: _getQuakesData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text(
              'loading...',
              style: TextStyle(
                fontSize: 17.2,
                fontWeight: FontWeight.bold
              ));
          default:
            if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error}');
            }
            else {
              return createListView(context, snapshot);
            }
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Quake tracker"),
        backgroundColor: Colors.redAccent,
      ),
      body: futureBuilder
    );
  }

  Future<Map> _getQuakesData() async {
    String url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
    http.Response response = await http.get(url);
    return json.decode(response.body);
  }

  _getQuakeDate(unixDate) {
    var format = new DateFormat.yMMMMd("en_US").add_jm();
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(unixDate);
    var dateString = format.format(date);
    return dateString;
  }

  _showQuakeTitle(BuildContext context, String title) {
    var dialogMessage = AlertDialog(
      title: Text(
        title
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Close"
          ),
        )
      ],
    );

    showDialog(context: context, builder: (context) {
      return dialogMessage;
    });
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List _features = snapshot.data['features'];

    return new ListView.builder(
        itemCount: _features == null ? 0 : _features.length,
        itemBuilder: (BuildContext context, int index) {
          return new Column(
            children: <Widget>[
              new ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Text(
                    _features[index]["properties"]["mag"].toString(),
                    style: TextStyle(
                      fontSize: 14.2,
                      color: Colors.white
                    ),
                  ),
                ),
                title: new Text(
                  _getQuakeDate(_features[index]["properties"]["time"]),
                  style: TextStyle(
                    color: Colors.green
                  ),
                ),
                subtitle: new Text(
                  _features[index]["properties"]["place"],
                  style: TextStyle(
                      fontStyle: FontStyle.italic
                  ),
                ),
                onTap: () => _showQuakeTitle(context, _features[index]["properties"]["place"]),
              ),
              new Divider(height: 2.0,)
            ],
          );
        },
    );
  }
}
