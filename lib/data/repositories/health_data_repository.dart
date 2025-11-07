import 'dart:async';
import '../../core/models/bluetooth_device_info.dart';
import '../../core/models/health_data.dart';
import '../../core/service/unified_health_service.dart';

/// Репозиторий для управления данными о здоровье
abstract interface class HealthDataRepository {
  /// Получить последние данные о пульсе
  HeartRateData? get latestHeartRate;

  /// Получить последние данные о шагах
  StepsData? get latestSteps;

  /// Получить последние данные о батарее
  BatteryData? get latestBattery;

  /// Получить последнюю температуру
  BodyTemperatureData? get latestTemperature;

  /// Получить последний SpO2
  OxygenSaturationData? get latestOxygenSaturation;

  /// Stream данных о пульсе
  Stream<HeartRateData> get heartRateStream;

  /// Stream данных о батарее
  Stream<BatteryData> get batteryStream;

  /// Начать получение данных от устройства
  Future<void> startDataCollection(BluetoothDeviceInfo device);

  /// Остановить получение данных
  Future<void> stopDataCollection();

  /// Обновить данные о шагах
  Future<void> refreshSteps();

  /// Обновить данные о температуре
  Future<void> refreshTemperature();

  /// Обновить данные о SpO2
  Future<void> refreshOxygenSaturation();

  /// Получить ID активного устройства
  String? get activeDeviceId;

  /// Освободить ресурсы
  Future<void> dispose();
}

/// Реализация репозитория данных о здоровье
class HealthDataRepositoryImpl implements HealthDataRepository {
  final UnifiedHealthService _unifiedHealthService;

  HeartRateData? _latestHeartRate;
  StepsData? _latestSteps;
  BatteryData? _latestBattery;
  BodyTemperatureData? _latestTemperature;
  OxygenSaturationData? _latestOxygenSaturation;

  final _heartRateController = StreamController<HeartRateData>.broadcast();
  final _batteryController = StreamController<BatteryData>.broadcast();

  StreamSubscription? _heartRateSubscription;
  StreamSubscription? _batterySubscription;

  HealthDataRepositoryImpl(this._unifiedHealthService);

  @override
  HeartRateData? get latestHeartRate => _latestHeartRate;

  @override
  StepsData? get latestSteps => _latestSteps;

  @override
  BatteryData? get latestBattery => _latestBattery;

  @override
  BodyTemperatureData? get latestTemperature => _latestTemperature;

  @override
  OxygenSaturationData? get latestOxygenSaturation => _latestOxygenSaturation;

  @override
  Stream<HeartRateData> get heartRateStream => _heartRateController.stream;

  @override
  Stream<BatteryData> get batteryStream => _batteryController.stream;

  @override
  String? get activeDeviceId => _unifiedHealthService.activeDeviceId;

  @override
  Future<void> startDataCollection(BluetoothDeviceInfo device) async {
    // Останавливаем предыдущий сбор данных
    await stopDataCollection();

    // Подключаемся через унифицированный сервис
    // Он автоматически определит Huawei или BLE
    await _unifiedHealthService.connectToDevice(device);

    // Подписываемся на пульс
    _heartRateSubscription = _unifiedHealthService.heartRateStream.listen((
      heartRate,
    ) {
      _latestHeartRate = heartRate;
      _heartRateController.add(heartRate);
    });

    // Подписываемся на батарею
    _batterySubscription = _unifiedHealthService.batteryStream.listen((
      battery,
    ) {
      _latestBattery = battery;
      _batteryController.add(battery);
    });

    // Получаем начальные данные
    await Future.wait([
      refreshSteps(),
      refreshTemperature(),
      refreshOxygenSaturation(),
    ]);
  }

  @override
  Future<void> stopDataCollection() async {
    await _unifiedHealthService.disconnectFromDevice();

    await _heartRateSubscription?.cancel();
    await _batterySubscription?.cancel();

    _heartRateSubscription = null;
    _batterySubscription = null;
  }

  @override
  Future<void> refreshSteps() async {
    try {
      final steps = await _unifiedHealthService.getSteps();
      if (steps != null) {
        _latestSteps = steps;
      }
    } catch (e) {
      print('Ошибка обновления шагов: $e');
    }
  }

  @override
  Future<void> refreshTemperature() async {
    try {
      final temp = await _unifiedHealthService.getBodyTemperature();
      if (temp != null) {
        _latestTemperature = temp;
      }
    } catch (e) {
      print('Ошибка обновления температуры: $e');
    }
  }

  @override
  Future<void> refreshOxygenSaturation() async {
    try {
      final spo2 = await _unifiedHealthService.getOxygenSaturation();
      if (spo2 != null) {
        _latestOxygenSaturation = spo2;
      }
    } catch (e) {
      print('Ошибка обновления SpO2: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await stopDataCollection();
    await _heartRateController.close();
    await _batteryController.close();
  }
}
