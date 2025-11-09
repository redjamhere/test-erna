import 'package:test_erna/core/composition_root.dart';
import 'package:test_erna/core/service/bluetooth_service.dart';
import 'package:test_erna/core/service/smartwatch_data_service.dart';

/// Пример использования Mock Services
///
/// Этот файл демонстрирует как использовать mock Bluetooth и Health Data сервисы
/// для тестирования без физических устройств.
class MockServicesExample {
  /// Пример 1: Сканирование и отображение mock устройств
  static Future<void> scanForMockDevices() async {
    print('\n=== Пример 1: Сканирование Mock Устройств ===\n');

    final bluetoothService = CompositionRoot.get<BluetoothService>();

    // Подписка на обнаруженные устройства
    final subscription = bluetoothService.devicesStream.listen((devices) {
      print('📱 Найдено устройств: ${devices.length}');
      for (final device in devices) {
        print('   - ${device.name}');
        print('     ID: ${device.id}');
        print('     RSSI: ${device.rssi} dBm (${device.signalStrengthString})');
        print('     Состояние: ${device.connectionStateString}');
        print('');
      }
    });

    // Запуск сканирования
    print('🔍 Начинаем сканирование...\n');
    await bluetoothService.startScan(timeout: const Duration(seconds: 8));

    // Ждем завершения сканирования
    await Future.delayed(const Duration(seconds: 9));
    await bluetoothService.stopScan();

    await subscription.cancel();
    print('✅ Сканирование завершено\n');
  }

  /// Пример 2: Подключение к mock устройству и получение данных пульса
  static Future<void> connectAndMonitorHeartRate() async {
    print('\n=== Пример 2: Мониторинг Пульса ===\n');

    final bluetoothService = CompositionRoot.get<BluetoothService>();
    final healthService = CompositionRoot.get<SmartwatchDataService>();

    // Выбираем Apple Watch для теста
    const deviceId = 'mock_apple_watch_series_9';
    const deviceName = 'Apple Watch Series 9';

    print('🔗 Подключаемся к $deviceName...');
    final connected = await bluetoothService.connectToDevice(deviceId);

    if (!connected) {
      print('❌ Не удалось подключиться');
      return;
    }

    print('✅ Подключено!\n');
    print('💓 Мониторинг пульса (10 секунд):\n');

    // Подписка на данные пульса
    final subscription = healthService
        .subscribeToHeartRate(deviceId)
        .listen(
          (heartRate) {
            final time = _formatTime(heartRate.timestamp);
            print('   [$time] Пульс: ${heartRate.bpm} BPM');
          },
          onError: (error) {
            print('❌ Ошибка: $error');
          },
        );

    // Мониторим 10 секунд
    await Future.delayed(const Duration(seconds: 10));

    await subscription.cancel();
    await healthService.unsubscribeAll(deviceId);
    await bluetoothService.disconnectFromDevice(deviceId);

    print('\n✅ Отключено\n');
  }

  /// Пример 3: Получение всех данных здоровья
  static Future<void> getAllHealthData() async {
    print('\n=== Пример 3: Все Данные Здоровья ===\n');

    final bluetoothService = CompositionRoot.get<BluetoothService>();
    final healthService = CompositionRoot.get<SmartwatchDataService>();

    // Используем Samsung Galaxy Watch для полного набора данных
    const deviceId = 'mock_samsung_galaxy_watch_6';
    const deviceName = 'Galaxy Watch6';

    print('🔗 Подключаемся к $deviceName...\n');
    await bluetoothService.connectToDevice(deviceId);

    // Информация об устройстве
    print('📱 Информация об устройстве:');
    final deviceInfo = await healthService.getDeviceInfo(deviceId);
    if (deviceInfo != null) {
      print('   Производитель: ${deviceInfo.manufacturer}');
      print('   Модель: ${deviceInfo.modelNumber}');
      print('   Серийный номер: ${deviceInfo.serialNumber}');
      print('   Прошивка: ${deviceInfo.firmwareRevision}');
      print('   ПО: ${deviceInfo.softwareRevision}\n');
    }

    // Батарея
    print('🔋 Уровень батареи:');
    final battery = await healthService.getBatteryLevel(deviceId);
    if (battery != null) {
      print('   Заряд: ${battery.level}%');
      print('   Статус: ${battery.status}');
      print('   Состояние: ${battery.batteryLevelString}\n');
    }

    // Шаги
    print('🚶 Активность:');
    final steps = await healthService.getSteps(deviceId);
    if (steps != null) {
      print('   Шаги: ${steps.steps}');
      print('   Дистанция: ${steps.distance?.toStringAsFixed(2)} км');
      print('   Калории: ${steps.calories}\n');
    }

    // Температура тела
    print('🌡️ Температура тела:');
    final temp = await healthService.getBodyTemperature(deviceId);
    if (temp != null) {
      print('   ${temp.celsius.toStringAsFixed(1)}°C\n');
    } else {
      print('   Не поддерживается устройством\n');
    }

    // SpO2
    print('🫁 Сатурация кислорода:');
    final spo2 = await healthService.getOxygenSaturation(deviceId);
    if (spo2 != null) {
      print('   ${spo2.percentage}%\n');
    } else {
      print('   Не поддерживается устройством\n');
    }

    await bluetoothService.disconnectFromDevice(deviceId);
    print('✅ Готово\n');
  }

  /// Пример 4: Сравнение данных с разных устройств
  static Future<void> compareDevices() async {
    print('\n=== Пример 4: Сравнение Устройств ===\n');

    final bluetoothService = CompositionRoot.get<BluetoothService>();
    final healthService = CompositionRoot.get<SmartwatchDataService>();

    final devices = [
      ('mock_apple_watch_series_9', 'Apple Watch Series 9'),
      ('mock_samsung_galaxy_watch_6', 'Galaxy Watch6'),
      ('mock_garmin_fenix_7', 'Garmin Fenix 7'),
      ('mock_fitbit_sense_2', 'Fitbit Sense 2'),
    ];

    print('📊 Сравнение показателей:\n');
    print('${'Устройство'.padRight(25)} | Пульс | Батарея | Шаги  | SpO2');
    print('-' * 65);

    for (final (deviceId, deviceName) in devices) {
      await bluetoothService.connectToDevice(deviceId);

      // Получаем данные
      final heartRate = await healthService
          .subscribeToHeartRate(deviceId)
          .first;
      final battery = await healthService.getBatteryLevel(deviceId);
      final steps = await healthService.getSteps(deviceId);
      final spo2 = await healthService.getOxygenSaturation(deviceId);

      // Форматируем строку
      final hr = '${heartRate.bpm}'.padLeft(3);
      final bat = '${battery?.level ?? 0}%'.padLeft(3);
      final st = '${steps?.steps ?? 0}'.padLeft(5);
      final sp = spo2 != null ? '${spo2.percentage}%'.padLeft(3) : ' - ';

      print('${deviceName.padRight(25)} | $hr   | $bat     | $st | $sp');

      await healthService.unsubscribeAll(deviceId);
      await bluetoothService.disconnectFromDevice(deviceId);

      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('\n✅ Сравнение завершено\n');
  }

  /// Пример 5: Мониторинг всех метрик в реальном времени
  static Future<void> realTimeMonitoring() async {
    print('\n=== Пример 5: Мониторинг в Реальном Времени ===\n');

    final bluetoothService = CompositionRoot.get<BluetoothService>();
    final healthService = CompositionRoot.get<SmartwatchDataService>();

    const deviceId = 'mock_apple_watch_ultra_2';
    const deviceName = 'Apple Watch Ultra 2';

    print('🔗 Подключаемся к $deviceName...\n');
    await bluetoothService.connectToDevice(deviceId);

    print('📊 Мониторинг (15 секунд):\n');
    print('Время     | Пульс | Батарея');
    print('-' * 35);

    var heartRateValue = 0;
    var batteryValue = 0;

    // Подписки
    final hrSub = healthService
        .subscribeToHeartRate(deviceId)
        .listen((data) => heartRateValue = data.bpm);

    final batSub = healthService
        .subscribeToBattery(deviceId)
        .listen((data) => batteryValue = data.level);

    // Вывод каждые 2 секунды
    for (var i = 0; i < 7; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final time = _formatTime(DateTime.now());
      print(
        '$time | ${heartRateValue.toString().padLeft(3)} BPM | ${batteryValue.toString().padLeft(3)}%',
      );
    }

    await hrSub.cancel();
    await batSub.cancel();
    await healthService.unsubscribeAll(deviceId);
    await bluetoothService.disconnectFromDevice(deviceId);

    print('\n✅ Мониторинг завершен\n');
  }

  /// Вспомогательная функция форматирования времени
  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  /// Запуск всех примеров
  static Future<void> runAllExamples() async {
    print('\n' + '=' * 70);
    print('  ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ MOCK SERVICES');
    print('=' * 70);

    try {
      await scanForMockDevices();
      await connectAndMonitorHeartRate();
      await getAllHealthData();
      await compareDevices();
      await realTimeMonitoring();

      print('\n' + '=' * 70);
      print('  ВСЕ ПРИМЕРЫ УСПЕШНО ВЫПОЛНЕНЫ');
      print('=' * 70 + '\n');
    } catch (e, stackTrace) {
      print('\n❌ Ошибка: $e');
      print('Stack trace: $stackTrace');
    }
  }
}

/// Точка входа для запуска примеров
/// Раскомментируйте main() для тестирования
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация DI
  await CompositionRoot.init();
  
  // Убедитесь, что в composition_root.dart установлено:
  // static const bool useMockServices = true;
  
  // Запуск всех примеров
  await MockServicesExample.runAllExamples();
  
  // Или запустите отдельные примеры:
  // await MockServicesExample.scanForMockDevices();
  // await MockServicesExample.connectAndMonitorHeartRate();
  // await MockServicesExample.getAllHealthData();
  // await MockServicesExample.compareDevices();
  // await MockServicesExample.realTimeMonitoring();
}
*/
