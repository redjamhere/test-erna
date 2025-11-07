import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/bluetooth_device_info.dart';
import '../../../../core/service/bluetooth_service.dart';
import '../../../blocs/main_screen_bloc/main_screen_bloc.dart';
import '../../../blocs/main_screen_bloc/main_screen_event.dart';

/// Bottom sheet для поиска и подключения к BLE устройствам
class DeviceSearchBottomSheet extends StatefulWidget {
  final BluetoothService bluetoothService;

  const DeviceSearchBottomSheet({super.key, required this.bluetoothService});

  @override
  State<DeviceSearchBottomSheet> createState() =>
      _DeviceSearchBottomSheetState();
}

class _DeviceSearchBottomSheetState extends State<DeviceSearchBottomSheet> {
  MainScreenBloc? _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc ??= context.read<MainScreenBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MainScreenBloc>().add(const MainScreenEvent.startScan());
    });
  }

  @override
  void dispose() {
    _bloc?.add(const MainScreenEvent.stopScan());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.bluetooth_searching,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Поиск устройств',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<BluetoothDeviceInfo>>(
              stream: widget.bluetoothService.devicesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка сканирования',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                final devices = snapshot.data ?? [];
                if (devices.isEmpty && !Platform.isIOS) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Поиск устройств...',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Убедитесь, что Bluetooth включен\nи устройство находится рядом',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: devices.length + (Platform.isIOS ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    if (Platform.isIOS && index == 0) {
                      return const _IosHealthTile();
                    }
                    final deviceIndex = Platform.isIOS ? index - 1 : index;
                    final device = devices[deviceIndex];
                    return _DeviceListTile(device: device);
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Нажмите на устройство для подключения',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IosHealthTile extends StatefulWidget {
  const _IosHealthTile();
  @override
  State<_IosHealthTile> createState() => _IosHealthTileState();
}

class _IosHealthTileState extends State<_IosHealthTile> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.2),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.favorite, color: theme.colorScheme.primary),
        ),
        title: Text(
          'iOS Health',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Получить данные из HealthKit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Рекомендуется',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.primary,
              ),
        onTap: _isConnecting ? null : () => _connectToIosHealth(context),
      ),
    );
  }

  Future<void> _connectToIosHealth(BuildContext context) async {
    setState(() => _isConnecting = true);
    try {
      final iosHealthDevice = BluetoothDeviceInfo(
        id: 'ios_health',
        name: 'iOS Health',
        rssi: 0,
        connectionState: DeviceConnectionState.disconnected,
        lastSeen: DateTime.now(),
      );
      if (context.mounted) {
        context.read<MainScreenBloc>().add(
          MainScreenEvent.connectToDevice(device: iosHealthDevice),
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось подключиться к iOS Health: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }
}

class _DeviceListTile extends StatefulWidget {
  final BluetoothDeviceInfo device;
  const _DeviceListTile({required this.device});
  @override
  State<_DeviceListTile> createState() => _DeviceListTileState();
}

class _DeviceListTileState extends State<_DeviceListTile> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final device = widget.device;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getDeviceIcon(device.name),
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        device.name.isEmpty ? 'Неизвестное устройство' : device.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            device.id,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _getSignalIcon(device.rssi),
                size: 16,
                color: _getSignalColor(device.rssi),
              ),
              const SizedBox(width: 4),
              Text(
                device.signalStrengthString,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getSignalColor(device.rssi),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: _isConnecting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
      onTap: _isConnecting ? null : () => _connectToDevice(context),
    );
  }

  Future<void> _connectToDevice(BuildContext context) async {
    if (_isAmazfitDevice(widget.device.name)) {
      _showAmazfitWarning(context);
      return;
    }
    setState(() => _isConnecting = true);
    try {
      if (context.mounted) {
        context.read<MainScreenBloc>().add(
          MainScreenEvent.connectToDevice(device: widget.device),
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось подключиться: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  bool _isAmazfitDevice(String deviceName) {
    final lowerName = deviceName.toLowerCase();
    return lowerName.contains('huami') ||
        lowerName.contains('zepp') ||
        lowerName.contains('mi band') ||
        lowerName.contains('mi smart band') ||
        lowerName.contains('honor') ||
        lowerName.contains('watch gt') ||
        lowerName.contains('watch fit');
  }

  void _showAmazfitWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Устройство не поддерживается'),
          ],
        ),
        content: const Text(
          'Устройства Amazfit/Huami/Huawei/Honor используют проприетарный протокол и в настоящее время не поддерживаются.\n\n'
          'Приложение поддерживает устройства со стандартным Bluetooth GATT профилем (например, Polar, Garmin).\n\n'
          'Поддержка проприетарных протоколов планируется в будущих обновлениях.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('watch') || lowerName.contains('band'))
      return Icons.watch;
    if (lowerName.contains('phone')) return Icons.phone_android;
    if (lowerName.contains('headphone') || lowerName.contains('buds'))
      return Icons.headphones;
    return Icons.bluetooth;
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi >= -60) return Icons.signal_cellular_alt;
    if (rssi >= -80) return Icons.signal_cellular_alt_2_bar;
    return Icons.signal_cellular_alt_1_bar;
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -80) return Colors.orange;
    return Colors.red;
  }
}
