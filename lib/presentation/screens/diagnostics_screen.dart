import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/service/bluetooth_service.dart';
import '../../core/service/smartwatch_data_service.dart';
import '../../core/utils/bluetooth_diagnostics.dart';
import '../../core/models/bluetooth_device_info.dart';

/// Экран для диагностики BLE подключений
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final _bluetoothService = GetIt.I<BluetoothService>();
  final _smartwatchDataService = GetIt.I<SmartwatchDataService>();
  late final BluetoothDiagnostics _diagnostics;

  List<BluetoothDeviceInfo> _devices = [];
  DiagnosticReport? _currentReport;
  bool _isScanning = false;
  bool _isDiagnosing = false;

  @override
  void initState() {
    super.initState();
    _diagnostics = BluetoothDiagnostics(
      _bluetoothService,
      _smartwatchDataService,
    );
    _listenToDevices();
  }

  void _listenToDevices() {
    _bluetoothService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _devices = devices;
        });
      }
    });

    _bluetoothService.isScanningStream.listen((scanning) {
      if (mounted) {
        setState(() {
          _isScanning = scanning;
        });
      }
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _currentReport = null;
    });
    await _bluetoothService.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> _diagnoseDevice(String deviceId) async {
    setState(() {
      _isDiagnosing = true;
      _currentReport = null;
    });

    try {
      final report = await _diagnostics.diagnoseDevice(deviceId);
      _diagnostics.printSummary(report);

      setState(() {
        _currentReport = report;
      });
    } finally {
      setState(() {
        _isDiagnosing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Диагностика BLE'),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
              tooltip: 'Сканировать',
            ),
        ],
      ),
      body: Column(
        children: [
          // Список устройств
          Expanded(
            flex: 1,
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bluetooth_searching,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Нет устройств'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isScanning ? null : _startScan,
                          icon: const Icon(Icons.search),
                          label: const Text('Начать поиск'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.watch,
                            color:
                                device.connectionState ==
                                    DeviceConnectionState.connected
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(device.name),
                          subtitle: Text(
                            'ID: ${device.id}\nСигнал: ${device.signalStrengthString}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: _isDiagnosing
                                ? null
                                : () => _diagnoseDevice(device.id),
                            child: const Text('Диагностика'),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Отчет диагностики
          if (_currentReport != null)
            Expanded(flex: 2, child: _buildReport(_currentReport!))
          else if (_isDiagnosing)
            const Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Выполняется диагностика...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReport(DiagnosticReport report) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Отчет диагностики',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),

          // Основная информация
          _buildSection('Основная информация', [
            _buildInfoRow('Device ID', report.deviceId),
            _buildInfoRow('Тип устройства', report.deviceType),
            _buildStatusRow('Bluetooth', report.bluetoothEnabled),
            _buildStatusRow('Устройство найдено', report.deviceFound),
            _buildStatusRow('Подключено', report.isConnected),
          ]),

          // Сервисы
          _buildSection('Обнаружено сервисов: ${report.servicesCount}', [
            _buildStatusRow('Heart Rate Service', report.hasHeartRateService),
            _buildStatusRow('Battery Service', report.hasBatteryService),
            _buildStatusRow('Device Info Service', report.hasDeviceInfoService),
          ]),

          // Данные
          _buildSection('Полученные данные', [
            _buildDataRow(
              'Пульс',
              report.heartRateDataReceived,
              report.heartRateValue != null
                  ? '${report.heartRateValue} BPM'
                  : null,
            ),
            _buildDataRow(
              'Батарея',
              report.batteryDataReceived,
              report.batteryLevel != null ? '${report.batteryLevel}%' : null,
            ),
          ]),

          // Все сервисы
          if (report.availableServices.isNotEmpty)
            _buildSection(
              'Все обнаруженные сервисы',
              report.availableServices.map((uuid) => Text('• $uuid')).toList(),
            ),

          // Ошибки
          if (report.errors.isNotEmpty)
            _buildSection(
              'Ошибки',
              report.errors
                  .map(
                    (error) =>
                        Text(error, style: const TextStyle(color: Colors.red)),
                  )
                  .toList(),
            ),

          // Рекомендации
          _buildRecommendations(report),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, bool received, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (received && value != null)
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            )
          else
            const Icon(Icons.cancel, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildRecommendations(DiagnosticReport report) {
    final recommendations = <String>[];

    if (!report.bluetoothEnabled) {
      recommendations.add('Включите Bluetooth на устройстве');
    }
    if (!report.deviceFound) {
      recommendations.add('Убедитесь, что устройство в зоне действия');
      recommendations.add('Попробуйте запустить сканирование заново');
    }
    if (!report.isConnected &&
        report.connectionAttempted &&
        !report.connectionSuccessful) {
      recommendations.add('Перезагрузите Bluetooth устройство (часы)');
      recommendations.add(
        'Удалите устройство из списка Bluetooth и подключитесь заново',
      );
    }
    if (report.servicesCount == 0) {
      recommendations.add('Устройство не предоставляет сервисы');
      recommendations.add('Возможно, требуется авторизация или сопряжение');
    }
    if (!report.hasHeartRateService && !report.hasBatteryService) {
      recommendations.add(
        'Устройство не поддерживает стандартные GATT сервисы',
      );
      recommendations.add('Используется проприетарный протокол');
      recommendations.add(
        'Требуется специальная реализация для этого производителя',
      );
    }
    if (report.hasHeartRateService && !report.heartRateDataReceived) {
      recommendations.add('Heart Rate сервис найден, но данные не получены');
      recommendations.add('Проверьте, включен ли мониторинг пульса на часах');
      recommendations.add('Убедитесь, что часы надеты на руку');
    }

    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      '🔧 Рекомендации',
      recommendations
          .map(
            (rec) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $rec'),
            ),
          )
          .toList(),
    );
  }
}
