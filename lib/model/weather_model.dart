class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final List<Weather>? forecast;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? '',
      temperature: json['main'] != null ? json['main']['temp'].toDouble() : 0.0,
      mainCondition: json['weather'] != null ? json['weather'][0]['main'] : '',
      forecast: null,
    );
  }

  // Factory for combining current and forecast data
  factory Weather.fromCombinedJson(
    Map<String, dynamic> current,
    Map<String, dynamic> forecastJson,
  ) {
    List<Weather> forecastList = [];
    if (forecastJson['daily'] != null) {
      forecastList = (forecastJson['daily'] as List<dynamic>)
          .map(
            (item) => Weather(
              cityName: current['name'] ?? '',
              temperature: item['temp']['day'].toDouble(),
              mainCondition: item['weather'][0]['main'],
            ),
          )
          .toList();
    }
    return Weather(
      cityName: current['name'] ?? '',
      temperature: current['main'] != null
          ? current['main']['temp'].toDouble()
          : 0.0,
      mainCondition: current['weather'] != null
          ? current['weather'][0]['main']
          : '',
      forecast: forecastList,
    );
  }
}
