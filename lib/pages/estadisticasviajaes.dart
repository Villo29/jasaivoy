import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GraphPage(),
    );
  }
}

class GraphPage extends StatefulWidget {
  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> with SingleTickerProviderStateMixin {
  List<FlSpot> historicalSpots = [];
  List<FlSpot> forecastSpots = [];
  List<FlSpot> animatedForecastSpots = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Duración de la animación
    )..addListener(() {
        setState(() {
          int currentCount = (_animationController.value * forecastSpots.length).toInt();
          animatedForecastSpots = forecastSpots.sublist(0, currentCount);
        });
      });
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final historicalResponse = await http.get(Uri.parse('http://35.175.159.211:5000/historical'));
      final forecastResponse = await http.get(Uri.parse('http://35.175.159.211:5000/forecast'));

      if (historicalResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        final historicalData = json.decode(historicalResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss z');

        setState(() {
          historicalSpots = historicalData
              .where((item) => item['date'] != null && item['count'] != null)
              .map<FlSpot>((item) {
            DateTime date = dateFormat.parse(item['date']);
            double count = item['count'].toDouble();
            return FlSpot(date.millisecondsSinceEpoch.toDouble(), count);
          }).toList();

          forecastSpots = forecastData
              .where((item) => item['date'] != null && item['predicted_count'] != null)
              .map<FlSpot>((item) {
            DateTime date = dateFormat.parse(item['date']);
            double predictedCount = item['predicted_count'].toDouble();
            return FlSpot(date.millisecondsSinceEpoch.toDouble(), predictedCount);
          }).toList();

          isLoading = false;
          _animationController.forward(); // Inicia la animación
        });
      } else {
        throw Exception('Error fetching data from API');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Ride Creation Forecast'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 86400000 * 7, // Intervalo de 7 días
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          return Text(
                            DateFormat('yyyy-MM-dd').format(date),
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    drawVerticalLine: true,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  minX: historicalSpots.first.x,
                  maxX: forecastSpots.last.x,
                  minY: 4,
                  maxY: 16,
                  lineBarsData: [
                    // Gráfica histórica (estática)
                    LineChartBarData(
                      spots: historicalSpots,
                      isCurved: false,
                      color: Colors.orange,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Gráfica de predicciones (animada)
                    LineChartBarData(
                      spots: animatedForecastSpots,
                      isCurved: false,
                      color: Colors.red,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                      dashArray: [10, 5],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
