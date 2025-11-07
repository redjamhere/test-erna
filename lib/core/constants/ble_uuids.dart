/// Стандартные UUID сервисов и характеристик Bluetooth Low Energy
/// Основано на спецификации GATT (Generic Attribute Profile)
class BleUuids {
  BleUuids._();

  // ============ Стандартные GATT сервисы ============

  /// Generic Access Service
  static const String genericAccess = '00001800-0000-1000-8000-00805f9b34fb';

  /// Generic Attribute Service
  static const String genericAttribute = '00001801-0000-1000-8000-00805f9b34fb';

  /// Device Information Service
  static const String deviceInformation =
      '0000180a-0000-1000-8000-00805f9b34fb';

  /// Battery Service
  static const String battery = '0000180f-0000-1000-8000-00805f9b34fb';

  /// Heart Rate Service
  static const String heartRate = '0000180d-0000-1000-8000-00805f9b34fb';

  /// Health Thermometer Service
  static const String healthThermometer =
      '00001809-0000-1000-8000-00805f9b34fb';

  /// Blood Pressure Service
  static const String bloodPressure = '00001810-0000-1000-8000-00805f9b34fb';

  /// Glucose Service
  static const String glucose = '00001808-0000-1000-8000-00805f9b34fb';

  /// Running Speed and Cadence Service
  static const String runningSpeedCadence =
      '00001814-0000-1000-8000-00805f9b34fb';

  /// Cycling Speed and Cadence Service
  static const String cyclingSpeedCadence =
      '00001816-0000-1000-8000-00805f9b34fb';

  /// User Data Service
  static const String userData = '0000181c-0000-1000-8000-00805f9b34fb';

  /// Body Composition Service
  static const String bodyComposition = '0000181b-0000-1000-8000-00805f9b34fb';

  /// Current Time Service
  static const String currentTime = '00001805-0000-1000-8000-00805f9b34fb';

  // ============ Характеристики Heart Rate Service ============

  /// Heart Rate Measurement (notify)
  static const String heartRateMeasurement =
      '00002a37-0000-1000-8000-00805f9b34fb';

  /// Body Sensor Location (read)
  static const String bodySensorLocation =
      '00002a38-0000-1000-8000-00805f9b34fb';

  /// Heart Rate Control Point (write)
  static const String heartRateControlPoint =
      '00002a39-0000-1000-8000-00805f9b34fb';

  // ============ Характеристики Battery Service ============

  /// Battery Level (read, notify)
  static const String batteryLevel = '00002a19-0000-1000-8000-00805f9b34fb';

  // ============ Характеристики Device Information ============

  /// Manufacturer Name (read)
  static const String manufacturerName = '00002a29-0000-1000-8000-00805f9b34fb';

  /// Model Number (read)
  static const String modelNumber = '00002a24-0000-1000-8000-00805f9b34fb';

  /// Serial Number (read)
  static const String serialNumber = '00002a25-0000-1000-8000-00805f9b34fb';

  /// Hardware Revision (read)
  static const String hardwareRevision = '00002a27-0000-1000-8000-00805f9b34fb';

  /// Firmware Revision (read)
  static const String firmwareRevision = '00002a26-0000-1000-8000-00805f9b34fb';

  /// Software Revision (read)
  static const String softwareRevision = '00002a28-0000-1000-8000-00805f9b34fb';

  // ============ Пользовательские UUID (примеры для кастомных устройств) ============

  /// Шаги (для умных часов)
  /// Примечание: Это не стандартный UUID, каждый производитель может использовать свой
  static const String steps = '00002a53-0000-1000-8000-00805f9b34fb';

  /// Расстояние
  static const String distance = '00002a69-0000-1000-8000-00805f9b34fb';

  /// Калории
  static const String calories = '00002a6a-0000-1000-8000-00805f9b34fb';

  /// SpO2 (кислород в крови)
  /// Примечание: Не стандартизировано, может отличаться у производителей
  static const String oxygenSaturation = '00002a5f-0000-1000-8000-00805f9b34fb';

  /// Температура тела
  static const String bodyTemperature = '00002a1c-0000-1000-8000-00805f9b34fb';

  // ============ Вспомогательные методы ============

  /// Проверить, является ли UUID стандартным сервисом здоровья
  static bool isHealthService(String uuid) {
    final normalized = uuid.toLowerCase();
    return normalized == heartRate.toLowerCase() ||
        normalized == healthThermometer.toLowerCase() ||
        normalized == bloodPressure.toLowerCase() ||
        normalized == glucose.toLowerCase() ||
        normalized == bodyComposition.toLowerCase();
  }

  /// Проверить, является ли UUID сервисом информации об устройстве
  static bool isDeviceInfoService(String uuid) {
    return uuid.toLowerCase() == deviceInformation.toLowerCase();
  }

  /// Проверить, является ли UUID сервисом батареи
  static bool isBatteryService(String uuid) {
    return uuid.toLowerCase() == battery.toLowerCase();
  }

  /// Получить имя сервиса по UUID
  static String getServiceName(String uuid) {
    final normalized = uuid.toLowerCase();

    if (normalized == heartRate.toLowerCase()) return 'Пульс';
    if (normalized == battery.toLowerCase()) return 'Батарея';
    if (normalized == deviceInformation.toLowerCase()) {
      return 'Информация об устройстве';
    }
    if (normalized == healthThermometer.toLowerCase()) return 'Термометр';
    if (normalized == bloodPressure.toLowerCase()) return 'Давление';
    if (normalized == runningSpeedCadence.toLowerCase()) return 'Бег';
    if (normalized == cyclingSpeedCadence.toLowerCase()) return 'Велосипед';
    if (normalized == bodyComposition.toLowerCase()) return 'Состав тела';

    return 'Неизвестный сервис';
  }

  /// Получить имя характеристики по UUID
  static String getCharacteristicName(String uuid) {
    final normalized = uuid.toLowerCase();

    if (normalized == heartRateMeasurement.toLowerCase()) {
      return 'Измерение пульса';
    }
    if (normalized == batteryLevel.toLowerCase()) return 'Уровень батареи';
    if (normalized == manufacturerName.toLowerCase()) return 'Производитель';
    if (normalized == modelNumber.toLowerCase()) return 'Модель';
    if (normalized == serialNumber.toLowerCase()) return 'Серийный номер';
    if (normalized == bodyTemperature.toLowerCase()) return 'Температура';
    if (normalized == oxygenSaturation.toLowerCase()) return 'SpO2';
    if (normalized == steps.toLowerCase()) return 'Шаги';
    if (normalized == distance.toLowerCase()) return 'Расстояние';
    if (normalized == calories.toLowerCase()) return 'Калории';

    return 'Неизвестная характеристика';
  }
}

/// Дескрипторы GATT
class BleDescriptors {
  BleDescriptors._();

  /// Client Characteristic Configuration Descriptor (для включения/отключения уведомлений)
  static const String clientCharacteristicConfiguration =
      '00002902-0000-1000-8000-00805f9b34fb';

  /// Characteristic User Description Descriptor
  static const String characteristicUserDescription =
      '00002901-0000-1000-8000-00805f9b34fb';
}
