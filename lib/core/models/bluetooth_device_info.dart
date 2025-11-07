import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Состояние подключения устройства
enum DeviceConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

/// Информация о Bluetooth устройстве
class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int rssi; // Уровень сигнала
  final DeviceConnectionState connectionState;
  final BluetoothDevice? device;
  final DateTime lastSeen;

  const BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.connectionState,
    this.device,
    required this.lastSeen,
  });

  BluetoothDeviceInfo copyWith({
    String? id,
    String? name,
    int? rssi,
    DeviceConnectionState? connectionState,
    BluetoothDevice? device,
    DateTime? lastSeen,
  }) {
    return BluetoothDeviceInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      connectionState: connectionState ?? this.connectionState,
      device: device ?? this.device,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Получить строку состояния подключения
  String get connectionStateString {
    switch (connectionState) {
      case DeviceConnectionState.disconnected:
        return 'Отключено';
      case DeviceConnectionState.connecting:
        return 'Подключение...';
      case DeviceConnectionState.connected:
        return 'Подключено';
      case DeviceConnectionState.disconnecting:
        return 'Отключение...';
    }
  }

  /// Получить строку уровня сигнала
  String get signalStrengthString {
    if (rssi >= -50) return 'Отличный';
    if (rssi >= -70) return 'Хороший';
    if (rssi >= -85) return 'Удовлетворительный';
    return 'Слабый';
  }

  @override
  String toString() {
    return 'BluetoothDeviceInfo(id: $id, name: $name, rssi: $rssi, state: $connectionState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BluetoothDeviceInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
