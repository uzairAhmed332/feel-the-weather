import 'dart:async';
import 'package:feel_the_weather_new/services/weather.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utilities/color_loader_3.dart';

class HomeScreenOnlyTTSClean extends StatefulWidget {
  HomeScreenOnlyTTSClean({this.locationWeather});

  final locationWeather;

  @override
  _HomeScreenOnlyTTSCleanState createState() => _HomeScreenOnlyTTSCleanState();
}

class _HomeScreenOnlyTTSCleanState extends State<HomeScreenOnlyTTSClean> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 1;
  double pitch = 1;
  double rate = 0.3;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;

  bool isChrome = false;
  bool _chromeBtnFirstPress = true;

  WeatherModel weather = WeatherModel();

  DateTime date = DateTime.now();

  double? temperature;
  double? temperatureMin;
  double? temperatureMax;
  String? weatherSound;
  String? cityName;
  String? dayName;
  String? currentTime;
  String? weatherCondition;

  String? description;
  String? sunRiseValue;
  String? sunSetValue;
  String? humidityValue;
  var windSpeedValue;

  @override
  void initState() {
    super.initState();

    updateUI(widget.locationWeather);
    initTts();
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        temperatureMin = 0;
        temperatureMax = 0;
        weatherSound = 'Error';
        cityName = '';
        weatherCondition = '';
        description = '';
        sunRiseValue = '';
        sunSetValue = '';
        humidityValue = '';
        windSpeedValue = 0.0;
        return;
      }
      print('weatherAPIData :' + weatherData.toString());

      var temp = weatherData['main']['temp'];
      temperature = temp; //.toInt();
      var tempMin = weatherData['main']['temp_min'];
      temperatureMin = tempMin.toDouble(); //.toInt();
      var tempMax = weatherData['main']['temp_max'];
      temperatureMax = tempMax; //.toInt();
      var condition = weatherData['weather'][0]['id'];
      weatherSound = weather.getWeatherSound(condition);
      cityName = weatherData['name'];
      dayName = DateFormat('EEEE').format(date);
      currentTime = DateFormat("HH:mm").format(DateTime.now());
      weatherCondition = weatherData['weather'][0]['main'];
      description = weatherData['weather'][0]['description'];
      windSpeedValue = weatherData['wind']['speed'];
      var sunRise = weatherData['sys']['sunrise'];
      sunRiseValue = getClockInUtcPlus3Hours(sunRise as int);
      var sunSet = weatherData['sys']['sunset'];
      sunSetValue = getClockInUtcPlus3Hours(sunSet as int);

      var humidity = weatherData['main']['humidity'];
      humidityValue = humidity.toString();
      print('temp: $temperature '
          ' tempMin: $temperatureMin '
          ' tempMax: $temperatureMax  '
          ' weatherSound: $weatherSound '
          ' cityName: $cityName '
          ' dayName: $dayName '
          ' weatherCondition: $weatherCondition '
          ' description: $description'
          ' humidity: $humidityValue'
          ' sunset: $sunSetValue'
          ' sunrise: $sunRiseValue'
          ' windSpeedValue: $windSpeedValue'
          ' currentTime: $currentTime');
    });
  }

  @override
  Widget build(BuildContext context) {
    //Get info from API and put it here!
    String humiditySentence;
    // if(humidityValue == null ) {
    humiditySentence = humidityTTS(int.parse(humidityValue!));
    // }else {
    //   humiditySentence ="90";
    // }
    String descriptionSentence = descriptionTTS(description!);

    //converting windSpeed from m/sec to kilometer per hour by * 3.6
    String windSpeedValueInKmh =
        (windSpeedValue.toDouble() * 3.6).toStringAsFixed(2);

    String windSpeedValueSentence =
        windSpeedValueTTS(windSpeedValue.toDouble() * 3.6);

    final browser = Browser.detectOrNull();
    print(
        'BrowserName:${browser?.browser ?? 'Wrong platform'} ${browser?.version ?? 'Wrong platform'}');
    //Chromium, Chrome, Wrong platform
    if (browser?.browser == "Chromium" || browser?.browser == "Chrome") {
      isChrome = true;
    }

    _newVoiceText =
        'Hey there: Today its '
            '$dayName and time is $currentTime, and your current location is $cityName. Today Sunrise will happen at $sunRiseValue, and '
        'Sunset will happen at $sunSetValue. Now, you will about to hear current WEATHER Forecast of $cityName. The '
        'temperature feels like $temperature DEGREE centigrade, But it can go as low as $temperatureMin, and as high '
        'as $temperatureMax DEGREE centigrade. You could see the $description. $descriptionSentence. Humidity is $humidityValue %, which '
        'is $humiditySentence. Wind speed is $windSpeedValueInKmh kilometer per hour. Which $windSpeedValueSentence. '
        ' BYE bye, Have a NICE day!';

    _speak();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isChrome == true
                  ? Material(
                color: Colors.black,
                child: InkWell(
                  onTap: () {
                    _chromeBtnFirstPress == true ? _myCallback() : null;
                    _chromeBtnFirstPress = false;

                  },
                  // child: Image.asset('/assets/sun_smile.png',
                  //     width: 255.0, height: 300.0),
                  child: ColorLoader3(),
                ),

              )
                  : const Text('The condition is false!'),
              const SizedBox(
                height: 30.0,
              ),
              if(isChrome == true)
              const Text('Click to feel the Weather', style: TextStyle(color: Colors.white,fontSize: 22))
            ],
          ),
        ),
      ),
    );
  }

  void _myCallback() {
    print("clicked1");
    _chromeBtnFirstPress = false;
    setState(() {});

  }

  String humidityTTS(int humidityValue) {
    if (humidityValue > 70) {
      return "TOO MUCH";
    } else if (humidityValue >= 30 && humidityValue >= 50) {
      return "NORMAL";
    } else if (humidityValue < 30) {
      return "Dry";
    }
    return "NORMAL";
  }

  String descriptionTTS(String s) {
    // API data of description:	clear sky, few clouds, scattered clouds, broken clouds, shower rain, rain, thunderstorm, snow, mist
    if (s == "clear sky") {
      return "I hope its as Clear as your future";
    } else if (s == "few clouds") {
      return "cherish those remaining clouds now Before they are Gone too";
    } else if (s == "scattered clouds") {
      return "But not as scattered as your thoughts";
    } else if (s == "broken clouds") {
      return "But HEY, Its fine as long as your Heart is not broken.";
    } else if (s == "shower rain") {
      return "Rain showers are considered to be light rainfall that has a shorter duration than rain";
    } else if (s == "rain") {
      return "I hope you will not forgot your umbrella when going outside";
    } else if (s == "thunderstorm") {
      return "When thunder roars, please go indoors";
    } else if (s == "snow") {
      return "I hope the snow will not prevent you from going out.";
    } else if (s == "mist") {
      return "When driving in mist, PLease reduce your speed and turn on your headlights, Make sure that you can be seen.";
    } else if (s == "overcast clouds") {
      return "$dayName dawned a dreary overcast day.";
    }
    return "NORMAL";
  }

  String windSpeedValueTTS(double windSpeed) {
    print('windspeed is $windSpeed');
    if (windSpeed < 2) {
      return "Feels like very Calm and Gentle air";
    } else if (windSpeed >= 2 && windSpeed <= 5) {
      return "Feels like Light air";
    } else if (windSpeed >= 5 && windSpeed <= 11) {
      return "Feels like Light Breeze";
    } else if (windSpeed >= 11 && windSpeed <= 19) {
      return "Feels like Gentle Breeze";
    } else if (windSpeed >= 19 && windSpeed <= 29) {
      return "Feels like Moderate Breeze ";
    } else if (windSpeed >= 29 && windSpeed <= 39) {
      return "Feels like Fresh Breeze ";
    } else if (windSpeed >= 39 && windSpeed <= 50) {
      return "Feels like Strong Breeze ";
    } else if (windSpeed >= 50 && windSpeed <= 61) {
      return "Feels like Moderate Gale";
    } else if (windSpeed >= 61 && windSpeed <= 74) {
      return "Feels like Fresh Gale";
    } else if (windSpeed >= 74 && windSpeed <= 87) {
      return "Feels like Strong Gale";
    } else if (windSpeed >= 87 && windSpeed <= 101) {
      return "Feels like Whole Gale";
    } else if (windSpeed >= 101 && windSpeed <= 116) {
      return "Feels like Violent storm";
    } else if (windSpeed >= 117) {
      return "Feels like Hurricane";
    }
    return "Feels like wind";
  }

  String getClockInUtcPlus3Hours(int timeSinceEpochInSec) {
    final time = DateTime.fromMillisecondsSinceEpoch(timeSinceEpochInSec * 1000,
            isUtc: true)
        .add(const Duration(hours: 0));
    print('aaaaa: ${time.hour}:${time.second}');
    return '${time.hour}:${time.second}';
  }

//TTS

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print("Engine: " + engine);
    }
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) {
    flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  //Only required when typing text on field!
  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      //  setState(() {
      print("Playing");
      //  ttsState = TtsState.playing;
      //});
    });

    flutterTts.setCompletionHandler(() {
      //setState(() {
      print("Complete");
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      //   ttsState = TtsState.stopped;
      //   });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        //    ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          //    ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          //    ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        //    ttsState = TtsState.stopped;
      });
    });
  }

  _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setLanguage("en-AUen-AU");
    // await flutterTts.setVoice({"name": "en-au-x-aub-network", "locale": "en-AU"});  //Doen not work in WEB so ignore this
    // await flutterTts.setLanguage("en-US");

    flutterTts.getLanguages
      ..then((value) {
        print("Language: " + value.toString());
      });

    // flutterTts.getVoices.then((value) {
    //   print("Voices: " + value.toString());
    // });

    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }
// TTS End
}
