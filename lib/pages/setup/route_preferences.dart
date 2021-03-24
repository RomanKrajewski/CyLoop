import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hiking4nerds/components/poi_category_search_bar.dart';
import 'package:hiking4nerds/services/global_settings.dart';
import 'package:hiking4nerds/services/localization_service.dart';
import 'package:hiking4nerds/services/routing/poi_category.dart';
import 'package:hiking4nerds/styles.dart';
import 'package:hiking4nerds/services/routeparams.dart';

class RoutePreferences extends StatefulWidget {
  final RouteParamsCallback onPushRouteList;
  final RouteParams routeParams;

  RoutePreferences(
      {@required this.onPushRouteList, @required this.routeParams});

  @override
  _RoutePreferencesState createState() => _RoutePreferencesState();
}

class _RoutePreferencesState extends State<RoutePreferences> {
  int avgHikingSpeed = 12; // 12 min per km
  var averageSpeeds = {"hike": 12, "bike": 3.5, "racingbike": 2, "mtb": 4};
  double distance = 5.0; // default
  int selectedAltitude = 0;
  bool distanceAsDuration = false;
  String vehicle = "hike";
  List<PoiCategory> selectedPoiCategories = List<PoiCategory>();

  altitudeSelection() {
    List<Widget> altitudeTypes = List();
    AltitudeType.values.forEach((v) {
      int index = v.index;
      altitudeTypes.add(FlatButton(
        child: Text(AltitudeTypeHelper.asString(v),
            style: TextStyle(fontSize: 16)),
        color: index == selectedAltitude ? htwGreen : htwGrey,
        onPressed: () {
          setState(() => selectedAltitude = index);
        },
      ));
    });
    return altitudeTypes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().getLocalization(english: "Route Preferences", german: "Routeneinstellungen")), 
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 5)),
                    Text(
                      LocalizationService().getLocalization(english: "Select Route Distance", german: "Routendistanz wählen"),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600]),
                      textAlign: TextAlign.left,
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    if(GlobalSettings().onlineRouting) Wrap(children: <Widget>[
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Hike", german: "Wandern"),
                              style: TextStyle(fontSize: 16)),
                          color: vehicle == 'hike' ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => vehicle = 'hike');
                          }),
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Bike", german: "Fahrrad"),
                              style: TextStyle(fontSize: 16)),
                          color: vehicle == 'bike' ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => vehicle = 'bike');
                          }),
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Racingbike", german: "Rennrad"),
                              style: TextStyle(fontSize: 16)),
                          color: vehicle == 'racingbike' ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => vehicle = 'racingbike');
                          }),
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Mountainbike", german: "Mountainbike"),
                              style: TextStyle(fontSize: 16)),
                          color: vehicle == 'mtb' ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => vehicle = 'mtb');
                          })],
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Wrap(children: <Widget>[
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Distance", german: "Distanz"),
                              style: TextStyle(fontSize: 16)),
                          color: !distanceAsDuration ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => distanceAsDuration = false);
                          }),
                      FlatButton(
                          child: Text(LocalizationService().getLocalization(english: "Time", german: "Zeit"),
                              style: TextStyle(fontSize: 16)),
                          color: distanceAsDuration ? htwGreen : htwGrey,
                          onPressed: () {
                            setState(() => distanceAsDuration = true);
                          })],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Slider(
                            activeColor: htwGreen,
                            inactiveColor: htwGrey,
                            min: 2.0,
                            max: GlobalSettings().onlineRouting ? 100 :30,
                            label: distance.toString(),
                            onChanged: (value) {
                              setState(() => distance = value.roundToDouble());
                            },
                            value: distance,
                          ),
                        ),
                        Container(
                          width: 60.0,
                          alignment: Alignment.center,
                          child: Text(
                            distanceAsDuration ? '${distance*averageSpeeds[vehicle]~/60} h ${(distance*averageSpeeds[vehicle]).toInt()%60} min' : '${distance.toInt()} km',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Divider(
                  color: htwGrey,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    LocalizationService().getLocalization(english: "Select Points of Interest", german: "Wähle Sehenswürdigkeiten"),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  PoiCategorySearchBar(
                      selectedCategories: selectedPoiCategories),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Divider(color: htwGrey),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    LocalizationService().getLocalization(english: "Select Altitude Difference", german: "Höhendifferenz wählen"),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.left,
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 5)),
                  Wrap(
                    children: altitudeSelection(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Divider(
                  color: htwGrey,
                ),
              ),
              SizedBox(height: 100,)
            ],
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery
                .of(context)
                .size
                .width * 0.5 - 35,
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                  backgroundColor: htwGreen,
                  heroTag: "btn-go",
                  child: Icon(FontAwesomeIcons.check, size: 30),
                  onPressed: () {
                    widget.routeParams.distanceKm = distance;
                    widget.routeParams.poiCategories = selectedPoiCategories;
                    widget.routeParams.altitudeType =
                        AltitudeTypeHelper.fromIndex(selectedAltitude);
                    widget.routeParams.vehicle = vehicle;
                    widget.onPushRouteList(widget.routeParams);
                  }),
            ),
          ),

        ],
      ),
    );
  }
}
