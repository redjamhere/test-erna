import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import '../models/bluetooth_device_info.dart';
import 'bluetooth_service.dart' as bt;

/// Mock Bluetooth Service для тестирования без физических устройств
class MockBluetoothService implements bt.BluetoothService {
  final Map<String, BluetoothDeviceInfo> _mockDevices = {};
  final Map<String, BluetoothDeviceInfo> _connectedDevices = {};
  final _devicesStreamController =
      StreamController<List<BluetoothDeviceInfo>>.broadcast();
  final _isScanningController = StreamController<bool>.broadcast();
  final _connectionStateControllers =
      <String, StreamController<DeviceConnectionState>>{};

  bool _isScanning = false;
  bool _isBluetoothEnabled = true;
  Timer? _scanTimer;
  final Random _random = Random();

  MockBluetoothService() {
    _initializeMockDevices();
  }

  /// Инициализация списка mock устройств
  void _initializeMockDevices() {
    final now = DateTime.now();

    _mockDevices.addAll({
      // Samsung Galaxy Watch
      'mock_samsung_galaxy_watch_6': BluetoothDeviceInfo(
        id: 'mock_samsung_galaxy_watch_6',
        name: 'Galaxy Watch6',
        rssi: -45 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_samsung_galaxy_watch_5': BluetoothDeviceInfo(
        id: 'mock_samsung_galaxy_watch_5',
        name: 'Galaxy Watch5 Pro',
        rssi: -52 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Apple Watch
      'mock_apple_watch_series_9': BluetoothDeviceInfo(
        id: 'mock_apple_watch_series_9',
        name: 'Apple Watch Series 9',
        rssi: -48 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_apple_watch_ultra_2': BluetoothDeviceInfo(
        id: 'mock_apple_watch_ultra_2',
        name: 'Apple Watch Ultra 2',
        rssi: -50 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Fitbit
      'mock_fitbit_sense_2': BluetoothDeviceInfo(
        id: 'mock_fitbit_sense_2',
        name: 'Fitbit Sense 2',
        rssi: -55 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_fitbit_versa_4': BluetoothDeviceInfo(
        id: 'mock_fitbit_versa_4',
        name: 'Fitbit Versa 4',
        rssi: -58 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Garmin
      'mock_garmin_fenix_7': BluetoothDeviceInfo(
        id: 'mock_garmin_fenix_7',
        name: 'Garmin Fenix 7',
        rssi: -47 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_garmin_forerunner_965': BluetoothDeviceInfo(
        id: 'mock_garmin_forerunner_965',
        name: 'Garmin Forerunner 965',
        rssi: -53 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Amazfit
      'mock_amazfit_gtr_4': BluetoothDeviceInfo(
        id: 'mock_amazfit_gtr_4',
        name: 'Amazfit GTR 4',
        rssi: -60 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_amazfit_t_rex_2': BluetoothDeviceInfo(
        id: 'mock_amazfit_t_rex_2',
        name: 'Amazfit T-Rex 2',
        rssi: -62 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Huawei
      'mock_huawei_watch_gt_4': BluetoothDeviceInfo(
        id: 'mock_huawei_watch_gt_4',
        name: 'HUAWEI WATCH GT 4',
        rssi: -49 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_huawei_watch_fit_3': BluetoothDeviceInfo(
        id: 'mock_huawei_watch_fit_3',
        name: 'HUAWEI WATCH Fit 3',
        rssi: -56 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Xiaomi
      'mock_xiaomi_watch_s3': BluetoothDeviceInfo(
        id: 'mock_xiaomi_watch_s3',
        name: 'Xiaomi Watch S3',
        rssi: -54 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
      'mock_mi_band_8': BluetoothDeviceInfo(
        id: 'mock_mi_band_8',
        name: 'Mi Smart Band 8',
        rssi: -65 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Polar
      'mock_polar_vantage_v3': BluetoothDeviceInfo(
        id: 'mock_polar_vantage_v3',
        name: 'Polar Vantage V3',
        rssi: -51 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),

      // Withings
      'mock_withings_scanwatch_2': BluetoothDeviceInfo(
        id: 'mock_withings_scanwatch_2',
        name: 'Withings ScanWatch 2',
        rssi: -57 + _random.nextInt(10),
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: now,
      ),
    });

    print(
      '🎭 Mock Bluetooth Service initialized with ${_mockDevices.length} devices',
    );
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    return _isBluetoothEnabled;
  }

  @override
  Future<bool> enableBluetooth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isBluetoothEnabled = true;
    print('🎭 Mock: Bluetooth enabled');
    return true;
  }

  @override
  Stream<BluetoothAdapterState> get bluetoothState async* {
    yield _isBluetoothEnabled
        ? BluetoothAdapterState.on
        : BluetoothAdapterState.off;
  }

  @override
  Future<void> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isScanning) return;

    print('🎭 Mock: Starting scan for $timeout');
    _isScanning = true;
    _isScanningController.add(true);

    // Имитируем постепенное обнаружение устройств
    final devicesList = _mockDevices.values.toList()..shuffle(_random);
    var discoveredCount = 0;

    _scanTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (discoveredCount < devicesList.length) {
        // Добавляем устройства постепенно
        final batch = devicesList.skip(discoveredCount).take(2).toList();
        discoveredCount += batch.length;

        // Обновляем RSSI для реалистичности
        final updatedDevices = _mockDevices.values.map((device) {
          if (batch.any((d) => d.id == device.id)) {
            return device.copyWith(
              rssi: device.rssi + _random.nextInt(5) - 2,
              lastSeen: DateTime.now(),
            );
          }
          return device;
        }).toList();

        _devicesStreamController.add(updatedDevices);
        print(
          '🎭 Mock: Discovered ${batch.length} devices (total: $discoveredCount)',
        );
      }

      if (discoveredCount >= devicesList.length) {
        timer.cancel();
      }
    });

    // Автоматически останавливаем сканирование по таймауту
    Future.delayed(timeout, () {
      if (_isScanning) {
        stopScan();
      }
    });
  }

  @override
  Future<void> stopScan() async {
    if (!_isScanning) return;

    print('🎭 Mock: Stopping scan');
    _isScanning = false;
    _isScanningController.add(false);
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  @override
  Stream<List<BluetoothDeviceInfo>> get devicesStream =>
      _devicesStreamController.stream;

  @override
  Stream<bool> get isScanningStream => _isScanningController.stream;

  @override
  Future<bool> connectToDevice(String deviceId) async {
    print('🎭 Mock: Connecting to device $deviceId');

    final device = _mockDevices[deviceId];
    if (device == null) {
      print('🎭 Mock: Device not found');
      return false;
    }

    // Имитируем процесс подключения
    _updateDeviceState(deviceId, DeviceConnectionState.connecting);
    await Future.delayed(const Duration(milliseconds: 1500));

    // Успех с вероятностью 95%
    if (_random.nextDouble() < 0.95) {
      _updateDeviceState(deviceId, DeviceConnectionState.connected);
      _connectedDevices[deviceId] = device.copyWith(
        connectionState: DeviceConnectionState.connected,
      );
      print('🎭 Mock: Successfully connected to ${device.name}');
      return true;
    } else {
      _updateDeviceState(deviceId, DeviceConnectionState.disconnected);
      print('🎭 Mock: Failed to connect to ${device.name}');
      return false;
    }
  }

  @override
  Future<void> disconnectFromDevice(String deviceId) async {
    print('🎭 Mock: Disconnecting from device $deviceId');

    _updateDeviceState(deviceId, DeviceConnectionState.disconnecting);
    await Future.delayed(const Duration(milliseconds: 800));

    _updateDeviceState(deviceId, DeviceConnectionState.disconnected);
    _connectedDevices.remove(deviceId);
    print('🎭 Mock: Disconnected from device $deviceId');
  }

  @override
  Future<List<BluetoothDeviceInfo>> getConnectedDevices() async {
    return _connectedDevices.values.toList();
  }

  @override
  Stream<DeviceConnectionState> getDeviceConnectionState(String deviceId) {
    if (!_connectionStateControllers.containsKey(deviceId)) {
      _connectionStateControllers[deviceId] =
          StreamController<DeviceConnectionState>.broadcast();
    }
    return _connectionStateControllers[deviceId]!.stream;
  }

  @override
  BluetoothDevice? getDevice(String deviceId) {
    // Mock service не возвращает реальные BluetoothDevice объекты
    return null;
  }

  @override
  void clearDevices() {
    print('🎭 Mock: Clearing devices');
    _mockDevices.clear();
    _connectedDevices.clear();
    _devicesStreamController.add([]);
  }

  void _updateDeviceState(String deviceId, DeviceConnectionState state) {
    final device = _mockDevices[deviceId];
    if (device != null) {
      _mockDevices[deviceId] = device.copyWith(connectionState: state);
      _connectionStateControllers[deviceId]?.add(state);
      _devicesStreamController.add(_mockDevices.values.toList());
    }
  }

  @override
  Future<void> dispose() async {
    await stopScan();
    await _devicesStreamController.close();
    await _isScanningController.close();
    for (final controller in _connectionStateControllers.values) {
      await controller.close();
    }
    _connectionStateControllers.clear();
    print('🎭 Mock Bluetooth Service disposed');
  }
}
