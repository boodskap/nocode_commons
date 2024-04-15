import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:timeago/timeago.dart' as timeago;
import 'package:twinned_widgets/sensor_widget.dart';

typedef OnAssetDoubleTapped = Future<void> Function(twin.DeviceData dd);
typedef OnAssetAnalyticsTapped = Future<void> Function(twin.DeviceData dd);

class DefaultAssetView extends StatefulWidget {
  final twin.Twinned twinned;
  final String authToken;
  final String assetId;
  final OnAssetDoubleTapped onAssetDoubleTapped;
  final OnAssetAnalyticsTapped onAssetAnalyticsTapped;
  const DefaultAssetView(
      {super.key,
      required this.twinned,
      required this.authToken,
      required this.assetId,
      required this.onAssetDoubleTapped,
      required this.onAssetAnalyticsTapped});

  @override
  State<DefaultAssetView> createState() => _DefaultAssetViewState();
}

class _DefaultAssetViewState extends BaseState<DefaultAssetView> {
  final List<Widget> _alarms = [];
  final List<Widget> _displays = [];
  final List<Widget> _controls = [];
  final List<Widget> _fields = [];
  final List<twin.DeviceData> _data = [];
  //Widget image = const Icon(Icons.image);
  String title = '?';
  String info = '?';
  String reported = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                divider(),
                Text(
                  info,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (_alarms.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: _alarms,
                  ),
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  if (_controls.isNotEmpty)
                    Expanded(
                        child: Column(
                      children: [
                        //Expanded(child: Center(child: image)),
                        Expanded(
                          child: SingleChildScrollView(
                              child: Wrap(
                            spacing: 8,
                            children: _controls,
                          )),
                        ),
                      ],
                    )),
                  if (_fields.isNotEmpty)
                    Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          child: Center(
                            child: Wrap(
                              spacing: 5,
                              children: _fields,
                            ),
                          ),
                        )),
                  divider(horizontal: true)
                ],
              ),
            ),
            divider(),
            if (_displays.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: _displays,
                  ),
                ),
              ),
            divider(),
            if (reported.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    reported,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    _alarms.clear();
    _displays.clear();
    _controls.clear();
    _fields.clear();
    _data.clear();

    refresh();

    await execute(() async {
      var res = await widget.twinned
          .getAsset(apikey: widget.authToken, assetId: widget.assetId);
      if (validateResponse(res)) {
        twin.Asset asset = res.body!.entity!;
        title = asset.name;
        //String imageId = UserSession().getSelectImageId(asset.selectedImage, asset.images);
        //image = UserSession().getImage(asset.domainKey, imageId);

        var dRes = await widget.twinned.searchRecentDeviceData(
            apikey: widget.authToken,
            assetId: widget.assetId,
            body:
                const twin.FilterSearchReq(search: '*', page: 0, size: 10000));

        if (validateResponse(dRes)) {
          _data.addAll(dRes.body!.values!);
        }
      }
      int lastReported = 0;
      Map<String, twin.DeviceModel> models = {};

      for (twin.DeviceData dd in _data) {
        if (models.containsKey(dd.modelId)) continue;
        var res = await widget.twinned
            .getDeviceModel(apikey: widget.authToken, modelId: dd.modelId);
        if (validateResponse(res)) {
          models[dd.modelId] = res.body!.entity!;
        }
      }
      int totalFields = 0;
      for (twin.DeviceModel dm in models.values) {
        totalFields += NoCodeUtils.getSortedFields(dm).length;
      }

      double cardWidth = 220;
      double cardHeight = 220;

      if (totalFields > 2) {
        cardWidth = 140;
        cardHeight = 140;
      } else if (totalFields > 1) {
        cardWidth = 170;
        cardHeight = 170;
      }

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
          late Widget widget;

          if (type == SensorWidgetType.none) {
            if (icon.isEmpty) {
              widget = const Icon(Icons.device_unknown_sharp);
            } else {
              widget = SizedBox(
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
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          widget,
                        ],
                      )),
                ),
              ));
            });
          } else {
            var parameter = NoCodeUtils.getParameter(field, deviceModel);
            widget = SensorWidget(
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
                            padding: const EdgeInsets.all(8.0),
                            child: widget,
                          )))));
            });
          }
        }
      }

      if (_data.isNotEmpty) {
        twin.DeviceData dd = _data.first;
        info = '${dd.premise} -> ${dd.facility} -> ${dd.floor}';
      }

      if (lastReported > 0) {
        var dt = DateTime.fromMillisecondsSinceEpoch(lastReported);
        reported = 'reported ${timeago.format(dt, locale: 'en')}';
      } else {
        reported = '';
      }

      refresh();
    });
    loading = false;
  }

  @override
  void setup() {
    load();
  }
}
