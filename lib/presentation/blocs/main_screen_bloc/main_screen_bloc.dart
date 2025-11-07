import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/bluetooth_device_info.dart';
import '../../../core/service/bluetooth_service.dart';
import '../../../data/repositories/health_data_repository.dart';
import 'main_screen_event.dart';
import 'main_screen_state.dart';

/// BLoC для управления главным экраном
class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  final BluetoothService _bluetoothService;
  final HealthDataRepository _healthDataRepository;

  StreamSubscription<void>? _heartRateSubscription;
  StreamSubscription<void>? _batterySubscription;

  MainScreenBloc({
    required BluetoothService bluetoothService,
    required HealthDataRepository healthDataRepository,
  }) : _bluetoothService = bluetoothService,
       _healthDataRepository = healthDataRepository,
       super(const MainScreenState.initial()) {
    on<MainScreenEvent>(_onMainScreenEvent);
  }

  /// Main event handler using freezed's when method
  Future<void> _onMainScreenEvent(
    MainScreenEvent event,
    Emitter<MainScreenState> emit,
  ) async {
    await event.when(
      started: () => _onStarted(emit),
      connectToDevice: (device) => _onConnectToDevice(device, emit),
      disconnectFromDevice: () => _onDisconnectFromDevice(emit),
      refreshData: () => _onRefreshData(emit),
      startScan: () => _onStartScan(emit),
      stopScan: () => _onStopScan(emit),
    );
  }

  /// Инициализация
  Future<void> _onStarted(Emitter<MainScreenState> emit) async {
    emit(const MainScreenState.loading());

    try {
      // Проверяем, есть ли подключенные устройства
      final connectedDevices = await _bluetoothService.getConnectedDevices();
      final hasConnectedDevice = connectedDevices.isNotEmpty;

      // Подписываемся на обновления данных
      if (hasConnectedDevice) {
        await _healthDataRepository.startDataCollection(connectedDevices.first);
        _subscribeToHealthData(emit);
      }

      emit(
        MainScreenState.loaded(
          hasConnectedDevice: hasConnectedDevice,
          connectedDevice: hasConnectedDevice ? connectedDevices.first : null,
          heartRate: _healthDataRepository.latestHeartRate,
          steps: _healthDataRepository.latestSteps,
          battery: _healthDataRepository.latestBattery,
          temperature: _healthDataRepository.latestTemperature,
          oxygenSaturation: _healthDataRepository.latestOxygenSaturation,
        ),
      );
    } catch (e) {
      emit(MainScreenState.error(message: e.toString()));
    }
  }

  /// Подключение к устройству
  Future<void> _onConnectToDevice(
    BluetoothDeviceInfo device,
    Emitter<MainScreenState> emit,
  ) async {
    emit(const MainScreenState.loading());

    try {
      // Начинаем сбор данных (подключение происходит автоматически)
      // UnifiedHealthService определит тип устройства (Huawei или BLE)
      await _healthDataRepository.startDataCollection(device);

      // Подписываемся на обновления данных
      _subscribeToHealthData(emit);

      emit(
        MainScreenState.loaded(
          hasConnectedDevice: true,
          connectedDevice: device,
          heartRate: _healthDataRepository.latestHeartRate,
          steps: _healthDataRepository.latestSteps,
          battery: _healthDataRepository.latestBattery,
          temperature: _healthDataRepository.latestTemperature,
          oxygenSaturation: _healthDataRepository.latestOxygenSaturation,
        ),
      );
    } catch (e) {
      emit(MainScreenState.error(message: 'Не удалось подключиться: $e'));
    }
  }

  /// Отключение от устройства
  Future<void> _onDisconnectFromDevice(Emitter<MainScreenState> emit) async {
    emit(const MainScreenState.loading());

    try {
      // Останавливаем сбор данных
      await _healthDataRepository.stopDataCollection();

      // Отписываемся от обновлений
      await _heartRateSubscription?.cancel();
      await _batterySubscription?.cancel();
      _heartRateSubscription = null;
      _batterySubscription = null;

      // Отключаемся от устройства
      final connectedDevices = await _bluetoothService.getConnectedDevices();
      if (connectedDevices.isNotEmpty) {
        await _bluetoothService.disconnectFromDevice(connectedDevices.first.id);
      }

      emit(
        const MainScreenState.loaded(
          hasConnectedDevice: false,
          connectedDevice: null,
          heartRate: null,
          steps: null,
          battery: null,
          temperature: null,
          oxygenSaturation: null,
        ),
      );
    } catch (e) {
      emit(MainScreenState.error(message: 'Не удалось отключиться: $e'));
    }
  }

  /// Обновление данных
  Future<void> _onRefreshData(Emitter<MainScreenState> emit) async {
    final currentState = state;

    // Работаем только если находимся в loaded состоянии
    await currentState.whenOrNull(
      loaded:
          (
            hasConnectedDevice,
            connectedDevice,
            heartRate,
            steps,
            battery,
            temperature,
            oxygenSaturation,
          ) async {
            try {
              // Обновляем данные
              await _healthDataRepository.refreshSteps();
              await _healthDataRepository.refreshTemperature();
              await _healthDataRepository.refreshOxygenSaturation();

              // Проверяем, что эмиттер еще активен
              if (!emit.isDone) {
                emit(
                  MainScreenState.loaded(
                    hasConnectedDevice: hasConnectedDevice,
                    connectedDevice: connectedDevice,
                    heartRate: _healthDataRepository.latestHeartRate,
                    steps: _healthDataRepository.latestSteps,
                    battery: _healthDataRepository.latestBattery,
                    temperature: _healthDataRepository.latestTemperature,
                    oxygenSaturation:
                        _healthDataRepository.latestOxygenSaturation,
                  ),
                );
              }
            } catch (e) {
              if (!emit.isDone) {
                emit(
                  MainScreenState.error(
                    message: 'Не удалось обновить данные: $e',
                  ),
                );
              }
            }
          },
    );
  }

  /// Начать сканирование
  Future<void> _onStartScan(Emitter<MainScreenState> emit) async {
    try {
      await _bluetoothService.startScan();
    } catch (e) {
      emit(
        MainScreenState.error(message: 'Не удалось начать сканирование: $e'),
      );
    }
  }

  /// Остановить сканирование
  Future<void> _onStopScan(Emitter<MainScreenState> emit) async {
    try {
      await _bluetoothService.stopScan();
    } catch (e) {
      emit(
        MainScreenState.error(
          message: 'Не удалось остановить сканирование: $e',
        ),
      );
    }
  }

  /// Подписка на обновления здоровья
  void _subscribeToHealthData(Emitter<MainScreenState> emit) {
    _heartRateSubscription?.cancel();
    _batterySubscription?.cancel();

    // Подписываемся на обновления пульса
    _heartRateSubscription = _healthDataRepository.heartRateStream.listen(
      (heartRate) {
        // Обновляем только если находимся в loaded состоянии
        state.whenOrNull(
          loaded: (_, __, ___, ____, _____, ______, _______) {
            add(const MainScreenEvent.refreshData());
          },
        );
      },
      onError: (error) {
        // Логируем ошибки, но не падаем
        print('Ошибка в потоке пульса: $error');
      },
    );

    // Подписываемся на обновления батареи
    _batterySubscription = _healthDataRepository.batteryStream.listen(
      (battery) {
        // Обновляем только если находимся в loaded состоянии
        state.whenOrNull(
          loaded: (_, __, ___, ____, _____, ______, _______) {
            add(const MainScreenEvent.refreshData());
          },
        );
      },
      onError: (error) {
        print('Ошибка в потоке батареи: $error');
      },
    );
  }

  @override
  Future<void> close() async {
    await _heartRateSubscription?.cancel();
    await _batterySubscription?.cancel();
    await _healthDataRepository.stopDataCollection();
    return super.close();
  }
}
