import 'dart:collection';

import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/timestamp.dart';
import 'package:sensor_demo/sensor_data.dart';
import 'package:sensor_demo/sensor_event.dart';

class BufferManager {
  BufferManager._privateConstructor() {
    openDB();
  }
  static final BufferManager _instance = BufferManager._privateConstructor();

  final HashMap _buffers = HashMap<int, List<SensorData>>();
  late final Database db;
  late final StoreRef store;
  bool init = false;

  factory BufferManager() {
    return _instance;
  }

  void addBuffer(int id) {
    if (!_buffers.containsKey(id)) {
      _buffers[id] = <SensorData>[];
    }
  }

  void openDB() async {
// get the application documents directory
    var dir = await getApplicationDocumentsDirectory();
// make sure it exists
    await dir.create(recursive: true);
// build the database path
    var dbPath = join(dir.path, 'my_database.db');
// open the database
    db = await databaseFactoryIo.openDatabase(dbPath);
    store = intMapStoreFactory.store('product');
    init = true;
  }

  void fillBuffer(int id, SensorData data) {
    if (_buffers.containsKey(id)) {
      List<SensorData> list = _buffers[id];
      list.add(data);
      writeToDatabase(data);
      print(data.time.toIso8601String());
    }
  }

  SensorData latestData(int id) {
    if (_buffers.containsKey(id)) {
      List<SensorData> list = _buffers[id];
      return list.last;
    }
    return SensorData(0, 0, 0);
  }

  SensorData medianAllData(int id) {
    if (_buffers.containsKey(id)) {
      List<SensorData> tmpSensorList = <SensorData>[];
      List<SensorData> list = _buffers[id];
      tmpSensorList.addAll(list);

      double medx = 0;
      double medy = 0;
      double medz = 0;
      for (var element in tmpSensorList) {
        medx += element.x;
        medy += element.y;
        medz += element.z;
      }
      int max = tmpSensorList.length;
      return SensorData(medx / max, medy / max, medz / max);
    }
    return SensorData(0, 0, 0);
  }

  void writeToDatabase(SensorData data) async {
    store.add(db, {"x": data.x, "y": data.y, "z": data.z, "time": data.time});
  }

  Future<List<SensorEvent>> readFromDatabase() async {
    var finder = Finder(
        filter: Filter.lessThan('time', Timestamp.now()),
        sortOrders: [SortOrder('time')]);
    var records = await store.find(db, finder: finder);
    return records
        .map((record) =>
            SensorEvent.fromMap(record.value as Map<dynamic, dynamic>))
        .toList(growable: false);
  }

  bool isDatabaseReady() {
    return init;
  }
}
