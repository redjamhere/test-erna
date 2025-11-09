import 'dart:async';
import 'dart:math';
import '../models/health_data.dart';
import 'smartwatch_data_service.dart';

/// Mock Health Data Service для генерации реалистичных данных здоровья
///
/// Поддерживает симуляцию данных для различных типов устройств:
/// - Samsung Galaxy Watch (высокая точность, быстрое обновление)
/// - Apple Watch (отличная точность, активные тренировки)
/// - Fitbit (фокус на фитнес метрики)
/// - Garmin (спортивные метрики, GPS)
/// - Amazfit (базовые метрики)
/// - Huawei Watch (комплексные метрики)
class MockHealthDataService implements SmartwatchDataService {
  final Map<String, StreamController<HeartRateData>> _heartRateControllers = {};
  final Map<String, StreamController<BatteryData>> _batteryControllers = {};
  final Map<String, Timer?> _heartRateTimers = {};
  final Map<String, int> _currentBatteryLevels = {};
  final Map<String, int> _dailySteps = {};

  final Random _random = Random();

  /// Базовые параметры пульса для разных типов устройств
  int _getBaseHeartRate(String deviceId) {
    if (deviceId.contains('apple') || deviceId.contains('samsung')) {
      return 72; // Более точные устройства показывают реалистичный пульс покоя
    } else if (deviceId.contains('garmin') || deviceId.contains('polar')) {
      return 68; // Спортивные часы для более тренированных пользователей
    } else if (deviceId.contains('fitbit')) {
      return 75;
    }
    return 73; // Дефолтный пульс покоя
  }

  /// Вариация пульса
  int _getHeartRateVariation(String deviceId) {
    if (deviceId.contains('apple') || deviceId.contains('samsung')) {
      return 5; // Меньшая вариация у точных устройств
    } else if (deviceId.contains('garmin')) {
      return 8; // Спортивные часы учитывают активность
    }
    return 7; // Стандартная вариация
  }

  /// Генерация реалистичного пульса с учетом времени суток и активности
  int _generateRealisticHeartRate(String deviceId) {
    final hour = DateTime.now().hour;
    final baseRate = _getBaseHeartRate(deviceId);
    final variation = _getHeartRateVariation(deviceId);

    // Симуляция циркадного ритма
    int timeAdjustment = 0;
    if (hour >= 6 && hour < 12) {
      // Утро - пульс повышается
      timeAdjustment = 3 + _random.nextInt(5);
    } else if (hour >= 12 && hour < 18) {
      // День - активность
      timeAdjustment = 5 + _random.nextInt(8);
    } else if (hour >= 18 && hour < 22) {
      // Вечер - спокойствие
      timeAdjustment = -2 + _random.nextInt(4);
    } else {
      // Ночь - низкий пульс
      timeAdjustment = -8 + _random.nextInt(4);
    }

    // Случайная "активность" (симуляция движения)
    final activitySpike = _random.nextDouble() < 0.1
        ? 10 + _random.nextInt(20)
        : 0;

    return (baseRate +
            timeAdjustment +
            activitySpike +
            _random.nextInt(variation) -
            variation ~/ 2)
        .clamp(50, 180);
  }

  /// Генерация уровня батареи
  int _generateBatteryLevel(String deviceId) {
    if (!_currentBatteryLevels.containsKey(deviceId)) {
      // Начальный уровень батареи зависит от типа устройства
      if (deviceId.contains('apple_watch')) {
        _currentBatteryLevels[deviceId] =
            60 + _random.nextInt(35); // Apple Watch 60-95%
      } else if (deviceId.contains('samsung')) {
        _currentBatteryLevels[deviceId] =
            65 + _random.nextInt(30); // Samsung 65-95%
      } else if (deviceId.contains('amazfit') || deviceId.contains('huawei')) {
        _currentBatteryLevels[deviceId] =
            75 + _random.nextInt(20); // Долгая батарея 75-95%
      } else {
        _currentBatteryLevels[deviceId] = 50 + _random.nextInt(45); // 50-95%
      }
    }

    // Медленное уменьшение батареи (1% каждые ~30 секунд в моке)
    if (_random.nextDouble() < 0.03) {
      _currentBatteryLevels[deviceId] = (_currentBatteryLevels[deviceId]! - 1)
          .clamp(5, 100);
    }

    return _currentBatteryLevels[deviceId]!;
  }

  /// Генерация количества шагов
  int _generateSteps(String deviceId) {
    if (!_dailySteps.containsKey(deviceId)) {
      // Начальное количество шагов зависит от времени суток
      final hour = DateTime.now().hour;
      final baseSteps =
          (hour * 300) + _random.nextInt(1000); // ~300 шагов в час
      _dailySteps[deviceId] = baseSteps;
    }

    // Постепенно увеличиваем шаги
    if (_random.nextDouble() < 0.3) {
      _dailySteps[deviceId] = _dailySteps[deviceId]! + _random.nextInt(20);
    }

    return _dailySteps[deviceId]!;
  }

  @override
  Stream<HeartRateData> subscribeToHeartRate(String deviceId) {
    if (!_heartRateControllers.containsKey(deviceId)) {
      _heartRateControllers[deviceId] =
          StreamController<HeartRateData>.broadcast();
      _startHeartRateGeneration(deviceId);
    }

    return _heartRateControllers[deviceId]!.stream;
  }

  void _startHeartRateGeneration(String deviceId) {
    print('🎭 Mock: Starting heart rate generation for $deviceId');

    // Частота обновления зависит от устройства
    Duration updateInterval = const Duration(seconds: 2);
    if (deviceId.contains('apple') || deviceId.contains('samsung')) {
      updateInterval = const Duration(seconds: 1); // Быстрое обновление
    } else if (deviceId.contains('amazfit') || deviceId.contains('mi_band')) {
      updateInterval = const Duration(seconds: 5); // Медленное обновление
    }

    _heartRateTimers[deviceId] = Timer.periodic(updateInterval, (timer) {
      final bpm = _generateRealisticHeartRate(deviceId);
      final data = HeartRateData(bpm: bpm, timestamp: DateTime.now());

      _heartRateControllers[deviceId]?.add(data);
      print('🎭 Mock: Heart rate for $deviceId: $bpm BPM');
    });
  }

  @override
  Stream<BatteryData> subscribeToBattery(String deviceId) {
    if (!_batteryControllers.containsKey(deviceId)) {
      _batteryControllers[deviceId] = StreamController<BatteryData>.broadcast();

      // Обновляем батарею каждые 10 секунд
      Timer.periodic(const Duration(seconds: 10), (timer) {
        if (!_batteryControllers.containsKey(deviceId)) {
          timer.cancel();
          return;
        }

        final level = _generateBatteryLevel(deviceId);
        BatteryStatus status = BatteryStatus.discharging;

        if (level >= 95) {
          status = BatteryStatus.full;
        } else if (level <= 15) {
          status = BatteryStatus.discharging;
        }

        final data = BatteryData(
          level: level,
          timestamp: DateTime.now(),
          status: status,
        );

        _batteryControllers[deviceId]?.add(data);
      });
    }

    return _batteryControllers[deviceId]!.stream;
  }

  @override
  Future<BatteryData?> getBatteryLevel(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final level = _generateBatteryLevel(deviceId);
    BatteryStatus status = BatteryStatus.discharging;

    if (level >= 95) {
      status = BatteryStatus.full;
    } else if (level <= 15) {
      status = BatteryStatus.discharging;
    }

    print('🎭 Mock: Battery level for $deviceId: $level%');

    return BatteryData(level: level, timestamp: DateTime.now(), status: status);
  }

  @override
  Future<StepsData?> getSteps(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final steps = _generateSteps(deviceId);
    final distance = (steps * 0.75) / 1000; // ~0.75м на шаг, в км
    final calories = (steps * 0.04).toInt(); // ~0.04 калории на шаг

    print('🎭 Mock: Steps for $deviceId: $steps');

    return StepsData(
      steps: steps,
      timestamp: DateTime.now(),
      distance: distance,
      calories: calories,
    );
  }

  @override
  Future<BodyTemperatureData?> getBodyTemperature(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Только некоторые устройства поддерживают температуру
    if (!deviceId.contains('samsung') &&
        !deviceId.contains('fitbit_sense') &&
        !deviceId.contains('withings')) {
      return null;
    }

    // Нормальная температура тела с небольшими вариациями
    final baseTempCelsius = 36.6;
    final variation = (_random.nextDouble() - 0.5) * 0.6; // ±0.3°C
    final temperature = baseTempCelsius + variation;

    print(
      '🎭 Mock: Body temperature for $deviceId: ${temperature.toStringAsFixed(1)}°C',
    );

    return BodyTemperatureData(celsius: temperature, timestamp: DateTime.now());
  }

  @override
  Future<OxygenSaturationData?> getOxygenSaturation(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Только продвинутые устройства поддерживают SpO2
    if (!deviceId.contains('apple') &&
        !deviceId.contains('samsung') &&
        !deviceId.contains('fitbit_sense') &&
        !deviceId.contains('garmin') &&
        !deviceId.contains('withings')) {
      return null;
    }

    // Нормальная сатурация кислорода 95-100%
    final percentage = 96 + _random.nextInt(4);

    print('🎭 Mock: Oxygen saturation for $deviceId: $percentage%');

    return OxygenSaturationData(
      percentage: percentage,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<DeviceInfo?> getDeviceInfo(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 50));

    String manufacturer = 'Unknown';
    String model = 'Unknown';

    if (deviceId.contains('samsung')) {
      manufacturer = 'Samsung';
      model = deviceId.contains('watch_6')
          ? 'Galaxy Watch6'
          : 'Galaxy Watch5 Pro';
    } else if (deviceId.contains('apple')) {
      manufacturer = 'Apple';
      model = deviceId.contains('series_9')
          ? 'Watch Series 9'
          : 'Watch Ultra 2';
    } else if (deviceId.contains('fitbit')) {
      manufacturer = 'Fitbit';
      model = deviceId.contains('sense') ? 'Sense 2' : 'Versa 4';
    } else if (deviceId.contains('garmin')) {
      manufacturer = 'Garmin';
      model = deviceId.contains('fenix') ? 'Fenix 7' : 'Forerunner 965';
    } else if (deviceId.contains('amazfit')) {
      manufacturer = 'Amazfit';
      model = deviceId.contains('gtr') ? 'GTR 4' : 'T-Rex 2';
    } else if (deviceId.contains('huawei')) {
      manufacturer = 'Huawei';
      model = deviceId.contains('gt_4') ? 'WATCH GT 4' : 'WATCH Fit 3';
    } else if (deviceId.contains('xiaomi') || deviceId.contains('mi_band')) {
      manufacturer = 'Xiaomi';
      model = deviceId.contains('watch') ? 'Watch S3' : 'Mi Smart Band 8';
    } else if (deviceId.contains('polar')) {
      manufacturer = 'Polar';
      model = 'Vantage V3';
    } else if (deviceId.contains('withings')) {
      manufacturer = 'Withings';
      model = 'ScanWatch 2';
    }

    return DeviceInfo(
      manufacturer: manufacturer,
      modelNumber: model,
      serialNumber: 'MOCK-${deviceId.hashCode.abs()}',
      hardwareRevision: '1.0',
      firmwareRevision: '2.5.${_random.nextInt(20)}',
      softwareRevision: 'MockOS 3.0',
    );
  }

  @override
  Future<void> unsubscribeAll(String deviceId) async {
    print('🎭 Mock: Unsubscribing from all data streams for $deviceId');

    _heartRateTimers[deviceId]?.cancel();
    _heartRateTimers.remove(deviceId);

    await _heartRateControllers[deviceId]?.close();
    _heartRateControllers.remove(deviceId);

    await _batteryControllers[deviceId]?.close();
    _batteryControllers.remove(deviceId);
  }

  @override
  Future<void> dispose() async {
    print('🎭 Mock: Disposing health data service');

    for (final timer in _heartRateTimers.values) {
      timer?.cancel();
    }
    _heartRateTimers.clear();

    for (final controller in _heartRateControllers.values) {
      await controller.close();
    }
    _heartRateControllers.clear();

    for (final controller in _batteryControllers.values) {
      await controller.close();
    }
    _batteryControllers.clear();

    _currentBatteryLevels.clear();
    _dailySteps.clear();
  }
}
