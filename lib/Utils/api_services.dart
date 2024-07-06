
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_condition/Models/current_weather_model.dart';
import 'package:weather_condition/Models/hourly_weather_model.dart';

import 'package:http/http.dart' as http;
import 'package:weather_condition/credentials.dart';


getCurrentWeather(lat, long) async {
  var link = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$OPEN_WEATHER_API_KEY&units=metric";
  var res = await http.get(Uri.parse(link));

  if(res.statusCode == 200){
    var data = currentWeatherDataFromJson(res.body.toString());
    debugPrint("Fetching data successfully ::::: ${data.weather[0].main}, $lat & $long, ${data.name}");
    return data;
  }
  else {
    debugPrint("Error for getCurrentWeather");
  }
}


getHourlyWeather(lat, long) async {
  var hourlyLink = "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&appid=$OPEN_WEATHER_API_KEY&units=metric";
  var res = await http.get(Uri.parse(hourlyLink));

  if(res.statusCode == 200){
    var data = hourlyWeatherDataFromJson(res.body.toString());
    debugPrint("Fetching hourly data successfully ::::::::::::: ${data.list[0].main.temp}⁰");
    return data;
  }
  else {
    debugPrint("Error for getHourlyWeather");
  }
}





sendRequestToAPI(String apiUrl) async{
  http.Response responseFromAPI = await http.get(Uri.parse(apiUrl),);
  try{
    if(responseFromAPI.statusCode == 200){
      String dataFormAPI = responseFromAPI.body;
      var dataDecoded = jsonDecode(dataFormAPI);
      return dataDecoded;
    }
    else{
      return "error";
    }
  } catch (error){
    return "error";
  }
}


