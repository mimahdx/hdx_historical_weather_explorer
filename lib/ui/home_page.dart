import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hdx_historical_weather_explorer/core/env.dart';
import 'package:hdx_historical_weather_explorer/utils/string_utils.dart';
import 'package:latlong2/latlong.dart';
import 'common/secondary_button_style.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../utils/date_format_utils.dart';
import '../utils/history_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _controller = TextEditingController(text: 'Cebu');
  DateTime? startDate;
  DateTime? endDate;
  LatLng defaultLocation = const LatLng(10.3157, 123.8854); // Cebu

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate ??= DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 31));
    endDate ??= DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));

    final range = DateTimeRange(start: startDate!, end: endDate!);
    context.read<HistoryCubit>().fetchHistoricalWeather(
      _controller.text,
      range,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.indigo,
        title: const Text(StringUtils.appTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: BlocListener<HistoryCubit, HistoryState>(
          listenWhen:
              (prev, curr) =>
                  curr is LocationCityResolved || curr is HistoryLoaded,
          listener: (context, state) {
            if (state is LocationCityResolved) {
              _controller.text = state.city;
              defaultLocation = state.location;
              _safeMove(state.location, 10);
            }

            if (state is HistoryLoaded &&
                state.data.lat != null &&
                state.data.lon != null) {
              final loc = LatLng(state.data.lat!, state.data.lon!);
              _safeMove(loc, 8);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCityInputField(),
                const SizedBox(height: 12),
                _buildDatePickers(),
                const SizedBox(height: 12),
                _buildSubmitButton(),
                const SizedBox(height: 20),
                BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) {
                    LatLng location = defaultLocation;
                    if (state is LocationCityResolved) {
                      location = state.location;
                    } else if (state is HistoryLoaded &&
                        state.data.lat != null &&
                        state.data.lon != null) {
                      location = LatLng(state.data.lat!, state.data.lon!);
                    }
                    return _buildMap(location);
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<HistoryCubit, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is HistoryLoaded) {
                      final summary = HistoryUtils.generateWeatherHistorySummary(state.data);
                      return _buildSummaryCard(summary, state);
                    }
                    if (state is HistoryError) {
                      return Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _safeMove(LatLng location, double zoom) {
    Future.delayed(const Duration(milliseconds: 100), () {
      _mapController.move(location, zoom);
    });
  }

  Widget _buildCityInputField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: StringUtils.enterCityLabel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => _pickDate(isStart: true),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${StringUtils.startDateLabel}\n${DateFormatUtils.formatDate(startDate!)}',
                style: const TextStyle(fontSize: 15),
              ),
              style: secondaryButtonStyle(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () => _pickDate(isStart: false),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                '${StringUtils.endDateLabel}\n${DateFormatUtils.formatDate(endDate!)}',
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 15),
              ),
              style: secondaryButtonStyle(),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate! : endDate!,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget _buildSubmitButton() {
    final validRange =
        startDate != null && endDate != null && !endDate!.isBefore(startDate!);

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed:
            validRange
                ? () {
                  final range = DateTimeRange(start: startDate!, end: endDate!);
                  context.read<HistoryCubit>().fetchHistoricalWeather(
                    _controller.text,
                    range,
                  );
                }
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        child: const Text(StringUtils.getHistoryButton, style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildMap(LatLng location) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: defaultLocation,
            initialZoom: 8,
            onTap: (tapPosition, latLng) {
              context.read<HistoryCubit>().fetchReverseGeocodedCity(latLng);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: Environment.openstreetmapTileUrl,
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: Environment.packageName,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String summary, HistoryLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringUtils.weatherSummaryTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          Text(summary),
          const SizedBox(height: 16),
          Text(StringUtils.detailsTitle, style: Theme.of(context).textTheme.titleSmall),
          Text('${StringUtils.avgTempTitle} ${state.data.tempAvg ?? '-'}${StringUtils.celciusUnit}'),
          Text('${StringUtils.minTempTitle} ${state.data.tempMin ?? '-'}${StringUtils.celciusUnit}'),
          Text('${StringUtils.maxTempTitle} ${state.data.tempMax ?? '-'}${StringUtils.celciusUnit}'),
          Text('${StringUtils.precipitationTitle} ${state.data.precip ?? '-'} ${StringUtils.mmUnit}'),
        ],
      ),
    );
  }
}
