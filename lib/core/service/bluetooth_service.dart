import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/bluetooth_device_info.dart';

/// Абстрактный интерфейс для Bluetooth сервиса
abstract interface class BluetoothService {
  Future<bool> isBluetoothEnabled();
  Future<bool> enableBluetooth();
  Stream<BluetoothAdapterState> get bluetoothState;
  Future<void> startScan({Duration timeout});
  Future<void> stopScan();
  Stream<List<BluetoothDeviceInfo>> get devicesStream;
  Stream<bool> get isScanningStream;
  Future<bool> connectToDevice(String deviceId);
  Future<void> disconnectFromDevice(String deviceId);
  Future<List<BluetoothDeviceInfo>> getConnectedDevices();
  Stream<DeviceConnectionState> getDeviceConnectionState(String deviceId);
  BluetoothDevice? getDevice(String deviceId);
  void clearDevices();
  Future<void> dispose();
}

/// Реализация Bluetooth сервиса
class BluetoothServiceImpl implements BluetoothService {
  // ignore: unused_field
  final FlutterBluePlus _flutterBluePlus;
  final Map<String, BluetoothDevice> _connectedDevices = {};
  final Map<String, BluetoothDeviceInfo> _discoveredDevices = {};
  final _devicesStreamController =
      StreamController<List<BluetoothDeviceInfo>>.broadcast();
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  BluetoothServiceImpl(this._flutterBluePlus);

  @override
  Future<bool> isBluetoothEnabled() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> enableBluetooth() async {
    try {
      if (await isBluetoothEnabled()) return true;
      await FlutterBluePlus.turnOn();
      await Future.delayed(const Duration(seconds: 1));
      return await isBluetoothEnabled();
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<BluetoothAdapterState> get bluetoothState =>
      FlutterBluePlus.adapterState;

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!await isBluetoothEnabled()) throw Exception('Bluetooth не включен');
    await stopScan();
    _discoveredDevices.clear();
    _devicesStreamController.add([]);

    // Сначала добавляем системные устройства (уже подключенные)
    try {
      final systemDevices = await FlutterBluePlus.systemDevices([]);
      print('📱 Найдено системных устройств: ${systemDevices.length}');
      for (final device in systemDevices) {
        final deviceId = device.remoteId.toString();
        final connectionState = await device.connectionState.first;
        _discoveredDevices[deviceId] = BluetoothDeviceInfo(
          id: deviceId,
          name: device.platformName.isNotEmpty
              ? device.platformName
              : 'Неизвестное устройство',
          rssi: -50, // Для системных устройств RSSI недоступен
          connectionState: connectionState == BluetoothConnectionState.connected
              ? DeviceConnectionState.connected
              : DeviceConnectionState.disconnected,
          device: device,
          lastSeen: DateTime.now(),
        );
        print(
          '  - ${device.platformName} ($deviceId) - ${connectionState == BluetoothConnectionState.connected ? "подключено" : "отключено"}',
        );
      }
      _devicesStreamController.add(_discoveredDevices.values.toList());
    } catch (e) {
      print('⚠️ Ошибка при получении системных устройств: $e');
    }

    // Затем начинаем сканирование новых устройств
    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );
    _scanSubscription = FlutterBluePlus.scanResults.listen(_handleScanResults);
  }

  void _handleScanResults(List<ScanResult> results) {
    for (final result in results) {
      final device = result.device;
      final deviceId = device.remoteId.toString();
      _discoveredDevices[deviceId] = BluetoothDeviceInfo(
        id: deviceId,
        name: device.platformName.isNotEmpty
            ? device.platformName
            : 'Неизвестное устройство',
        rssi: result.rssi,
        connectionState: _connectedDevices.containsKey(deviceId)
            ? DeviceConnectionState.connected
            : DeviceConnectionState.disconnected,
        device: device,
        lastSeen: DateTime.now(),
      );
    }
    _devicesStreamController.add(_discoveredDevices.values.toList());
  }

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (await FlutterBluePlus.isScanning.first)
      await FlutterBluePlus.stopScan();
  }

  @override
  Stream<List<BluetoothDeviceInfo>> get devicesStream =>
      _devicesStreamController.stream;

  @override
  Stream<bool> get isScanningStream => FlutterBluePlus.isScanning;

  @override
  Future<bool> connectToDevice(String deviceId) async {
    try {
      final device = _discoveredDevices[deviceId]?.device;
      if (device == null) throw Exception('Устройство не найдено');

      _updateDeviceState(deviceId, DeviceConnectionState.connecting);

      // Проверяем, не подключено ли устройство уже через систему
      final currentState = await device.connectionState.first;
      if (currentState == BluetoothConnectionState.connected) {
        print(
          '✅ Устройство уже подключено через систему, используем существующее соединение',
        );
        _connectedDevices[deviceId] = device;
        _updateDeviceState(deviceId, DeviceConnectionState.connected);
        return true;
      }

      // Если есть активное системное подключение, сначала отключаемся
      try {
        final systemDevices = await FlutterBluePlus.systemDevices([]);
        final systemDevice = systemDevices.firstWhere(
          (d) => d.remoteId.toString() == deviceId,
          orElse: () => throw Exception('not found'),
        );

        final systemState = await systemDevice.connectionState.first;
        if (systemState == BluetoothConnectionState.connected) {
          print('⚠️ Обнаружено системное подключение, отключаемся...');
          await systemDevice.disconnect();
          // Даем время на отключение
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        // Устройство не найдено в системных - это нормально
      }

      // Подключаемся к устройству
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      _connectedDevices[deviceId] = device;
      _updateDeviceState(deviceId, DeviceConnectionState.connected);
      print('✅ Успешно подключено к устройству: $deviceId');
      return true;
    } catch (e) {
      print('❌ Ошибка подключения к устройству: $e');
      _updateDeviceState(deviceId, DeviceConnectionState.disconnected);
      rethrow; // Пробрасываем ошибку для отображения пользователю
    }
  }

  @override
  Future<void> disconnectFromDevice(String deviceId) async {
    try {
      final device = _connectedDevices[deviceId];
      if (device == null) return;
      _updateDeviceState(deviceId, DeviceConnectionState.disconnecting);
      await device.disconnect();
      _connectedDevices.remove(deviceId);
      _updateDeviceState(deviceId, DeviceConnectionState.disconnected);
    } catch (e) {
      _updateDeviceState(deviceId, DeviceConnectionState.disconnected);
    }
  }

  void _updateDeviceState(String deviceId, DeviceConnectionState state) {
    final deviceInfo = _discoveredDevices[deviceId];
    if (deviceInfo != null) {
      _discoveredDevices[deviceId] = deviceInfo.copyWith(
        connectionState: state,
      );
      _devicesStreamController.add(_discoveredDevices.values.toList());
    }
  }

  @override
  Future<List<BluetoothDeviceInfo>> getConnectedDevices() async {
    try {
      final systemDevices = await FlutterBluePlus.systemDevices([]);
      final connectedDevicesList = <BluetoothDeviceInfo>[];
      for (final device in systemDevices) {
        final isConnected =
            await device.connectionState.first ==
            BluetoothConnectionState.connected;
        if (isConnected) {
          connectedDevicesList.add(
            BluetoothDeviceInfo(
              id: device.remoteId.toString(),
              name: device.platformName.isNotEmpty
                  ? device.platformName
                  : 'Неизвестное устройство',
              rssi: 0,
              connectionState: DeviceConnectionState.connected,
              device: device,
              lastSeen: DateTime.now(),
            ),
          );
        }
      }
      return connectedDevicesList;
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<DeviceConnectionState> getDeviceConnectionState(String deviceId) {
    final device =
        _discoveredDevices[deviceId]?.device ?? _connectedDevices[deviceId];
    if (device == null) return Stream.value(DeviceConnectionState.disconnected);
    return device.connectionState.map(
      (state) => state == BluetoothConnectionState.connected
          ? DeviceConnectionState.connected
          : DeviceConnectionState.disconnected,
    );
  }

  @override
  BluetoothDevice? getDevice(String deviceId) =>
      _discoveredDevices[deviceId]?.device ?? _connectedDevices[deviceId];

  @override
  void clearDevices() {
    _discoveredDevices.clear();
    _devicesStreamController.add([]);
  }

  @override
  Future<void> dispose() async {
    await stopScan();
    await _scanSubscription?.cancel();
    await _devicesStreamController.close();
    for (final device in _connectedDevices.values) {
      try {
        await device.disconnect();
      } catch (e) {}
    }
    _connectedDevices.clear();
  }
}
