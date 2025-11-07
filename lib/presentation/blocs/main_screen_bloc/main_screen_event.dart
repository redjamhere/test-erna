import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/bluetooth_device_info.dart';

part 'main_screen_event.freezed.dart';

/// События главного экрана
@freezed
class MainScreenEvent with _$MainScreenEvent {
  /// Инициализация и загрузка данных
  const factory MainScreenEvent.started() = _Started;

  /// Подключение к устройству
  const factory MainScreenEvent.connectToDevice({
    required BluetoothDeviceInfo device,
  }) = _ConnectToDevice;

  /// Отключение от устройства
  const factory MainScreenEvent.disconnectFromDevice() = _DisconnectFromDevice;

  /// Обновление данных
  const factory MainScreenEvent.refreshData() = _RefreshData;

  /// Начать сканирование устройств
  const factory MainScreenEvent.startScan() = _StartScan;

  /// Остановить сканирование устройств
  const factory MainScreenEvent.stopScan() = _StopScan;
}
