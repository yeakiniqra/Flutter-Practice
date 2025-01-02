import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // To parse JSON responses
import 'package:weather/secrets.dart'; // Contains your OpenWeather API key

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Variables to store weather data
  String cityName = 'Dhaka';
  String currentWeatherDescription = 'Loading...';
  String currentTemperature = 'Loading...';
  String currentIcon = '01d'; // Default weather icon
  int humidity = 0;
  double windSpeed = 0.0;
  int pressure = 0;
  List<Map<String, dynamic>> hourlyForecast = [];
  List<Map<String, dynamic>> weeklyForecast = [];

  // Fetch weather data
  Future<void> fetchWeatherData() async {
    final String apiKey =
        openWeatherAPIKey; // Use your API key from secrets.dart
    final String currentWeatherUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=Dhaka,BD&appid=$apiKey&units=metric';
    final String forecastUrl =
        'https://api.openweathermap.org/data/2.5/forecast?q=Dhaka,BD&appid=$apiKey&units=metric';

    try {
      final currentWeatherResponse =
          await http.get(Uri.parse(currentWeatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (currentWeatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = jsonDecode(currentWeatherResponse.body);
        final forecastData = jsonDecode(forecastResponse.body);

        setState(() {
          cityName = currentData['name'];
          currentWeatherDescription = currentData['weather'][0]['description'];
          currentTemperature = currentData['main']['temp'].toString();
          currentIcon = currentData['weather'][0]['icon'];
          humidity = currentData['main']['humidity'];
          windSpeed = currentData['wind']['speed'];
          pressure = currentData['main']['pressure'];

          hourlyForecast = (forecastData['list'] as List)
              .take(8)
              .map((item) => {
                    'time': item['dt_txt'],
                    'temp': item['main']['temp'],
                    'icon': item['weather'][0]['icon']
                  })
              .toList();

          weeklyForecast = (forecastData['list'] as List)
              .where((item) => item['dt_txt'].contains('12:00:00'))
              .take(7)
              .map((item) => {
                    'date': item['dt_txt'].split(' ')[0],
                    'temp': item['main']['temp'],
                    'icon': item['weather'][0]['icon'],
                    'description': item['weather'][0]['description'],
                  })
              .toList();
        });
      } else {
        setState(() {
          currentWeatherDescription = 'Error fetching data';
          currentTemperature = 'N/A';
        });
      }
    } catch (e) {
      setState(() {
        currentWeatherDescription = 'Error: $e';
        currentTemperature = 'N/A';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData(); // Fetch weather data on app launch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: fetchWeatherData, // Refresh weather data
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder(
                duration: const Duration(seconds: 1),
                tween: Tween<double>(begin: 0.9, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Card(
                  elevation: 5,
                  color: Colors.deepPurple.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          currentWeatherDescription,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '$currentTemperature°C',
                          style: const TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 134, 171, 206),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20.0),
              // Hourly Forecast
              const Text(
                'Hourly Forecast',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 120.0,
                child: hourlyForecast.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyForecast.length,
                        itemBuilder: (context, index) {
                          final forecast = hourlyForecast[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                Text(forecast['time'].split(' ')[1]),
                                const SizedBox(height: 8.0),
                                Image.network(
                                  'https://openweathermap.org/img/wn/${forecast['icon']}@2x.png',
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(height: 8.0),
                                Text('${forecast['temp']}°C'),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20.0),
              // Additional Weather Information
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: Colors.blue,
                        size: 32.0,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Humidity',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$humidity%',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.air,
                        color: Colors.teal,
                        size: 32.0,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Wind Speed',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$windSpeed m/s',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.thermostat,
                        color: Colors.redAccent,
                        size: 32.0,
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Pressure',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '$pressure hPa',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
