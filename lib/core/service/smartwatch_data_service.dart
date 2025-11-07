import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../constants/ble_uuids.dart';
import '../models/health_data.dart';
import 'bluetooth_service.dart' as bt;

/// Абстрактный интерфейс для получения данных от умных часов
abstract interface class SmartwatchDataService {
  /// Подписаться на данные о сердечном ритме
  Stream<HeartRateData> subscribeToHeartRate(String deviceId);

  /// Получить текущий уровень батареи
  Future<BatteryData?> getBatteryLevel(String deviceId);

  /// Подписаться на данные о батарее
  Stream<BatteryData> subscribeToBattery(String deviceId);

  /// Получить данные о шагах
  Future<StepsData?> getSteps(String deviceId);

  /// Получить данные о температуре тела
  Future<BodyTemperatureData?> getBodyTemperature(String deviceId);

  /// Получить данные о кислороде в крови (SpO2)
  Future<OxygenSaturationData?> getOxygenSaturation(String deviceId);

  /// Получить информацию об устройстве
  Future<DeviceInfo?> getDeviceInfo(String deviceId);

  /// Отписаться от всех уведомлений для устройства
  Future<void> unsubscribeAll(String deviceId);

  /// Освободить ресурсы
  Future<void> dispose();
}

/// Информация об устройстве
class DeviceInfo {
  final String? manufacturer;
  final String? modelNumber;
  final String? serialNumber;
  final String? hardwareRevision;
  final String? firmwareRevision;
  final String? softwareRevision;

  const DeviceInfo({
    this.manufacturer,
    this.modelNumber,
    this.serialNumber,
    this.hardwareRevision,
    this.firmwareRevision,
    this.softwareRevision,
  });

  @override
  String toString() =>
      'DeviceInfo(manufacturer: $manufacturer, model: $modelNumber)';
}

/// Реализация сервиса для получения данных от умных часов
class SmartwatchDataServiceImpl implements SmartwatchDataService {
  final bt.BluetoothService _bluetoothService;
  final Map<String, List<StreamSubscription>> _subscriptions = {};
  final Map<String, StreamController<HeartRateData>> _heartRateControllers = {};
  final Map<String, StreamController<BatteryData>> _batteryControllers = {};

  SmartwatchDataServiceImpl(this._bluetoothService);

  @override
  Stream<HeartRateData> subscribeToHeartRate(String deviceId) {
    // Создаем контроллер, если его еще нет
    if (!_heartRateControllers.containsKey(deviceId)) {
      _heartRateControllers[deviceId] =
          StreamController<HeartRateData>.broadcast();
      _subscribeToHeartRateCharacteristic(deviceId);
    }

    return _heartRateControllers[deviceId]!.stream;
  }

  Future<void> _subscribeToHeartRateCharacteristic(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) {
        throw Exception('Устройство не найдено');
      }

      print('🔍 Discovering services for device: $deviceId');

      // Ищем сервис Heart Rate
      final services = await device.discoverServices();

      // ДИАГНОСТИКА: Выводим все доступные сервисы
      print('📋 Available services on device:');
      for (var service in services) {
        print('  Service: ${service.uuid}');
        for (var char in service.characteristics) {
          print('    Characteristic: ${char.uuid}');
          print(
            '      Properties: read=${char.properties.read}, write=${char.properties.write}, notify=${char.properties.notify}',
          );
        }
      }
      final heartRateService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            BleUuids.heartRate.toLowerCase(),
        orElse: () => throw Exception(
          'Heart Rate сервис не найден. Возможно, это устройство использует проприетарный протокол (например, Amazfit/Huami).',
        ),
      );

      // Ищем характеристику Heart Rate Measurement
      final characteristic = heartRateService.characteristics.firstWhere(
        (char) =>
            char.uuid.toString().toLowerCase() ==
            BleUuids.heartRateMeasurement.toLowerCase(),
        orElse: () => throw Exception('Heart Rate Measurement не найдена'),
      );

      // Подписываемся на уведомления
      await characteristic.setNotifyValue(true);

      final subscription = characteristic.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final heartRateData = _parseHeartRateData(value);
          _heartRateControllers[deviceId]?.add(heartRateData);
        }
      });

      _addSubscription(deviceId, subscription);
    } catch (e) {
      print(e);
      print('Ошибка при подписке на Heart Rate: $e');
      // rethrow;
    }
  }

  HeartRateData _parseHeartRateData(List<int> data) {
    // Парсинг согласно спецификации GATT Heart Rate Service
    // Флаги находятся в первом байте
    final flags = data[0];
    final isHeartRateValueUint16 = (flags & 0x01) != 0;

    int heartRate;
    int offset;

    if (isHeartRateValueUint16) {
      // 16-битное значение
      heartRate = data[1] | (data[2] << 8);
      offset = 3;
    } else {
      // 8-битное значение
      heartRate = data[1];
      offset = 2;
    }

    // Проверяем наличие Energy Expended
    int? energyExpended;
    if ((flags & 0x08) != 0 && data.length >= offset + 2) {
      energyExpended = data[offset] | (data[offset + 1] << 8);
      offset += 2;
    }

    // Проверяем наличие RR intervals
    List<int>? rrIntervals;
    if ((flags & 0x10) != 0 && data.length >= offset + 2) {
      rrIntervals = [];
      for (int i = offset; i < data.length; i += 2) {
        if (i + 1 < data.length) {
          final rrInterval = data[i] | (data[i + 1] << 8);
          rrIntervals.add(rrInterval);
        }
      }
    }

    return HeartRateData(
      bpm: heartRate,
      timestamp: DateTime.now(),
      energyExpended: energyExpended,
      rrIntervals: rrIntervals,
    );
  }

  @override
  Future<BatteryData?> getBatteryLevel(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) return null;

      print('🔋 Attempting to read battery level...');
      final services = await device.discoverServices();

      final batteryService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            BleUuids.battery.toLowerCase(),
        orElse: () => throw Exception(
          'Battery сервис не найден. Устройство может использовать проприетарный протокол.',
        ),
      );

      final characteristic = batteryService.characteristics.firstWhere(
        (char) =>
            char.uuid.toString().toLowerCase() ==
            BleUuids.batteryLevel.toLowerCase(),
        orElse: () => throw Exception('Battery Level не найдена'),
      );

      final value = await characteristic.read();
      if (value.isEmpty) return null;

      return BatteryData(level: value[0], timestamp: DateTime.now());
    } catch (e) {
      print('Ошибка при чтении уровня батареи: $e');
      return null;
    }
  }

  @override
  Stream<BatteryData> subscribeToBattery(String deviceId) {
    if (!_batteryControllers.containsKey(deviceId)) {
      _batteryControllers[deviceId] = StreamController<BatteryData>.broadcast();
      _subscribeToBatteryCharacteristic(deviceId);
    }

    return _batteryControllers[deviceId]!.stream;
  }

  Future<void> _subscribeToBatteryCharacteristic(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) throw Exception('Устройство не найдено');

      final services = await device.discoverServices();
      final batteryService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            BleUuids.battery.toLowerCase(),
        orElse: () => throw Exception('Battery сервис не найден'),
      );

      final characteristic = batteryService.characteristics.firstWhere(
        (char) =>
            char.uuid.toString().toLowerCase() ==
            BleUuids.batteryLevel.toLowerCase(),
        orElse: () => throw Exception('Battery Level не найдена'),
      );

      await characteristic.setNotifyValue(true);

      final subscription = characteristic.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final batteryData = BatteryData(
            level: value[0],
            timestamp: DateTime.now(),
          );
          _batteryControllers[deviceId]?.add(batteryData);
        }
      });

      _addSubscription(deviceId, subscription);
    } catch (e) {
      print('Ошибка при подписке на Battery: $e');
    }
  }

  @override
  Future<StepsData?> getSteps(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) return null;

      final services = await device.discoverServices();

      // Примечание: UUID для шагов не стандартизирован, каждый производитель может использовать свой
      // Здесь используется пример UUID
      final characteristic = await _findCharacteristic(
        services,
        BleUuids.steps,
      );

      if (characteristic == null) return null;

      final value = await characteristic.read();
      if (value.isEmpty) return null;

      // Парсинг зависит от производителя, это пример
      final steps = ByteData.sublistView(
        Uint8List.fromList(value),
      ).getUint32(0, Endian.little);

      return StepsData(steps: steps, timestamp: DateTime.now());
    } catch (e) {
      print('Ошибка при чтении шагов: $e');
      return null;
    }
  }

  @override
  Future<BodyTemperatureData?> getBodyTemperature(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) return null;

      final services = await device.discoverServices();
      final characteristic = await _findCharacteristic(
        services,
        BleUuids.bodyTemperature,
      );

      if (characteristic == null) return null;

      final value = await characteristic.read();
      if (value.length < 4) return null;

      // Парсинг Temperature Measurement согласно GATT спецификации
      final flags = value[0];
      final isFahrenheit = (flags & 0x01) != 0;

      // Температура в формате FLOAT (IEEE-11073)
      final tempValue = ByteData.sublistView(
        Uint8List.fromList(value),
      ).getFloat32(1, Endian.little);

      final celsius = isFahrenheit ? (tempValue - 32) * 5 / 9 : tempValue;

      return BodyTemperatureData(celsius: celsius, timestamp: DateTime.now());
    } catch (e) {
      print('Ошибка при чтении температуры: $e');
      return null;
    }
  }

  @override
  Future<OxygenSaturationData?> getOxygenSaturation(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) return null;

      final services = await device.discoverServices();
      final characteristic = await _findCharacteristic(
        services,
        BleUuids.oxygenSaturation,
      );

      if (characteristic == null) return null;

      final value = await characteristic.read();
      if (value.isEmpty) return null;

      // Формат зависит от производителя
      final percentage = value[0];

      return OxygenSaturationData(
        percentage: percentage,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Ошибка при чтении SpO2: $e');
      return null;
    }
  }

  @override
  Future<DeviceInfo?> getDeviceInfo(String deviceId) async {
    try {
      final device = _bluetoothService.getDevice(deviceId);
      if (device == null) return null;

      final services = await device.discoverServices();
      final deviceInfoService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            BleUuids.deviceInformation.toLowerCase(),
        orElse: () => throw Exception('Device Information сервис не найден'),
      );

      return DeviceInfo(
        manufacturer: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.manufacturerName,
        ),
        modelNumber: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.modelNumber,
        ),
        serialNumber: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.serialNumber,
        ),
        hardwareRevision: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.hardwareRevision,
        ),
        firmwareRevision: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.firmwareRevision,
        ),
        softwareRevision: await _readStringCharacteristic(
          deviceInfoService,
          BleUuids.softwareRevision,
        ),
      );
    } catch (e) {
      print('Ошибка при чтении информации об устройстве: $e');
      return null;
    }
  }

  Future<String?> _readStringCharacteristic(
    BluetoothService service,
    String characteristicUuid,
  ) async {
    try {
      final characteristic = service.characteristics.firstWhere(
        (char) =>
            char.uuid.toString().toLowerCase() ==
            characteristicUuid.toLowerCase(),
        orElse: () => throw Exception('Характеристика не найдена'),
      );

      final value = await characteristic.read();
      return String.fromCharCodes(value);
    } catch (e) {
      return null;
    }
  }

  Future<BluetoothCharacteristic?> _findCharacteristic(
    List<BluetoothService> services,
    String characteristicUuid,
  ) async {
    for (final service in services) {
      try {
        return service.characteristics.firstWhere(
          (char) =>
              char.uuid.toString().toLowerCase() ==
              characteristicUuid.toLowerCase(),
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  void _addSubscription(String deviceId, StreamSubscription subscription) {
    if (!_subscriptions.containsKey(deviceId)) {
      _subscriptions[deviceId] = [];
    }
    _subscriptions[deviceId]!.add(subscription);
  }

  @override
  Future<void> unsubscribeAll(String deviceId) async {
    // Отменяем все подписки для устройства
    final deviceSubscriptions = _subscriptions[deviceId];
    if (deviceSubscriptions != null) {
      for (final subscription in deviceSubscriptions) {
        await subscription.cancel();
      }
      _subscriptions.remove(deviceId);
    }

    // Закрываем контроллеры
    await _heartRateControllers[deviceId]?.close();
    _heartRateControllers.remove(deviceId);

    await _batteryControllers[deviceId]?.close();
    _batteryControllers.remove(deviceId);
  }

  @override
  Future<void> dispose() async {
    // Отменяем все подписки
    for (final deviceId in _subscriptions.keys.toList()) {
      await unsubscribeAll(deviceId);
    }

    _subscriptions.clear();
    _heartRateControllers.clear();
    _batteryControllers.clear();
  }
}
