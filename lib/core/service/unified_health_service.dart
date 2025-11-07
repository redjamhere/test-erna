import 'dart:async';
import '../models/bluetooth_device_info.dart';
import '../models/health_data.dart';
import 'bluetooth_service.dart';
import 'ios_health_service.dart';
import 'smartwatch_data_service.dart';

/// Унифицированный сервис для работы с данными здоровья
/// Автоматически выбирает iOS Health или BLE GATT
/// в зависимости от типа устройства
abstract interface class UnifiedHealthService {
  /// Подключиться к устройству и начать сбор данных
  Future<void> connectToDevice(BluetoothDeviceInfo device);

  /// Отключиться от устройства
  Future<void> disconnectFromDevice();

  /// Подписаться на данные о сердечном ритме
  Stream<HeartRateData> get heartRateStream;

  /// Подписаться на данные о батарее
  Stream<BatteryData> get batteryStream;

  /// Получить текущий уровень батареи
  Future<BatteryData?> getBatteryLevel();

  /// Получить данные о шагах
  Future<StepsData?> getSteps();

  /// Получить данные о температуре тела
  Future<BodyTemperatureData?> getBodyTemperature();

  /// Получить данные о кислороде в крови (SpO2)
  Future<OxygenSaturationData?> getOxygenSaturation();

  /// Проверить, используется ли iOS Health (HealthKit)
  bool get isIosHealth;

  /// Получить ID активного устройства
  String? get activeDeviceId;

  /// Получить информацию об активном устройстве
  BluetoothDeviceInfo? get activeDevice;

  /// Освободить ресурсы
  Future<void> dispose();
}

/// Реализация унифицированного сервиса
class UnifiedHealthServiceImpl implements UnifiedHealthService {
  final SmartwatchDataService _smartwatchDataService;
  final IosHealthService _iosHealthService;
  final BluetoothService _bluetoothService;

  BluetoothDeviceInfo? _activeDevice;
  bool _isIosHealth = false;

  final _heartRateController = StreamController<HeartRateData>.broadcast();
  final _batteryController = StreamController<BatteryData>.broadcast();

  StreamSubscription<HeartRateData>? _heartRateSubscription;
  StreamSubscription<BatteryData>? _batterySubscription;
  StreamSubscription<StepsData>? _stepsSubscription;

  UnifiedHealthServiceImpl({
    required SmartwatchDataService smartwatchDataService,
    required IosHealthService iosHealthService,
    required BluetoothService bluetoothService,
  }) : _smartwatchDataService = smartwatchDataService,
       _iosHealthService = iosHealthService,
       _bluetoothService = bluetoothService;

  @override
  Future<void> connectToDevice(BluetoothDeviceInfo device) async {
    // Отключаемся от предыдущего устройства
    await disconnectFromDevice();

    _activeDevice = device;

    // Проверяем, используется ли iOS Health (специальное "устройство")
    if (device.name == 'iOS Health' || device.id == 'ios_health') {
      print('📱 Тип устройства: iOS Health (HealthKit)');
      _isIosHealth = true;
      await _connectToIosHealth(device);
      return;
    }

    print('🔍 Обнаружено устройство: ${device.name}');
    print('📱 Тип устройства: Стандартный BLE GATT');
    await _connectToBleDevice(device);
  }

  /// Подключиться к iOS Health (HealthKit)
  Future<void> _connectToIosHealth(BluetoothDeviceInfo device) async {
    print('✅ Используем iOS Health Service (HealthKit)');

    try {
      // Запрашиваем разрешения на доступ к HealthKit
      final authorized = await _iosHealthService.requestAuthorization();

      if (!authorized) {
        throw Exception(
          'iOS Health доступ не разрешен.\n\n'
          'Пожалуйста, разрешите доступ к Health данным в настройках iOS.',
        );
      }

      // Подписываемся на данные через iOS Health
      _heartRateSubscription = _iosHealthService
          .subscribeToHeartRate(device.id)
          .listen((heartRate) {
            _heartRateController.add(heartRate);
          });

      _batterySubscription = _iosHealthService
          .subscribeToBattery(device.id)
          .listen((battery) {
            _batteryController.add(battery);
          });

      print('✅ iOS Health Service подключен');
      print('📱 Получение данных из HealthKit каждые 2 секунды');
    } catch (e) {
      print('❌ Ошибка подключения к iOS Health: $e');
      rethrow;
    }
  }

  /// Подключиться к BLE устройству через GATT
  Future<void> _connectToBleDevice(BluetoothDeviceInfo device) async {
    print('✅ Используем стандартный BLE GATT');

    try {
      // Подключаемся через BLE
      final connected = await _bluetoothService.connectToDevice(device.id);

      if (!connected) {
        throw Exception('Не удалось подключиться к устройству');
      }

      // Подписываемся на данные
      _heartRateSubscription = _smartwatchDataService
          .subscribeToHeartRate(device.id)
          .listen((heartRate) {
            _heartRateController.add(heartRate);
          });

      _batterySubscription = _smartwatchDataService
          .subscribeToBattery(device.id)
          .listen((battery) {
            _batteryController.add(battery);
          });

      print('✅ BLE GATT подключен');
    } catch (e) {
      print('❌ Ошибка подключения через BLE: $e');
      rethrow;
    }
  }

  @override
  Future<void> disconnectFromDevice() async {
    // Отменяем подписки
    await _heartRateSubscription?.cancel();
    await _batterySubscription?.cancel();
    await _stepsSubscription?.cancel();

    _heartRateSubscription = null;
    _batterySubscription = null;
    _stepsSubscription = null;

    if (_activeDevice != null) {
      if (_isIosHealth) {
        // Отключаемся от iOS Health Service
        await _iosHealthService.unsubscribeAll(_activeDevice!.id);
      } else {
        // Отключаемся от BLE
        await _bluetoothService.disconnectFromDevice(_activeDevice!.id);
        await _smartwatchDataService.unsubscribeAll(_activeDevice!.id);
      }
    }

    _activeDevice = null;
    _isIosHealth = false;
  }

  @override
  Stream<HeartRateData> get heartRateStream => _heartRateController.stream;

  @override
  Stream<BatteryData> get batteryStream => _batteryController.stream;

  @override
  Future<BatteryData?> getBatteryLevel() async {
    if (_activeDevice == null) return null;

    if (_isIosHealth) {
      return await _iosHealthService.getBatteryLevel(_activeDevice!.id);
    } else {
      return await _smartwatchDataService.getBatteryLevel(_activeDevice!.id);
    }
  }

  @override
  Future<StepsData?> getSteps() async {
    if (_activeDevice == null) return null;

    if (_isIosHealth) {
      return await _iosHealthService.getSteps(_activeDevice!.id);
    } else {
      return await _smartwatchDataService.getSteps(_activeDevice!.id);
    }
  }

  @override
  Future<BodyTemperatureData?> getBodyTemperature() async {
    if (_activeDevice == null) return null;

    if (_isIosHealth) {
      return await _iosHealthService.getBodyTemperature(_activeDevice!.id);
    } else {
      return await _smartwatchDataService.getBodyTemperature(_activeDevice!.id);
    }
  }

  @override
  Future<OxygenSaturationData?> getOxygenSaturation() async {
    if (_activeDevice == null) return null;

    if (_isIosHealth) {
      return await _iosHealthService.getOxygenSaturation(_activeDevice!.id);
    } else {
      return await _smartwatchDataService.getOxygenSaturation(
        _activeDevice!.id,
      );
    }
  }

  @override
  bool get isIosHealth => _isIosHealth;

  @override
  String? get activeDeviceId => _activeDevice?.id;

  @override
  BluetoothDeviceInfo? get activeDevice => _activeDevice;

  @override
  Future<void> dispose() async {
    await disconnectFromDevice();
    await _heartRateController.close();
    await _batteryController.close();
  }
}
