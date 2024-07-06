/*
- Implement a search bar where users can enter a city name
- Add a button to trigger the weather search
- Display a loading indicator while fetching data
 */



import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:weather_condition/Controllers/weather_controller.dart';
import 'package:weather_condition/Views/WeatherDetailsScreen.dart';

class HomeScreen extends StatelessWidget {

  WeatherController controller = Get.put(WeatherController());

  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // app bar
      appBar: AppBar(
        backgroundColor: Get.theme.cardColor,
        title: Text('Weather Info', style: TextStyle(color: Get.theme.primaryColor,),),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60,),
            /// button for last serach data
            ElevatedButton(
              onPressed: (){
                controller.isLoaded = false.obs;
                controller.onEnter();
                controller.isLoaded = true.obs;
                Get.to(() => const WeatherDetailsScreen());
              },
              child: const Text("Last Searched Data", style: TextStyle(color: Colors.red,),),
            ),

            const SizedBox(height: 20,),

            // heading
            Center(
              child: Text("Checked Weather information by search place", style: TextStyle(color: Get.theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18,), textAlign: TextAlign.center,),
            ),
            const SizedBox(height: 20,),

            /// textField for search place
            TextFormField(
              controller: controller.nameTextEditingController,
              // style: TextStyle(color: Get.theme.primaryColor),
              decoration: InputDecoration(
                hintText: 'Search place...',
                fillColor: Get.theme.inputDecorationTheme.fillColor,
                filled: true,
              ),
            ),

            /// ListTile for the suggested area
            Obx(
              ()=> Expanded(
                child: ListView.builder(
                  itemCount: controller.placesList.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      onTap: ()async{
                        List<Location> locations = await locationFromAddress(controller.placesList[index]);
                        // for debugging
                        debugPrint(locations.last.latitude.toString());
                        debugPrint(locations.last.longitude.toString());
                        // save value in controller to see the reflected changes
                        controller.latitude.value = locations.last.latitude;
                        controller.longitude.value = locations.last.longitude;
                        // store selected place
                        controller.selectedPlace.value = controller.placesList[index];
                        controller.onEnter();
                        controller.isLoaded = true.obs;
                        // navigate to the main screen
                        Get.to(() => const WeatherDetailsScreen());

                        // Save data
                        controller.storage.write('latitude', controller.latitude.value);
                        controller.storage.write('longitude', controller.longitude.value);
                        controller.storage.write('selectedPlace', controller.selectedPlace.value);
                      },
                      title: Text(controller.placesList[index], style: TextStyle(color: Get.theme.primaryColor,),),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
