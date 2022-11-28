import 'dart:io';

import 'package:flutter/services.dart';

import '../sensor_demo_platform_interface.dart';

import 'generated/messages.dart';
import '../sensor_event.dart';
import '../sensors.dart';

/// An implementation of [SensorDemoPlatform] that uses pigeon.
class PigeonSensorDemo extends SensorDemoPlatform {
  /// List of subscriptions to the update event channel.
  final Map<int, EventChannel> _eventChannels = {};

  /// List of subscriptions to the update event channel.
  final Map<int, Stream<SensorEvent>> _sensorStreams = {};

  /// Return the stream associated with the given sensor.
  Stream<SensorEvent>? _getSensorStream(int sensorId) {
    return _sensorStreams[sensorId];
  }

  /// Return the stream associated with the given sensor.
  Future<EventChannel> _getEventChannel(int sensorId, int interval) async {
    EventChannel? eventChannel = _eventChannels[sensorId];
    if (eventChannel == null) {
      // Start event channel on platform
      await Api2Host().startEventChannel(sensorId, interval);
      // Start and store event channel on flutter
      eventChannel = EventChannel("sensors/$sensorId");
      _eventChannels.putIfAbsent(sensorId, () => eventChannel!);
    }
    return eventChannel;
  }

  /// Register a sensor update request.
  @override
  Future<Stream<SensorEvent>> sensorUpdates({required int sensorId, Duration? interval}) async {
    var sensorStream = _getSensorStream(sensorId);
    interval = interval ?? Sensors.SENSOR_DELAY_NORMAL;
    if (sensorStream == null) {
      var intervalAsInt = _transformDurationToInt(interval);
      final eventChannel = await _getEventChannel(sensorId, intervalAsInt);
      sensorStream = eventChannel.receiveBroadcastStream().map((event) {
        return SensorEvent.fromMap(event);
      });
      _sensorStreams.putIfAbsent(sensorId, () => sensorStream!);
    } else {
      await updateSensorInterval(sensorId, interval);
    }
    return sensorStream;
  }

  /// Check if the sensor is available in the device.
  @override
  Future<bool> isSensorAvailable(int sensorId) async => await Api2Host().isSensorAvailable(sensorId);

  /// Updates the interval between updates for an specific sensor.
  @override
  Future<bool> updateSensorInterval(int sensorId, Duration newInterval) async {
    var newIntervalAsInt = _transformDurationToInt(newInterval);
    return await Api2Host().updateSensorInterval(sensorId, newIntervalAsInt);
  }

  /// Transform the delay duration object to an int value for each platform.
  int _transformDurationToInt(Duration delay) {
    return Platform.isAndroid ? delay.inMicroseconds : delay.inSeconds;
  }
}
