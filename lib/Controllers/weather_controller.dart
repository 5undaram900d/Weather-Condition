
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:weather_condition/Utils/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:weather_condition/credentials.dart';

class WeatherController extends GetxController{

  var isLoaded = false.obs;

  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  dynamic currentWeatherData;
  dynamic hourlyWeatherData;

  final TextEditingController nameTextEditingController = TextEditingController();
  final selectedPlace = "".obs;
  final RxList<dynamic> placesList = [].obs;

  final GetStorage storage = GetStorage();


  @override
  void onInit() async{                   // in getx in place used onInit() like place of Init() in stateful
    nameTextEditingController.addListener(() {
      onChange();
    });

    // Load saved data
    if (storage.hasData('latitude') && storage.hasData('longitude') && storage.hasData('selectedPlace')) {
      latitude.value = storage.read('latitude');
      longitude.value = storage.read('longitude');
      selectedPlace.value = storage.read('selectedPlace');
      onEnter();
      isLoaded.value = true;
    }

    super.onInit();
  }

  onChange() {
    getSuggestion(nameTextEditingController.text);
  }

  void getSuggestion(String input)async {
    String baseURl = 'https://api.geoapify.com/v1/geocode/autocomplete';
    String request = '$baseURl?text=$input&apiKey=$GOOGLE_MAP_API_KEY';
    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();


    // Parse the JSON data
    Map<String, dynamic> jsonData = jsonDecode(data);

    // Initialize a list to store city names
    List<String> cityNames = [];

    // Extract city names from features
    for (var feature in jsonData['features']) {
      String ?cityName = feature['properties']['city'];
      debugPrint("******* $cityName ***************************");
      cityName!=null ? cityNames.add(cityName) : null;
    }

    // for debugging purpose
    debugPrint(cityNames.toList().toString());

    if(response.statusCode==200){
        placesList.value = cityNames;
    }
    else{
      throw Exception('Failed to load data');
    }
  }



  onEnter() {
    currentWeatherData = getCurrentWeather(latitude.value, longitude.value);
    hourlyWeatherData = getHourlyWeather(latitude.value, latitude.value);
  }

}