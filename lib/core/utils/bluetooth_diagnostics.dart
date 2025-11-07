import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../service/bluetooth_service.dart' as bt;
import '../service/smartwatch_data_service.dart';

/// Утилита для диагностики проблем с подключением к BLE устройствам
class BluetoothDiagnostics {
  final bt.BluetoothService _bluetoothService;
  final SmartwatchDataService _smartwatchDataService;

  BluetoothDiagnostics(this._bluetoothService, this._smartwatchDataService);

  /// Запустить полную диагностику устройства
  Future<DiagnosticReport> diagnoseDevice(String deviceId) async {
    final report = DiagnosticReport(deviceId: deviceId);

    print('🔍 ===== НАЧАЛО ДИАГНОСТИКИ УСТРОЙСТВА =====');
    print('Device ID: $deviceId');

    // 1. Проверка Bluetooth
    report.bluetoothEnabled = await _bluetoothService.isBluetoothEnabled();
    print('1️⃣ Bluetooth включен: ${report.bluetoothEnabled}');

    if (!report.bluetoothEnabled) {
      print('❌ Bluetooth выключен! Включите Bluetooth.');
      return report;
    }

    // 2. Проверка устройства
    final device = _bluetoothService.getDevice(deviceId);
    report.deviceFound = device != null;
    print('2️⃣ Устройство найдено: ${report.deviceFound}');

    if (!report.deviceFound) {
      print('❌ Устройство не найдено в списке обнаруженных устройств');
      return report;
    }

    // 3. Проверка подключения
    try {
      final connectionState = await device!.connectionState.first;
      report.isConnected =
          connectionState == BluetoothConnectionState.connected;
      print('3️⃣ Устройство подключено: ${report.isConnected}');

      if (!report.isConnected) {
        print('⚠️ Устройство не подключено. Попытка подключения...');
        final connected = await _bluetoothService.connectToDevice(deviceId);
        report.connectionAttempted = true;
        report.connectionSuccessful = connected;
        print(
          '   Результат подключения: ${connected ? "✅ Успешно" : "❌ Неудачно"}',
        );

        if (!connected) {
          return report;
        }
      }
    } catch (e) {
      print('❌ Ошибка при проверке подключения: $e');
      report.errors.add('Connection check error: $e');
      return report;
    }

    // 4. Обнаружение сервисов
    print('4️⃣ Обнаружение сервисов...');
    try {
      final services = await device.discoverServices();
      report.servicesCount = services.length;
      print('   Найдено сервисов: ${services.length}');

      // Детальный вывод всех сервисов
      for (var service in services) {
        final serviceUuid = service.uuid.toString();
        print('   📦 Сервис: $serviceUuid');
        report.availableServices.add(serviceUuid);

        for (var char in service.characteristics) {
          final charUuid = char.uuid.toString();
          final props = char.properties;
          print('      📋 Характеристика: $charUuid');
          print(
            '         Свойства: R=${props.read}, W=${props.write}, N=${props.notify}, I=${props.indicate}',
          );
          report.availableCharacteristics.add(charUuid);
        }
      }
    } catch (e) {
      print('❌ Ошибка при обнаружении сервисов: $e');
      report.errors.add('Service discovery error: $e');
      return report;
    }

    // 5. Проверка стандартных GATT сервисов
    print('5️⃣ Проверка стандартных GATT сервисов:');

    // Heart Rate Service
    report.hasHeartRateService = report.availableServices.any(
      (uuid) => uuid.toLowerCase().contains('0000180d'),
    );
    print(
      '   ❤️  Heart Rate Service (0x180D): ${report.hasHeartRateService ? "✅" : "❌"}',
    );

    // Battery Service
    report.hasBatteryService = report.availableServices.any(
      (uuid) => uuid.toLowerCase().contains('0000180f'),
    );
    print(
      '   🔋 Battery Service (0x180F): ${report.hasBatteryService ? "✅" : "❌"}',
    );

    // Device Information Service
    report.hasDeviceInfoService = report.availableServices.any(
      (uuid) => uuid.toLowerCase().contains('0000180a'),
    );
    print(
      '   ℹ️  Device Info Service (0x180A): ${report.hasDeviceInfoService ? "✅" : "❌"}',
    );

    // 6. Попытка получить данные
    print('6️⃣ Попытка получить данные:');

    // Тест Heart Rate
    if (report.hasHeartRateService) {
      try {
        print('   Подписка на Heart Rate...');
        final heartRateStream = _smartwatchDataService.subscribeToHeartRate(
          deviceId,
        );

        final heartRateData = await heartRateStream
            .timeout(
              const Duration(seconds: 10),
              onTimeout: (sink) {
                print('   ⏱️ Timeout при получении данных о пульсе');
                sink.close();
              },
            )
            .first;

        report.heartRateDataReceived = true;
        report.heartRateValue = heartRateData.bpm;
        print('   ✅ Пульс получен: ${heartRateData.bpm} BPM');
      } catch (e) {
        print('   ❌ Ошибка при получении пульса: $e');
        report.errors.add('Heart rate error: $e');
      }
    }

    // Тест Battery
    if (report.hasBatteryService) {
      try {
        print('   Чтение уровня батареи...');
        final battery = await _smartwatchDataService.getBatteryLevel(deviceId);
        if (battery != null) {
          report.batteryDataReceived = true;
          report.batteryLevel = battery.level;
          print('   ✅ Батарея получена: ${battery.level}%');
        } else {
          print('   ⚠️ Батарея не получена (null)');
        }
      } catch (e) {
        print('   ❌ Ошибка при получении батареи: $e');
        report.errors.add('Battery error: $e');
      }
    }

    // 7. Определение типа устройства
    print('7️⃣ Определение типа устройства:');
    report.deviceType = _determineDeviceType(report);
    print('   Тип: ${report.deviceType}');

    print('🔍 ===== КОНЕЦ ДИАГНОСТИКИ =====\n');

    return report;
  }

  String _determineDeviceType(DiagnosticReport report) {
    if (report.availableServices.isEmpty) {
      return 'Неизвестно (нет сервисов)';
    }

    // Проприетарные протоколы
    if (report.availableServices.any(
      (uuid) => uuid.contains('0000fee0') || uuid.contains('0000fee1'),
    )) {
      return 'Проприетарный (Amazfit/Huami/Zepp)';
    }

    // Стандартный GATT
    if (report.hasHeartRateService || report.hasBatteryService) {
      return 'Стандартный GATT';
    }

    // Huawei специфичный
    if (report.availableServices.any(
      (uuid) => uuid.toLowerCase().contains('huawei'),
    )) {
      return 'Huawei проприетарный';
    }

    return 'Неизвестный тип';
  }

  /// Напечатать краткий отчет
  void printSummary(DiagnosticReport report) {
    print('\n📊 ===== КРАТКИЙ ОТЧЕТ ДИАГНОСТИКИ =====');
    print('Device ID: ${report.deviceId}');
    print('Bluetooth: ${report.bluetoothEnabled ? "✅" : "❌"}');
    print('Устройство найдено: ${report.deviceFound ? "✅" : "❌"}');
    print('Подключено: ${report.isConnected ? "✅" : "❌"}');
    print('Сервисов найдено: ${report.servicesCount}');
    print('Тип устройства: ${report.deviceType}');
    print('\nПоддержка стандартных сервисов:');
    print('  Heart Rate: ${report.hasHeartRateService ? "✅" : "❌"}');
    print('  Battery: ${report.hasBatteryService ? "✅" : "❌"}');
    print('  Device Info: ${report.hasDeviceInfoService ? "✅" : "❌"}');
    print('\nДанные получены:');
    print(
      '  Пульс: ${report.heartRateDataReceived ? "✅ (${report.heartRateValue} BPM)" : "❌"}',
    );
    print(
      '  Батарея: ${report.batteryDataReceived ? "✅ (${report.batteryLevel}%)" : "❌"}',
    );

    if (report.errors.isNotEmpty) {
      print('\n❌ Ошибки:');
      for (var error in report.errors) {
        print('  - $error');
      }
    }

    print('\n🔧 Рекомендации:');
    if (!report.bluetoothEnabled) {
      print('  - Включите Bluetooth на устройстве');
    }
    if (!report.deviceFound) {
      print('  - Убедитесь, что устройство в зоне действия');
      print('  - Попробуйте запустить сканирование заново');
    }
    if (!report.isConnected &&
        report.connectionAttempted &&
        !report.connectionSuccessful) {
      print('  - Перезагрузите Bluetooth устройство (часы)');
      print('  - Удалите устройство из списка Bluetooth и подключитесь заново');
    }
    if (report.servicesCount == 0) {
      print('  - Устройство не предоставляет сервисы');
      print('  - Возможно, требуется авторизация или сопряжение');
    }
    if (!report.hasHeartRateService && !report.hasBatteryService) {
      print('  - Устройство не поддерживает стандартные GATT сервисы');
      print('  - Используется проприетарный протокол');
      print('  - Требуется специальная реализация для этого производителя');
    }
    if (report.hasHeartRateService && !report.heartRateDataReceived) {
      print('  - Heart Rate сервис найден, но данные не получены');
      print('  - Проверьте, включен ли мониторинг пульса на часах');
      print('  - Убедитесь, что часы надеты на руку');
    }

    print('========================================\n');
  }
}

/// Отчет диагностики
class DiagnosticReport {
  final String deviceId;
  bool bluetoothEnabled = false;
  bool deviceFound = false;
  bool isConnected = false;
  bool connectionAttempted = false;
  bool connectionSuccessful = false;
  int servicesCount = 0;
  List<String> availableServices = [];
  List<String> availableCharacteristics = [];
  bool hasHeartRateService = false;
  bool hasBatteryService = false;
  bool hasDeviceInfoService = false;
  bool heartRateDataReceived = false;
  int? heartRateValue;
  bool batteryDataReceived = false;
  int? batteryLevel;
  String deviceType = 'Неизвестно';
  List<String> errors = [];

  DiagnosticReport({required this.deviceId});
}
