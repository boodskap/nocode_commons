import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

enum TimeSeriesChartStyle { line, area }

class SingleDeviceTimeSeriesChart {
  String deviceId;
  List<String> fields;
  TimeSeriesChartStyle? style = TimeSeriesChartStyle.line;

  SingleDeviceTimeSeriesChart(
      {required this.deviceId, required this.fields, this.style});

  static SingleDeviceTimeSeriesChart? from(Object? object) {
    if (null != object) {
      Map<String, dynamic> attrs = object as Map<String, dynamic>;
      return SingleDeviceTimeSeriesChart(
          deviceId: attrs['deviceId'],
          fields: attrs['fields'],
          style: TimeSeriesChartStyle.values
              .byName(attrs['style'] ?? TimeSeriesChartStyle.line.name));
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {'deviceId': deviceId, 'fields': fields, 'style': style!.name};
  }
}

class SingleDeviceChartWidget extends StatefulWidget {
  final ScreenWidget screenWidget;
  const SingleDeviceChartWidget({super.key, required this.screenWidget});

  @override
  State<SingleDeviceChartWidget> createState() =>
      _SingleDeviceChartWidgetState();
}

class _SingleDeviceChartWidgetState extends BaseState<SingleDeviceChartWidget> {
  late final SingleDeviceTimeSeriesChart _chart;

  @override
  void initState() {
    _chart = SingleDeviceTimeSeriesChart.from(widget.screenWidget.attributes)!;
    super.initState();
  }

  @override
  void setup() async {
    // TODO: implement setup
  }

  Widget _buildLineChart(BuildContext context) {
    return const Placeholder();
  }

  Widget _buildAreaChart(BuildContext context) {
    return const Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    switch (_chart.style!) {
      case TimeSeriesChartStyle.line:
        return _buildLineChart(context);
      case TimeSeriesChartStyle.area:
        return _buildAreaChart(context);
      default:
        return const Placeholder();
    }
  }
}
