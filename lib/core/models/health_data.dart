/// Данные о сердечном ритме
class HeartRateData {
  final int bpm; // Ударов в минуту
  final DateTime timestamp;
  final int? energyExpended; // Калории (опционально)
  final List<int>? rrIntervals; // R-R интервалы для HRV (опционально)

  const HeartRateData({
    required this.bpm,
    required this.timestamp,
    this.energyExpended,
    this.rrIntervals,
  });

  /// Получить строку состояния ЧСС
  String get heartRateZone {
    if (bpm < 60) return 'Низкий';
    if (bpm < 100) return 'Нормальный';
    if (bpm < 140) return 'Повышенный';
    if (bpm < 180) return 'Высокий';
    return 'Очень высокий';
  }

  @override
  String toString() => 'HeartRateData(bpm: $bpm, timestamp: $timestamp)';
}

/// Данные о шагах
class StepsData {
  final int steps;
  final DateTime timestamp;
  final double? distance; // в километрах
  final int? calories; // сожженные калории

  const StepsData({
    required this.steps,
    required this.timestamp,
    this.distance,
    this.calories,
  });

  @override
  String toString() => 'StepsData(steps: $steps, distance: $distance km)';
}

/// Данные о батарее
class BatteryData {
  final int level; // Уровень заряда (0-100)
  final DateTime timestamp;
  final BatteryStatus? status;

  const BatteryData({
    required this.level,
    required this.timestamp,
    this.status,
  });

  /// Получить строку состояния батареи
  String get batteryLevelString {
    if (level >= 80) return 'Высокий';
    if (level >= 50) return 'Средний';
    if (level >= 20) return 'Низкий';
    return 'Критический';
  }

  @override
  String toString() => 'BatteryData(level: $level%, status: $status)';
}

/// Статус батареи
enum BatteryStatus { unknown, charging, discharging, full, notCharging }

/// Данные о сне
class SleepData {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final SleepQuality quality;
  final Map<SleepStage, Duration>? stages; // Фазы сна

  const SleepData({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.quality,
    this.stages,
  });

  /// Получить количество часов сна
  double get hoursSlept => duration.inMinutes / 60.0;

  @override
  String toString() =>
      'SleepData(duration: ${hoursSlept.toStringAsFixed(1)}h, quality: $quality)';
}

/// Качество сна
enum SleepQuality { poor, fair, good, excellent }

/// Фазы сна
enum SleepStage { awake, light, deep, rem }

/// Данные о калориях
class CaloriesData {
  final int total; // Всего калорий
  final int active; // Активные калории
  final int resting; // Калории в покое
  final DateTime timestamp;

  const CaloriesData({
    required this.total,
    required this.active,
    required this.resting,
    required this.timestamp,
  });

  @override
  String toString() => 'CaloriesData(total: $total, active: $active)';
}

/// Данные о кислороде в крови (SpO2)
class OxygenSaturationData {
  final int percentage; // Процент кислорода в крови (обычно 95-100%)
  final DateTime timestamp;

  const OxygenSaturationData({
    required this.percentage,
    required this.timestamp,
  });

  /// Получить строку состояния SpO2
  String get saturationStatus {
    if (percentage >= 95) return 'Нормальный';
    if (percentage >= 90) return 'Низкий';
    return 'Критический';
  }

  @override
  String toString() => 'OxygenSaturationData($percentage%)';
}

/// Данные о температуре тела
class BodyTemperatureData {
  final double celsius;
  final DateTime timestamp;

  const BodyTemperatureData({required this.celsius, required this.timestamp});

  double get fahrenheit => (celsius * 9 / 5) + 32;

  /// Получить строку состояния температуры
  String get temperatureStatus {
    if (celsius < 36.0) return 'Низкая';
    if (celsius < 37.5) return 'Нормальная';
    if (celsius < 38.0) return 'Повышенная';
    return 'Высокая';
  }

  @override
  String toString() => 'BodyTemperatureData(${celsius.toStringAsFixed(1)}°C)';
}

/// Данные о стрессе
class StressData {
  final int level; // Уровень стресса (0-100)
  final DateTime timestamp;
  final StressLevel category;

  const StressData({
    required this.level,
    required this.timestamp,
    required this.category,
  });

  @override
  String toString() => 'StressData(level: $level, category: $category)';
}

/// Категории уровня стресса
enum StressLevel { relaxed, low, medium, high }

/// Данные о активности
class ActivityData {
  final ActivityType type;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double? distance; // в километрах
  final int? calories;
  final int? averageHeartRate;

  const ActivityData({
    required this.type,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.distance,
    this.calories,
    this.averageHeartRate,
  });

  @override
  String toString() => 'ActivityData(type: $type, duration: $duration)';
}

/// Типы активности
enum ActivityType { walking, running, cycling, swimming, workout, yoga, other }
