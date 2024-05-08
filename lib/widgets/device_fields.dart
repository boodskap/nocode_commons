import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:nocode_commons/sensor_widget.dart';

class DeviceFields extends StatefulWidget {
  final twin.Device device;
  final twin.Twinned twinned;
  final String authToken;
  final TextStyle titleTextStyle;
  final TextStyle infoTextStyle;
  final TextStyle widgetTextStyle;

  const DeviceFields({
    super.key,
    required this.device,
    required this.twinned,
    required this.authToken,
    this.titleTextStyle =
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    this.infoTextStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    this.widgetTextStyle =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  });

  @override
  State<DeviceFields> createState() => _DeviceFieldsState();
}

class _DeviceFieldsState extends BaseState<DeviceFields> {
  final List<Widget> _fields = [];
  final List<twin.DeviceData> _data = [];

  @override
  Widget build(BuildContext context) {
    if (_fields.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8.0,
      children: _fields,
    );
  }

  void _load() async {
    if (loading) return;
    loading = true;

    _fields.clear();
    _data.clear();

    await execute(() async {
      int lastReported = 0;
      Map<String, twin.DeviceModel> models = {};

      var ddRes = await widget.twinned.getDeviceData(
          apikey: widget.authToken,
          deviceId: widget.device.id,
          isHardwareDevice: false);

      if (validateResponse(ddRes)) {
        _data.add(ddRes.body!.data!);
      }

      for (twin.DeviceData dd in _data) {
        if (models.containsKey(dd.modelId)) continue;
        var res = await widget.twinned
            .getDeviceModel(apikey: widget.authToken, modelId: dd.modelId);
        if (validateResponse(res)) {
          models[dd.modelId] = res.body!.entity!;
        }
      }

      double cardWidth = 130;
      double cardHeight = 130;

      for (twin.DeviceData dd in _data) {
        if (lastReported < dd.updatedStamp) {
          lastReported = dd.updatedStamp;
        }
        twin.DeviceModel deviceModel = models[dd.modelId]!;
        var fields = NoCodeUtils.getSortedFields(deviceModel);

        for (String field in fields) {
          String icon = NoCodeUtils.getParameterIcon(field, deviceModel);
          String unit = NoCodeUtils.getParameterUnit(field, deviceModel);
          String label = NoCodeUtils.getParameterLabel(field, deviceModel);
          SensorWidgetType type =
              NoCodeUtils.getSensorWidgetType(field, deviceModel);
          dynamic value = NoCodeUtils.getParameterValue(field, dd);
          late Widget sensorWidget;

          if (type == SensorWidgetType.none) {
            if (icon.isEmpty) {
              sensorWidget = const Icon(Icons.device_unknown_sharp);
            } else {
              sensorWidget = SizedBox(
                  width: 45, child: UserSession().getImage(dd.domainKey, icon));
            }

            refresh(sync: () {
              _fields.add(SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Card(
                  elevation: 5,
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$label : $value $unit',
                            style: widget.widgetTextStyle,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          sensorWidget,
                        ],
                      )),
                ),
              ));
            });
          } else {
            var parameter = NoCodeUtils.getParameter(field, deviceModel);
            sensorWidget = SensorWidget(
              parameter: parameter!,
              deviceData: dd,
              tiny: false,
              deviceModel: deviceModel,
            );

            refresh(sync: () {
              _fields.add(SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Card(
                      elevation: 5,
                      child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: sensorWidget,
                          )))));
            });
          }
        }
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
