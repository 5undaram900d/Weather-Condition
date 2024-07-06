/*
- Display the following information:
  ~ City name
  ~ Current temperature (in Celsius)
  ~ Weather condition (e.g., cloudy, sunny, rainy)
  ~ An icon representing the weather condition
  ~ Humidity percentage
  ~ Wind speed

  @ Add a "Refresh" button to fetch updated weather data
  @ Implement data persistence to save the last searched city
 */





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_condition/Controllers/theme_controller.dart';
import 'package:weather_condition/Models/current_weather_model.dart';
import 'package:weather_condition/Models/hourly_weather_model.dart';
import 'package:weather_condition/Controllers/weather_controller.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // date formatting
    var date = DateFormat("yMMMMd").format(DateTime.now());

    // initialize ThemeController
    final ThemeController themeController = Get.put(ThemeController());
    var theme = Theme.of(context);      // for shaving the theme state

    // initialize a WeatherController
    var controller = Get.put(WeatherController());


    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(date, style: TextStyle(color: theme.primaryColor),),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: [
            // theme changer button
            Obx(
              () => IconButton(
                onPressed: (){
                  themeController.toggleTheme();
                },
                icon: Icon(themeController.isDark.value ? Icons.light_mode : Icons.dark_mode, color: theme.iconTheme.color,),
              ),
            ),

            // button for refreshing data again
            IconButton(
              onPressed: () {
                try{
                  controller.onEnter();
                  Get.snackbar("Success", "Refresh Data Successfully", backgroundColor: Colors.green.withOpacity(0.2), snackPosition: SnackPosition.BOTTOM, showProgressIndicator: true, icon: const Icon(Icons.thumb_up, color: Colors.indigo,));
                }catch (error){
                  Get.snackbar("Error", "Unsuccessful", backgroundColor: Colors.red.withOpacity(0.2), snackPosition: SnackPosition.BOTTOM, icon: const Icon(Icons.error,),);
                }
              },
              icon: Icon(Icons.refresh, color: theme.iconTheme.color,),
            ),
          ],
        ),

        // body
        body: Obx(
          () => controller.isLoaded.value
            ? Container(
              padding: const EdgeInsets.all(12),
              child: FutureBuilder(
                future: controller.currentWeatherData,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(snapshot.hasData){
                    CurrentWeatherData data = snapshot.data;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.selectedPlace.toString(), style: TextStyle(color: theme.primaryColor, letterSpacing: 2,fontWeight: FontWeight.bold, fontSize: 30),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// logo according to weather condition
                              Image.network('http://openweathermap.org/img/wn/${data.weather[0].icon}@2x.png', height: 80, width: 80,),

                              /// main temp of the day
                              RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${data.main.temp}⁰',         // by default it has white color
                                        style: TextStyle(color: theme.primaryColor, fontSize: 35),
                                      ),
                                      TextSpan(
                                        text: '  ${data.weather[0].main}',         // by default it has white color
                                        style: TextStyle(color: theme.primaryColor, fontSize: 15, letterSpacing: 2),
                                      ),
                                    ]
                                ),
                              )
                            ],
                          ),

                          // min & max temp on this day
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(onPressed: null, icon: Icon(Icons.expand_less, color: theme.iconTheme.color,), label: Text('${data.main.tempMax}', style: TextStyle(color: theme.iconTheme.color),),),
                              TextButton.icon(onPressed: null, icon: Icon(Icons.expand_more, color: theme.iconTheme.color,), label: Text('${data.main.tempMin}', style: TextStyle(color: theme.iconTheme.color),),),
                            ],
                          ),

                          /// Information about clouds, humidity & wind speed
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(3, (index) {
                              List<IconData> iconList = [CupertinoIcons.cloud_bolt_rain_fill, CupertinoIcons.waveform_path, CupertinoIcons.wind_snow,];
                              var values = ["${data.clouds.all}", "${data.main.humidity}%", "${data.wind.speed} km/h"];

                              return Column(
                                children: [
                                  const SizedBox(height: 10,),

                                  Icon(iconList[index], size: 50, color: Colors.blueAccent,),

                                  const SizedBox(height: 10,),

                                  Text(values[index], style: TextStyle(color: Colors.grey[600]),)
                                ],
                              );
                            },),
                          ),

                          const SizedBox(height: 10,),
                          const Divider(thickness: 2,),
                          const SizedBox(height: 10,),

                          /// every 3 hours data of the days
                          FutureBuilder(
                            future: controller.hourlyWeatherData,
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if(snapshot.hasData){
                                HourlyWeatherData hourlyData = snapshot.data;
                                return SizedBox(
                                  height: 180,
                                  child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: hourlyData.list.length > 12 ? 12 : hourlyData.list.length,
                                      itemBuilder: (BuildContext context, int index){
                                        var time = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(hourlyData.list[index].dt * 1000));
                                        return Container(
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Colors.deepPurpleAccent,
                                              borderRadius: BorderRadius.circular(12)
                                          ),
                                          child: Column(
                                            children: [
                                              /// time
                                              Text(time, style: const TextStyle(color: Colors.white),),
                                              /// image as situation
                                              Image.network("http://openweathermap.org/img/wn/${hourlyData.list[index].weather[0].icon}@2x.png", height: 80, width: 80,),
                                              /// temperature
                                              Text('${hourlyData.list[index].main.temp}⁰', style: const TextStyle(color: Colors.white),),
                                            ],
                                          ),
                                        );
                                      }
                                  ),
                                );
                              }
                              else{
                                  return const Center(child: CircularProgressIndicator(),);
                              }
                            },
                          ),

                          const SizedBox(height: 10,),
                          const Divider(thickness: 2,),
                          const SizedBox(height: 10,),

                          /// heading for 7 days forecast
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Next 7 days..', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: theme.primaryColor),),
                              TextButton(onPressed: (){}, child: const Text('View All'),),
                            ],
                          ),

                          /// but it is under paid plan
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 7,
                            itemBuilder: (BuildContext context, int index){
                              var day = DateFormat("EEEE").format(DateTime.now().add(Duration(days: index+1),),);

                              return Card(
                                color: theme.cardColor,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(day, style: TextStyle(fontWeight: FontWeight.w500, color: theme.primaryColor),),),

                                      Expanded(
                                        child: TextButton.icon(
                                          onPressed: null,
                                          icon: Image.network("https://static.vecteezy.com/system/resources/previews/028/600/717/original/weather-3d-rendering-icon-illustration-free-png.png", height: 40, width: 40,),
                                          label: Text('34', style: TextStyle(color: theme.primaryColor),),
                                        ),
                                      ),

                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '37℃ / ',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: theme.primaryColor),
                                            ),

                                            TextSpan(
                                              text: '28℃',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.iconTheme.color),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                            },
                          ),

                        ],
                      ),
                    );
                  }
                  else{
                    return const Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
            )
            : const Center(child: CircularProgressIndicator(),),
        ),

      ),
    );
  }
}

