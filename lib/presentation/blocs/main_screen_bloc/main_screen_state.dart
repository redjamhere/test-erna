import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/bluetooth_device_info.dart';
import '../../../core/models/health_data.dart';

part 'main_screen_state.freezed.dart';

/// Состояния главного экрана
@freezed
class MainScreenState with _$MainScreenState {
  const factory MainScreenState.initial() = _Initial;

  const factory MainScreenState.loading() = _Loading;

  const factory MainScreenState.loaded({
    required bool hasConnectedDevice,
    BluetoothDeviceInfo? connectedDevice,
    HeartRateData? heartRate,
    StepsData? steps,
    BatteryData? battery,
    BodyTemperatureData? temperature,
    OxygenSaturationData? oxygenSaturation,
  }) = _Loaded;

  const factory MainScreenState.error({required String message}) = _Error;
}
