import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:color_sequence_game/navigation_bar.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class UserStatisticsPage extends StatefulWidget {
  const UserStatisticsPage({Key? key}) : super(key: key);

  @override
  State<UserStatisticsPage> createState() => _UserStatisticsPageState();
}

class _UserStatisticsPageState extends State<UserStatisticsPage> {
  String _selectedCategory = '';
  late User? _currentUser;
  dynamic _userEmail;
  dynamic _userName;
  dynamic _userAge;

  List<StatisticData> _statisticDataList = [];
  int _selectedIndex = 2;
  // Initializes the state, fetches current user and sets default category
  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _selectedCategory = 'Reaction Time';
  }

  // Fetches the current user and related data
  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _fetchStatisticData(_currentUser!.uid);
      await _fetchUserData(_currentUser!.uid);
    }
  }

  // Fetches user data from Firestore
  Future<void> _fetchUserData(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('userProgress')
        .doc('progress')
        .get();

    if (userSnapshot.exists) {
      setState(() {
        _userEmail = _currentUser!.email;
        _userName = userSnapshot['name'];
        _userAge = userSnapshot['age'];
      });
    }
  }
  // Handles navigation based on selected index from BottomNavigationBar
  void _onItemTapped(int index) {
    // Set the state to update the selectedIndex
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0:
      // Navigate to the home screen
        Navigator.pushNamed(context, '/');
        break;
      case 1:
      // Navigate to the search screen
        Navigator.pushNamed(context, '/begin_game');
        break;
      case 2:
      // Navigate to the profile screen
        Navigator.pushNamed(context, '/user_stats');
        break;
    }
  }

  // Fetches statistical data for the user from Firestore
  Future<void> _fetchStatisticData(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('games')
        .orderBy('timestamp', descending: true)
        .get();

    Map<String, List<double>> averageReactionTimeMap = {};
    Map<String, List<int>> averageMemoryMistakesMap = {};
    Map<String, List<int>> averageAttentionMistakesMap = {};

    querySnapshot.docs.forEach((doc) {
      DateTime timestamp = doc['timestamp'].toDate();
      String hourKey = _formatHour(timestamp);

      double reactionTime = doc['average_reaction_time'];
      int memoryMistakes = doc['mistakes'];
      int attentionMistakes = doc['at_mistakes'];

      averageReactionTimeMap.putIfAbsent(hourKey, () => []).add(reactionTime);
      averageMemoryMistakesMap.putIfAbsent(hourKey, () => []).add(memoryMistakes);
      averageAttentionMistakesMap.putIfAbsent(hourKey, () => []).add(attentionMistakes);
    });

    _statisticDataList = averageReactionTimeMap.entries.map((entry) {
      double averageReactionTime =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      int averageMemoryMistakes =
          averageMemoryMistakesMap[entry.key]!.reduce((a, b) => a + b) ~/
              averageMemoryMistakesMap[entry.key]!.length;
      int averageAttentionMistakes =
          averageAttentionMistakesMap[entry.key]!.reduce((a, b) => a + b) ~/
              averageAttentionMistakesMap[entry.key]!.length;

      DateTime timestamp = DateTime.parse(entry.key);

      return StatisticData(
        averageReactionTime: averageReactionTime,
        averageMemoryMistakes: averageMemoryMistakes,
        averageAttentionMistakes: averageAttentionMistakes,
        timestamp: Timestamp.fromDate(timestamp),
      );
    }).toList();

    setState(() {});
  }
  // Formats the DateTime into a string for hourly keys
  String _formatHour(DateTime timestamp) {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}';
  }

  // Building UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Statistics',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.blue[200], // Lighter background color
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Reaction Time';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'Reaction Time' ? Colors.blue : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        'Reaction Time',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Memory';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'Memory' ? Colors.blue : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        'Memory',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Attention';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'Attention' ? Colors.blue : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        'Attention',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_selectedCategory.isNotEmpty) ...[
              Text(
                '$_selectedCategory Statistics',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Expanded(
                child: _statisticDataList.isNotEmpty
                    ? _buildChart()
                    : Text('No data available'),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildChart() {
    late List<charts.Series<StatisticData, DateTime>> seriesList;
    late String yAxisLabel;

    if (_selectedCategory == 'Reaction Time') {
      seriesList = _buildReactionTimeSeries();
      yAxisLabel = 'Reaction Time';
    } else if (_selectedCategory == 'Memory') {
      seriesList = _buildMemoryMistakesSeries();
      yAxisLabel = 'Memory Mistakes';
    } else if (_selectedCategory == 'Attention') {
      seriesList = _buildAttentionMistakesSeries();
      yAxisLabel = 'Attention Mistakes';
    }

    return charts.TimeSeriesChart(
      seriesList,
      animate: true,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(zeroBound: false),
      ),
      domainAxis: charts.DateTimeAxisSpec(
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(format: 'd', transitionFormat: 'd MMM'),
        ),
      ),
      behaviors: [
        charts.ChartTitle('Date', behaviorPosition: charts.BehaviorPosition.bottom),
        charts.ChartTitle(yAxisLabel, behaviorPosition: charts.BehaviorPosition.start),
      ],
    );
  }

  List<charts.Series<StatisticData, DateTime>> _buildReactionTimeSeries() {
    return [
      charts.Series(
        id: 'Reaction Time',
        data: _statisticDataList,
        domainFn: (StatisticData data, _) => data.timestamp.toDate(),
        measureFn: (StatisticData data, _) => data.averageReactionTime,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];
  }

  List<charts.Series<StatisticData, DateTime>> _buildMemoryMistakesSeries() {
    return [
      charts.Series(
        id: 'Memory Mistakes',
        data: _statisticDataList,
        domainFn: (StatisticData data, _) => data.timestamp.toDate(),
        measureFn: (StatisticData data, _) => data.averageMemoryMistakes.toDouble(),
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      )
    ];
  }

  List<charts.Series<StatisticData, DateTime>> _buildAttentionMistakesSeries() {
    return [
      charts.Series(
        id: 'Attention Mistakes',
        data: _statisticDataList,
        domainFn: (StatisticData data, _) => data.timestamp.toDate(),
        measureFn: (StatisticData data, _) => data.averageAttentionMistakes.toDouble(),
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      )
    ];
  }
}

class StatisticData {
  final double averageReactionTime;
  final int averageMemoryMistakes;
  final int averageAttentionMistakes;
  final Timestamp timestamp;

  StatisticData({
    required this.averageReactionTime,
    required this.averageMemoryMistakes,
    required this.averageAttentionMistakes,
    required this.timestamp,
  });
}
