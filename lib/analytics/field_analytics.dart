import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/analytics/chart_objects.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class DeviceFieldAnalytics extends StatefulWidget {
  final String field;
  final twin.DeviceData deviceData;
  final twin.DeviceModel deviceModel;
  final twin.Twinned twinned;
  final String apiKey;
  final int pageSize;

  const DeviceFieldAnalytics({
    super.key,
    required this.field,
    required this.deviceData,
    required this.deviceModel,
    required this.twinned,
    required this.apiKey,
    this.pageSize = 10000,
  });

  @override
  State<DeviceFieldAnalytics> createState() => _DeviceFieldAnalyticsState();
}

class _DeviceFieldAnalyticsState extends BaseState<DeviceFieldAnalytics> {
  ChartType chartType = ChartType.none;
  late final String label;
  late final String unit;
  final List<TimeSeriesData> _chartData = [];
  final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
    enableDoubleTapZooming: true,
    enableMouseWheelZooming: true,
    enablePanning: true,
    enablePinching: true,
    enableSelectionZooming: true,
    zoomMode: ZoomMode.x,
  );
  twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter? filter =
      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.recent;
  int? beginStamp;
  int? endStamp;

  @override
  void initState() {
    label = NoCodeUtils.getParameterLabel(widget.field, widget.deviceModel);
    unit = NoCodeUtils.getParameterUnit(widget.field, widget.deviceModel);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: 'Line Chart',
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      chartType = ChartType.none;
                    });
                  },
                  icon: const Icon(Icons.line_axis)),
            ),
            Tooltip(
              message: 'Area Chart',
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      chartType = ChartType.area;
                    });
                  },
                  icon: const Icon(Icons.area_chart)),
            ),
            Tooltip(
              message: 'Curved Line Chart',
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      chartType = ChartType.spline;
                    });
                  },
                  icon: const Icon(Icons.call_split)),
            ),
            Tooltip(
              message: 'Scattered Chart',
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      chartType = ChartType.scatter;
                    });
                  },
                  icon: const Icon(Icons.scatter_plot_outlined)),
            ),
            divider(horizontal: true),
            PopupMenuButton<
                twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
              initialValue: filter,
              icon: const Icon(Icons.filter_alt_rounded),
              tooltip: 'Show Filters',
              elevation: 10,
              itemBuilder: (context) {
                return <PopupMenuEntry<
                    twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>>[
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin
                        .DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.recent,
                    child: Text('Recent'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin
                        .DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.today,
                    child: Text('Today'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .yesterday,
                    child: Text('Yesterday'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .thisweek,
                    child: Text('This Week'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .lastweek,
                    child: Text('Last Week'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .thismonth,
                    child: Text('This Month'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .lastmonth,
                    child: Text('Last Month'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .thisquarter,
                    child: Text('This Quarter'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .thisyear,
                    child: Text('This Year'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter
                        .lastyear,
                    child: Text('Last Year'),
                  ),
                  const PopupMenuItem<
                      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter>(
                    value: twin
                        .DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.range,
                    child: Text('Date Range'),
                  ),
                ];
              },
              onSelected:
                  (twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter value) {
                setState(() {
                  filter = value;
                });
                applyFilter(value);
              },
            ),
          ],
        ),
        Expanded(
          child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                title: const AxisTitle(
                  text: 'Time',
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                dateFormat: DateFormat('MM/dd HH:mm:ss'),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(
                    text: '$label ($unit)',
                    textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              zoomPanBehavior: zoomPanBehavior,
              tooltipBehavior: tooltipBehavior(),
              series: <CartesianSeries>[
                if (chartType == ChartType.area) // Renders line chart
                  AreaSeries<TimeSeriesData, DateTime>(
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataSource: _chartData,
                      xValueMapper: (TimeSeriesData sales, _) => sales.dateTime,
                      yValueMapper: (TimeSeriesData sales, _) => sales.value)
                else if (chartType == ChartType.spline) // Renders line chart
                  SplineSeries<TimeSeriesData, DateTime>(
                      markerSettings: const MarkerSettings(isVisible: true),
                      splineType: SplineType.cardinal,
                      //cardinalSplineTension: 0.05,
                      dataSource: _chartData,
                      xValueMapper: (TimeSeriesData sales, _) => sales.dateTime,
                      yValueMapper: (TimeSeriesData sales, _) => sales.value)
                else if (chartType == ChartType.scatter) // Renders line chart
                  ScatterSeries<TimeSeriesData, DateTime>(
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataSource: _chartData,
                      xValueMapper: (TimeSeriesData sales, _) => sales.dateTime,
                      yValueMapper: (TimeSeriesData sales, _) => sales.value)
                else // Renders line chart
                  LineSeries<TimeSeriesData, DateTime>(
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataSource: _chartData,
                      xValueMapper: (TimeSeriesData sales, _) => sales.dateTime,
                      yValueMapper: (TimeSeriesData sales, _) => sales.value)
              ]),
        ),
      ],
    );
  }

  Future applyFilter(
      twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter? filter) async {
    this.filter = filter;
    beginStamp = null;
    endStamp = null;
    DateTimeRange? picked;

    if (filter == twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.range) {
      picked = await showDateRangePicker(
          context: context,
          currentDate: DateTime.now(),
          firstDate: DateTime(DateTime.now().month - 1),
          lastDate: DateTime.now(),
          saveText: 'Apply',
          initialDateRange: DateTimeRange(
            start: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day - 7),
            end: DateTime.now(),
          ),
          builder: (context, child) {
            return Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 800.0,
                  ),
                  child: child,
                )
              ],
            );
          });

      if (null == picked) return;
    }

    if (null != picked) {
      beginStamp = picked.start.millisecondsSinceEpoch;
      endStamp = picked.end.millisecondsSinceEpoch;
    }

    debugPrint('begin: $beginStamp, end: $endStamp');

    await load();
  }

  Future load() async {
    if (loading) return false;

    loading = true;
    _chartData.clear();
    List<TimeSeriesData> chartData = [];
    bool isRecent = (null == filter ||
        filter == twin.DeviceDataSeriesDeviceIdFieldPageSizeGetFilter.recent);

    await execute(() async {
      var res = await widget.twinned.getDeviceTimeSeries(
          tz: DateTime.now().timeZoneName,
          filter: filter,
          apikey: widget.apiKey,
          deviceId: widget.deviceData.deviceId,
          field: widget.field,
          beginStamp: beginStamp,
          endStamp: endStamp,
          page: 0,
          size: isRecent ? 1000 : widget.pageSize);

      if (validateResponse(res, shouldAlert: false)) {
        for (var value in res.body!.values!) {
          if (null == value.data) continue;
          Map<String, dynamic> fValues = value.data as Map<String, dynamic>;
          chartData.add(TimeSeriesData(
              millis: value.updatedStamp, value: fValues[widget.field] ?? 0.0));
        }
      }
    });

    _chartData.addAll(chartData);

    refresh();
    loading = false;
  }

  @override
  void setup() {
    load();
  }

  TooltipBehavior tooltipBehavior() {
    return TooltipBehavior(
        enable: true,
        shouldAlwaysShow: true,
        builder: (data, point, series, pointIndex, seriesIndex) {
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              '${data.value} ($unit) - ${data.dateTime}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        });
  }
}
