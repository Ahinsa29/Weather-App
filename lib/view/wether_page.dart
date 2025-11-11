import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/service/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // API key and service
  final _weatherService = WeatherService('510db85692f459eaf1aeb8701bca0f81');
  Weather? _weather;

  // For search functionality
  final TextEditingController _cityController = TextEditingController();
  bool _isLoading = false;
  String? error;

  // Fetch weather and forecast: Defaults to current city if no cityName provided
  _fetchWeather({String? cityName}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String finalCityName = cityName ?? await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(finalCityName);
      
      setState(() {
        _weather = weather;
        _isLoading = false;
      
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _isLoading = false;
        error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching weather')));
    }
  }

  // Weather animations (unchanged from your code)
  String _getAnimation(String mainCondition) {
    switch (mainCondition.toLowerCase()) {
      case 'sunny':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/animations/cloud.json';
      case 'thunderstorm':
        return 'assets/animations/thunder.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/animations/rainy.json';
      case 'clear':
        return 'assets/animations/sunny.json';
      default:
        return 'assets/animations/cloud.json'; // Default animation
    }
  }

  @override
  @override
  void initState() {
    super.initState();
    // On start, fetch current city weather
    _fetchWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 35, 36),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 60),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: 'Search for a city ',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (_cityController.text.trim().isNotEmpty) {
                        _fetchWeather(cityName: _cityController.text.trim());
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                      }
                    },
                  ),
                ],
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Search bar for any city
                SizedBox(height: 10),

                // Button to refresh current city weather
                ElevatedButton(
                  onPressed: () => _fetchWeather(), // No param = current city
                  child: Text(
                    'Refresh Current City',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 150),

                // City name (shows current or searched city)
                _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        _weather?.cityName ?? "Loading City..",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),

                // Animation
                Lottie.asset(
                  _getAnimation(_weather?.mainCondition ?? ""),
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                ),

                // Temperature
                Text(
                  '${_weather?.temperature.round()}°C',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Main condition
                Text(
                  _weather?.mainCondition ?? "",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          
          ],
        ),
      ),
    );
  }
}
