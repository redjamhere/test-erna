import 'dart:async';
import 'package:health/health.dart';
import '../models/health_data.dart';
import 'smartwatch_data_service.dart' as sw;

/// Сервис для получения данных из iOS Health (HealthKit)
///
/// Использует пакет `health` для доступа к HealthKit на iOS устройствах.
/// Реализует интерфейс SmartwatchDataService для единообразной работы с данными.
class IosHealthService implements sw.SmartwatchDataService {
  final Health _health = Health();

  final Map<String, StreamController<HeartRateData>> _heartRateControllers = {};
  final Map<String, StreamController<BatteryData>> _batteryControllers = {};
  final Map<String, Timer?> _heartRateTimers = {};
  final Map<String, DateTime?> _lastHeartRateTimestamp = {};

  bool _isAuthorized = false;

  /// Типы данных для запроса разрешений
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  /// Запросить разрешения на доступ к HealthKit
  Future<bool> requestAuthorization() async {
    try {
      final permissions = _dataTypes
          .map((type) => HealthDataAccess.READ)
          .toList();

      _isAuthorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: permissions,
      );

      print('📱 iOS Health authorization: $_isAuthorized');
      return _isAuthorized;
    } catch (e) {
      print('❌ Error requesting iOS Health authorization: $e');
      return false;
    }
  }

  /// Проверить, авторизован ли доступ
  Future<void> _ensureAuthorized() async {
    if (!_isAuthorized) {
      final authorized = await requestAuthorization();
      if (!authorized) {
        throw Exception('iOS Health access not authorized');
      }
    }
  }

  @override
  Stream<HeartRateData> subscribeToHeartRate(String deviceId) {
    if (!_heartRateControllers.containsKey(deviceId)) {
      _heartRateControllers[deviceId] =
          StreamController<HeartRateData>.broadcast();
      _startHeartRatePolling(deviceId);
    }

    return _heartRateControllers[deviceId]!.stream;
  }

  /// Запускает периодический опрос данных о пульсе
  void _startHeartRatePolling(String deviceId) async {
    await _ensureAuthorized();

    // Получаем данные каждые 2 секунды
    _heartRateTimers[deviceId] = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      try {
        final now = DateTime.now();
        // Расширяем окно поиска до последних 10 минут
        // чтобы гарантированно найти данные о пульсе
        final startTime = now.subtract(const Duration(minutes: 10));

        final healthData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: startTime,
          endTime: now,
        );

        if (healthData.isNotEmpty) {
          // Сортируем по времени и берем самое последнее значение
          healthData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          final latestData = healthData.first;

          // Проверяем, не отправляли ли мы уже это значение
          final lastTimestamp = _lastHeartRateTimestamp[deviceId];
          if (lastTimestamp != null &&
              !latestData.dateTo.isAfter(lastTimestamp)) {
            // Это старое значение, не отправляем повторно
            return;
          }

          final bpm = (latestData.value as NumericHealthValue).numericValue
              .toInt();

          final heartRateData = HeartRateData(
            bpm: bpm,
            timestamp: latestData.dateTo,
          );

          // Сохраняем timestamp последнего отправленного значения
          _lastHeartRateTimestamp[deviceId] = latestData.dateTo;

          _heartRateControllers[deviceId]?.add(heartRateData);
          print(
            '💓 iOS Health - Heart Rate: $bpm BPM (recorded at ${latestData.dateTo})',
          );
        } else {
          print(
            '📊 iOS Health - No heart rate data available in the last 10 minutes',
          );
        }
      } catch (e) {
        print('❌ Error fetching heart rate from iOS Health: $e');
      }
    });
  }

  @override
  Future<BatteryData?> getBatteryLevel(String deviceId) async {
    // iOS Health не предоставляет информацию о батарее устройства
    // Возвращаем заглушку
    return BatteryData(
      level: 100,
      timestamp: DateTime.now(),
      status: BatteryStatus.unknown,
    );
  }

  @override
  Stream<BatteryData> subscribeToBattery(String deviceId) {
    if (!_batteryControllers.containsKey(deviceId)) {
      _batteryControllers[deviceId] = StreamController<BatteryData>.broadcast();

      // iOS Health не предоставляет данные о батарее
      // Отправляем статичное значение
      Timer.periodic(const Duration(seconds: 30), (timer) {
        _batteryControllers[deviceId]?.add(
          BatteryData(
            level: 100,
            timestamp: DateTime.now(),
            status: BatteryStatus.unknown,
          ),
        );
      });
    }

    return _batteryControllers[deviceId]!.stream;
  }

  @override
  Future<StepsData?> getSteps(String deviceId) async {
    try {
      await _ensureAuthorized();

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS, HealthDataType.DISTANCE_WALKING_RUNNING],
        startTime: midnight,
        endTime: now,
      );

      int totalSteps = 0;
      double totalDistance = 0.0; // в метрах

      for (final data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          totalSteps += (data.value as NumericHealthValue).numericValue.toInt();
        } else if (data.type == HealthDataType.DISTANCE_WALKING_RUNNING) {
          totalDistance += (data.value as NumericHealthValue).numericValue;
        }
      }

      print(
        '🚶 iOS Health - Steps: $totalSteps, Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km',
      );

      return StepsData(
        steps: totalSteps,
        timestamp: DateTime.now(),
        distance: totalDistance / 1000, // конвертируем в километры
      );
    } catch (e) {
      print('❌ Error fetching steps from iOS Health: $e');
      return null;
    }
  }

  @override
  Future<BodyTemperatureData?> getBodyTemperature(String deviceId) async {
    try {
      await _ensureAuthorized();

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BODY_TEMPERATURE],
        startTime: yesterday,
        endTime: now,
      );

      if (healthData.isEmpty) {
        print('📊 iOS Health - No body temperature data available');
        return null;
      }

      // Берем самое последнее значение
      final latestData = healthData.last;
      final celsius = (latestData.value as NumericHealthValue).numericValue
          .toDouble();

      print('🌡️ iOS Health - Temperature: ${celsius.toStringAsFixed(1)}°C');

      return BodyTemperatureData(
        celsius: celsius,
        timestamp: latestData.dateTo,
      );
    } catch (e) {
      print('❌ Error fetching body temperature from iOS Health: $e');
      return null;
    }
  }

  @override
  Future<OxygenSaturationData?> getOxygenSaturation(String deviceId) async {
    try {
      await _ensureAuthorized();

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: yesterday,
        endTime: now,
      );

      if (healthData.isEmpty) {
        print('📊 iOS Health - No blood oxygen data available');
        return null;
      }

      // Берем самое последнее значение
      final latestData = healthData.last;
      final percentage =
          ((latestData.value as NumericHealthValue).numericValue * 100).toInt();

      print('🫁 iOS Health - SpO2: $percentage%');

      return OxygenSaturationData(
        percentage: percentage,
        timestamp: latestData.dateTo,
      );
    } catch (e) {
      print('❌ Error fetching oxygen saturation from iOS Health: $e');
      return null;
    }
  }

  @override
  Future<sw.DeviceInfo?> getDeviceInfo(String deviceId) async {
    // iOS Health не предоставляет информацию об устройстве
    // Возвращаем информацию о том, что это iOS Health
    return const sw.DeviceInfo(
      manufacturer: 'Apple',
      modelNumber: 'iOS Health',
      serialNumber: 'N/A',
      hardwareRevision: 'N/A',
      firmwareRevision: 'N/A',
      softwareRevision: 'HealthKit',
    );
  }

  @override
  Future<void> unsubscribeAll(String deviceId) async {
    // Останавливаем таймер
    _heartRateTimers[deviceId]?.cancel();
    _heartRateTimers.remove(deviceId);

    // Очищаем timestamp
    _lastHeartRateTimestamp.remove(deviceId);

    // Закрываем контроллеры
    await _heartRateControllers[deviceId]?.close();
    _heartRateControllers.remove(deviceId);

    await _batteryControllers[deviceId]?.close();
    _batteryControllers.remove(deviceId);

    print('🔌 Unsubscribed from iOS Health data for device: $deviceId');
  }

  @override
  Future<void> dispose() async {
    // Останавливаем все таймеры
    for (final timer in _heartRateTimers.values) {
      timer?.cancel();
    }
    _heartRateTimers.clear();

    // Очищаем timestamps
    _lastHeartRateTimestamp.clear();

    // Закрываем все контроллеры
    for (final controller in _heartRateControllers.values) {
      await controller.close();
    }
    _heartRateControllers.clear();

    for (final controller in _batteryControllers.values) {
      await controller.close();
    }
    _batteryControllers.clear();

    print('🗑️ iOS Health Service disposed');
  }
}
