library nocode_commons;

import 'package:flutter/material.dart';


Future main() async {
  runApp(const MaterialApp(home: MyApp()));
}

/// For Bar Chart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Placeholder(),
          // BarChartWidget(
          //   xAxis: [1705708800000],
          //   yAxis: [
          //     [8, 8, 8]
          //   ],
          //   colors: [Colors.red, Colors.green, Colors.blue],
          //   dateFormat: 'yyyy/MM/dd HH:mm:ss',
          // )
        ],
      ),
    );
  }
}
