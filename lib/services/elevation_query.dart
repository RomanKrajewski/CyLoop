import 'package:hiking4nerds/services/route.dart';
import 'package:hiking4nerds/services/routing/node.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

// TODO perhaps it would be cleaner to resolve all services through
// TODO dependency injection

class ElevationQuery {
  static Future<List<double>> queryElevations(HikingRoute route) async {
    List<Node> path = route.path;
    List<double> queriedElevations = new List();
    String basisURL = "https://h4nsolo.f4.htw-berlin.de/elevation/api/v1/lookup?locations=";
    String currentURL = basisURL;
    int nodesPerQuery = 100; // they have to be divided because of the maximum URL character amount

    for (int i = 0; i < path.length; i++) {

      currentURL += path[i].latitude.toString() + "," + path[i].longitude.toString();

      if (i % nodesPerQuery == 0 && i > 0 || i == path.length - 1) { // every nodesPerQuery steps or when all paths were visited
        http.Response response = await http.get(Uri.parse(currentURL));
        dynamic parsedData = JSON.jsonDecode(response.body);
        int addRuns = (i % nodesPerQuery == 0) ? nodesPerQuery : i % nodesPerQuery;
        for (int j = 0; j < addRuns; j++) {
          
          queriedElevations.add(parsedData["results"][j]["elevation"].toDouble());
        }
        currentURL = basisURL; // reset URL for next query
      } else {
        currentURL += "|"; // when there will follow a further node
      }
    }

    // Alternatively the result could be assigned to the passed route reference
    return queriedElevations; 
  }

  static Future<List<double>> queryElevationsBetter(HikingRoute route) async {
    String basisURL = "https://h4nsolo.f4.htw-berlin.de/elevation/api/v1/lookup";
    List<Map<String, double>> locations = route.path.map((e) => {"latitude": e.latitude, "longitude": e.longitude}).toList();
    Map<String, String> headers = {"Accept": "application/json", "Content-Type": "application/json"};
    http.Response response = await http.post(Uri.parse(basisURL), headers: headers, body: JSON.jsonEncode({"locations": locations}));
    List<dynamic> parsedData = JSON.jsonDecode(response.body)["results"];
    List<double> queriedElevations = new List();
    parsedData.forEach((element) {queriedElevations.add(element["elevation"].toDouble());});
    return queriedElevations;
  }
}
