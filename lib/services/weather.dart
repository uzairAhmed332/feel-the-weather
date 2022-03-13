
import 'package:feel_the_weather_new/services/location.dart';
import 'package:feel_the_weather_new/services/network.dart';

const apiKey = '92e47afb54bc7791e43c0cd5ad09d00c';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {

  //Called at the start for current location weather
  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    print('getLocationWeather:');
    return weatherData;
  }

  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric');

    var weatherData = await networkHelper.getData();
    print('getCityWeather:');
    return weatherData;
  }



  String getWeatherSound(int condition) {
    if (condition < 300) {
      return 'rain_thunder'; //thunder_rain
    } else if (condition < 400) {
      return 'rain_light';//drizzle: sound: light rain
    } else if (condition == 500) {
      return 'rain_heavy'; //rain_med: sound:  medium_rain
    } else if (condition < 600) {
      return 'rain_heavy';//sound:  heavy_rain
    } else if (condition < 700) {
      return 'snow_walk';  //sound: snow_walk
    } else if (condition < 800) {
      return 'sunny_day'; //fog: sound: sunny
    } else if (condition == 800) {
      return 'sunny_day'; //sun: sound: sunny
    } else if (condition <= 804) {
      return 'sunny_day'; //cloud: sound: sunny
    } else {
      return 'thermometer';
    }
  }
}
