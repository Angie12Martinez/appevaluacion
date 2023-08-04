import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

void main() {
  initializeDateFormatting('es'); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AmbientMode(
      child: const HomeScreen(title: 'APP EVALUACIÓN'),
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Wear Hello',
          theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: mode == WearMode.active
                ? const ColorScheme.dark(
                    primary: Color.fromARGB(255, 13, 13, 13),
                  )
                : const ColorScheme.dark(
                    primary: Color.fromARGB(179, 6, 6, 6),
                    onBackground: Color.fromARGB(168, 9, 4, 59),
                    onSurface: Color.fromARGB(184, 27, 1, 58),
                  ),
          ),
          home: child,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer timer;
  String formattedDateTime = '';
  String formattedDate = '';
  WeatherFactory weatherFactory = WeatherFactory(
      "ca58d3e5edff31e7c39345a5d0048dea", 
      language: Language.SPANISH);
  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    updateDateTime();
    getCurrentWeather();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      updateDateTime();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void updateDateTime() {
  // Establecer una fecha y hora específica.
  final DateTime specificDateTime = DateTime(2023, 7, 24, 22, 5, 0);
  final DateFormat dayFormatter = DateFormat('dd', 'es');
  final DateFormat monthFormatter = DateFormat('MMMM', 'es');
  final DateFormat yearFormatter = DateFormat('yyyy', 'es');

  setState(() {
    formattedDateTime = DateFormat.Hm().format(specificDateTime);
    formattedDate =
        '${dayFormatter.format(specificDateTime)} de ${monthFormatter.format(specificDateTime)} de ${yearFormatter.format(specificDateTime)}';
  });
}
  Future<void> getCurrentWeather() async {
  Weather? weather = await weatherFactory.currentWeatherByLocation(34.0522, -118.2437); // Coordenadas de Los Ángeles
  setState(() {
    currentWeather = weather;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientMode(
        builder: (BuildContext context, dynamic mode, Widget? child) {
          final isAmbientMode = mode == WearMode.ambient;
          const textColor = Color.fromARGB(255, 52, 39, 241);
          final backgroundColor = isAmbientMode
              ? Color.fromARGB(255, 12, 12, 12)
              : Color.fromARGB(255, 252, 249, 249);
          final cardColor = isAmbientMode
              ? Color.fromARGB(255, 8, 8, 8)
              : Color.fromARGB(255, 247, 244, 244);
          final colorHora = isAmbientMode
              ? Color.fromARGB(255, 67, 196, 228)
              : const Color.fromARGB(255, 84, 112, 133);
          final colorClima = isAmbientMode
              ? Color.fromARGB(255, 246, 248, 250)
              : Color.fromARGB(255, 6, 7, 7);
          final colorIcono = isAmbientMode
              ? Color.fromARGB(255, 255, 253, 253)
              : const Color.fromARGB(255, 30, 144, 255);
          final colorTipoClima = isAmbientMode
              ? Color.fromARGB(255, 77, 197, 218)
              : Color.fromARGB(255, 64, 12, 148);

          return Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const SizedBox(height: 10),
                  Text(
                    formattedDateTime,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorHora,
                    ),
                  ),
                  Container(
                    width: 800,
                    height: 130,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentWeather != null)
                            Icon(
                              getWeatherIcon(
                                  currentWeather!.weatherDescription!),
                              size: 30,
                              color: colorIcono,
                            ),
                          const SizedBox(height: 7),
                          if (currentWeather != null)
                            Text(
                              "${currentWeather!.temperature?.celsius?.toStringAsFixed(1)}°C",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colorClima,
                              ),
                            ),
                          const SizedBox(height: 5),
                          if (currentWeather != null)
                            Text(
                              currentWeather!.weatherDescription!,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorTipoClima,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains('lluvia')) {
      return WeatherIcons.rain;
    } else if (weatherDescription.contains('nublado')) {
      return WeatherIcons.cloudy;
    } else if (weatherDescription.contains('soleado') ||
        weatherDescription.contains('despejado')) {
      return WeatherIcons.day_sunny;
    } else if (weatherDescription.contains('nieve')) {
      return WeatherIcons.snow;
    } else if (weatherDescription.contains('tormenta')) {
      return WeatherIcons.thunderstorm;
    } else if (weatherDescription.contains('niebla')) {
      return WeatherIcons.fog;
    } else {
      return WeatherIcons.cloudy;
    }
  }
}
