import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_erna/presentation/screens/diagnostics_screen.dart';
import '../blocs/main_screen_bloc/main_screen_bloc.dart';
import '../blocs/main_screen_bloc/main_screen_event.dart';
import '../blocs/main_screen_bloc/main_screen_state.dart';
import '../../core/composition_root.dart';
import '../../core/service/bluetooth_service.dart';
import '../../core/models/health_data.dart';
import '../../core/bloc/auth_bloc/auth_bloc.dart';
import '../../core/router/app_router.gr.dart';
import 'main_screen/widgets/device_search_bottom_sheet.dart';
import 'main_screen/widgets/health_data_card.dart';

@RoutePage()
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CompositionRoot.get<MainScreenBloc>()
            ..add(const MainScreenEvent.started()),
      child: const _MainScreenView(),
    );
  }
}

/// Главный экран приложения с дашбордом здоровья
class _MainScreenView extends StatelessWidget {
  const _MainScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Здоровье'),
        actions: [
          BlocBuilder<MainScreenBloc, MainScreenState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded:
                    (
                      hasConnectedDevice,
                      connectedDevice,
                      _,
                      __,
                      ___,
                      ____,
                      _____,
                    ) {
                      if (hasConnectedDevice && connectedDevice != null) {
                        return IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            context.read<MainScreenBloc>().add(
                              const MainScreenEvent.refreshData(),
                            );
                          },
                          tooltip: 'Обновить данные',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          BlocBuilder<MainScreenBloc, MainScreenState>(
            builder: (context, state) {
              return state.maybeWhen(
                loaded:
                    (
                      hasConnectedDevice,
                      connectedDevice,
                      _,
                      __,
                      ___,
                      ____,
                      _____,
                    ) {
                      if (hasConnectedDevice && connectedDevice != null) {
                        return IconButton(
                          icon: const Icon(Icons.bluetooth_disabled),
                          onPressed: () {
                            _showDisconnectDialog(context);
                          },
                          tooltip: 'Отключиться',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: BlocConsumer<MainScreenBloc, MainScreenState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: Colors.red),
              );
            },
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded:
                (
                  hasConnectedDevice,
                  connectedDevice,
                  heartRate,
                  steps,
                  battery,
                  temperature,
                  oxygenSaturation,
                ) {
                  if (!hasConnectedDevice) {
                    return _buildNoDeviceView(context);
                  }

                  return _buildHealthDashboard(
                    context: context,
                    deviceName: connectedDevice?.name ?? 'Неизвестно',
                    heartRate: heartRate,
                    steps: steps,
                    battery: battery,
                    temperature: temperature,
                    oxygenSaturation: oxygenSaturation,
                  );
                },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Произошла ошибка',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MainScreenBloc>().add(
                        const MainScreenEvent.started(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiagnosticsScreen()),
          );
        },
        child: const Icon(Icons.bug_report),
      ),
    );
  }

  //  BlocBuilder<MainScreenBloc, MainScreenState>(
  //           builder: (context, state) {
  //             return state.maybeWhen(
  //               loaded: (hasConnectedDevice, _, __, ___, ____, _____, ______) {
  //                 if (!hasConnectedDevice) {
  //                   return FloatingActionButton.extended(
  //                     onPressed: () => _showDeviceSearch(context),
  //                     icon: const Icon(Icons.bluetooth_searching),
  //                     label: const Text('Найти устройство'),
  //                   );
  //                 }
  //                 return const SizedBox.shrink();
  //               },
  //               orElse: () => const SizedBox.shrink(),
  //             );
  //           },
  //         ),

  /// Виджет для отображения когда нет подключенного устройства
  Widget _buildNoDeviceView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Устройство не подключено',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Подключите смарт-часы для отслеживания здоровья',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showDeviceSearch(context),
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('Найти устройство'),
          ),
        ],
      ),
    );
  }

  /// Дашборд со всеми показателями здоровья
  Widget _buildHealthDashboard({
    required BuildContext context,
    required String deviceName,
    required dynamic heartRate,
    required dynamic steps,
    required dynamic battery,
    required dynamic temperature,
    required dynamic oxygenSaturation,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MainScreenBloc>().add(const MainScreenEvent.refreshData());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Информация о подключенном устройстве
          Card(
            child: ListTile(
              leading: const Icon(Icons.watch, size: 32),
              title: Text(deviceName),
              subtitle: const Text('Подключено'),
              trailing: Icon(
                Icons.bluetooth_connected,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Пульс
          HealthDataCard(
            title: 'Пульс',
            icon: Icons.favorite,
            iconColor: Colors.red,
            value: heartRate?.bpm.toString() ?? '--',
            unit: 'BPM',
            subtitle: heartRate != null
                ? 'Зона: ${heartRate.heartRateZone}'
                : 'Нет данных',
            status: heartRate?.heartRateZone ?? 'Ожидание данных',
          ),
          const SizedBox(height: 12),

          // Шаги
          HealthDataCard(
            title: 'Шаги',
            icon: Icons.directions_walk,
            iconColor: Colors.green,
            value: steps?.steps.toString() ?? '--',
            unit: 'шагов',
            subtitle: steps != null && steps.distance != null
                ? 'Дистанция: ${(steps.distance! * 1000).toStringAsFixed(0)} м'
                : steps != null && steps.calories != null
                ? 'Калории: ${steps.calories} ккал'
                : 'Нет данных',
            status: steps != null ? 'Данные обновлены' : 'Ожидание данных',
          ),
          const SizedBox(height: 12),

          // Батарея
          HealthDataCard(
            title: 'Батарея устройства',
            icon: Icons.battery_charging_full,
            iconColor: Colors.blue,
            value: battery?.level.toString() ?? '--',
            unit: '%',
            subtitle:
                battery != null && battery.status == BatteryStatus.charging
                ? 'Заряжается'
                : battery != null
                ? 'Не заряжается'
                : 'Нет данных',
            status: battery?.batteryLevelString ?? 'Ожидание данных',
          ),
          const SizedBox(height: 12),

          // Температура
          HealthDataCard(
            title: 'Температура тела',
            icon: Icons.thermostat,
            iconColor: Colors.orange,
            value: temperature?.celsius.toStringAsFixed(1) ?? '--',
            unit: '°C',
            subtitle: temperature != null
                ? 'Фаренгейт: ${temperature.fahrenheit.toStringAsFixed(1)}°F'
                : 'Нет данных',
            status: temperature?.temperatureStatus ?? 'Ожидание данных',
          ),
          const SizedBox(height: 12),

          // Сатурация
          HealthDataCard(
            title: 'Кислород в крови',
            icon: Icons.air,
            iconColor: Colors.cyan,
            value: oxygenSaturation?.percentage.toString() ?? '--',
            unit: '%',
            subtitle: oxygenSaturation != null ? 'SpO2 уровень' : 'Нет данных',
            status: oxygenSaturation?.saturationStatus ?? 'Ожидание данных',
          ),
        ],
      ),
    );
  }

  /// Показать диалог поиска устройств
  void _showDeviceSearch(BuildContext context) {
    final bluetoothService = CompositionRoot.get<BluetoothService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<MainScreenBloc>(),
        child: DeviceSearchBottomSheet(bluetoothService: bluetoothService),
      ),
    );
  }

  /// Показать диалог отключения
  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отключить устройство?'),
        content: const Text(
          'Вы уверены, что хотите отключиться от устройства? '
          'Все текущие данные будут потеряны.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MainScreenBloc>().add(
                const MainScreenEvent.disconnectFromDevice(),
              );
            },
            child: const Text('Отключить'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Вы уверены, что хотите выйти? '
          'Вам потребуется снова войти для использования приложения.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Trigger logout event
              context.read<AuthBloc>().add(const AuthEvent.logout());
              // Navigate to login screen
              context.router.replaceAll([const LoginRoute()]);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
