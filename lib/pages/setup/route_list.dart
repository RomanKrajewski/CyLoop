import 'package:flutter/material.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/osmdata.dart';
import 'package:hiking4nerds/services/routeparams.dart';
import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/styles.dart';

class RouteList extends StatefulWidget {
  final RouteParamsCallback onPushRoutePreview;
  final RouteParams routeParams;

  RouteList({@required this.onPushRoutePreview, this.routeParams});

  @override
  _RouteListState createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  List<RouteListEntry> routeList = [];
  String summary = '';

  @override
  void initState() {
    super.initState();
    // todo implement loading bar
    calculateRoutes();
  }

  Future<void> calculateRoutes() async {
    List<HikingRoute> routes;

    try {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10,
          widget.routeParams.poiCategories);
    } on NoPOIsFoundException catch (err) {
        print("no poi found exception " + err.toString());
    } finally {
      routes = await OsmData().calculateHikingRoutes(
          widget.routeParams.startingLocation.latitude,
          widget.routeParams.startingLocation.longitude,
          widget.routeParams.distanceKm * 1000.0,
          10);
    }
    setState(() {
      widget.routeParams.routes = routes;
      print('## ${routes.length} routes found');
      widget.routeParams.routes.forEach((r) => routeList.add(RouteListEntry(
            r.title,
            r.date,
            r.totalLength,
          )));
    });
  }

  // TODO add localization or remove if not needed
  void summaryText() {
    String text = LocalizationService().getLocalization(english: "Displaying routes for your chosen parameters\n", german: "Routen für die gewählten Parameter werden dargestellt\n");
    text += LocalizationService().getLocalization(english: "Distance:", german: "Distanz:") + '${widget.routeParams.distanceKm}\n'; 
    text += (widget.routeParams.poiCategories.length > 0) ? 'POIs: \n' : '';
    text += LocalizationService().getLocalization(english: "Altitude:", german: "Höhe:") + '${widget.routeParams.altitudeType}\n';
    print(text);
    summary = text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: htwGreen,
          title: Text(LocalizationService().getLocalization(english: "Choose a route to preview", german: "Route für Vorschau wählen")),
          elevation: 0,
        ),
        body: Stack(children: <Widget>[
          Text(
            summary,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]),
            textAlign: TextAlign.left,
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
          ListView.builder(
            itemCount: routeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      widget.routeParams.routeIndex = index;
                      widget.onPushRoutePreview(widget.routeParams);
                    },
                    title: Text(routeList[index].title),
                    subtitle: Text(
                        LocalizationService().getLocalization(english: "Distance:", german: "Distanz:") + '${routeList[index].distance.toString()}\n${LocalizationService().getLocalization(english: "Date:", german: "Datum:")}: ${routeList[index].date}'),
                    leading: CircleAvatar(
                        child: Icon(
                      Icons.directions_walk,
                      color: htwGreen,
                    )
                        //backgroundImage: (routeList[index].avatar == null) ? AssetImage('assets/img/h4n-icon2.png') : AssetImage('assets/img/h4n-icon2.png'),
                        ),
                  ),
                ),
              );
            },
          ),
        ]));
  }
}

class RouteListEntry {
  String title; // Route title i.e. Address, city, regio, custom
  String date; // Route date - created
  String distance; // Route length in KM
  CircleAvatar avatar;

  // RouteListTile({ this.title, this.date, this.distance, this.avatar });

  RouteListEntry(String title, String date, double distance) {
    this.title = title;
    this.date = date;
    this.distance = formatDistance(distance);
    // this.avatar = avatar;
  }

  String formatDistance(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}
