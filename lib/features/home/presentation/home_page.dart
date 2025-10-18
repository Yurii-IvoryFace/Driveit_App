import 'package:driveit_app/features/vehicles/domain/vehicle.dart';
import 'package:driveit_app/features/vehicles/domain/vehicle_repository.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onFuelSummary});

  final ValueChanged<Vehicle?> onFuelSummary;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<VehicleRepository>();
    return StreamBuilder<List<Vehicle>>(
      stream: repository.watchVehicles(),
      builder: (context, snapshot) {
        final vehicles = snapshot.data ?? const <Vehicle>[];
        final activeVehicle = vehicles.firstOrNull;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _VehicleHeroCard(
                  vehicle: activeVehicle,
                  onFuelStatsTap: () => onFuelSummary(activeVehicle),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _VehicleStatsStrip(vehicle: activeVehicle),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recent events',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList.separated(
                itemCount: _demoEvents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _EventCard(event: _demoEvents[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VehicleHeroCard extends StatelessWidget {
  const _VehicleHeroCard({required this.vehicle, required this.onFuelStatsTap});

  final Vehicle? vehicle;
  final VoidCallback onFuelStatsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = vehicle?.photoUrl;
    return Stack(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            image: image != null
                ? DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  )
                : null,
            color: AppColors.surfaceSecondary,
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black87],
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  vehicle?.displayName ?? 'No vehicles yet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  vehicle != null
                      ? '${vehicle!.make} ${vehicle!.model} \u2022 ${vehicle!.year}'
                      : 'Add your first vehicle to unlock stats & tracking',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions_car_outlined),
                      label: Text(
                        vehicle == null ? 'Add vehicle' : 'Open garage',
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: vehicle == null ? null : onFuelStatsTap,
                      child: const Text('Fuel summary'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleStatsStrip extends StatelessWidget {
  const _VehicleStatsStrip({required this.vehicle});

  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final stats = <_VehicleStat>[
      if (vehicle?.odometerKm != null)
        _VehicleStat(
          icon: Icons.speed_outlined,
          label: 'Odometer',
          value: '${vehicle!.odometerKm} km',
        ),
      if (vehicle?.nextService != null)
        _VehicleStat(
          icon: Icons.build_circle_outlined,
          label: 'Next service',
          value: _formatDate(context, vehicle!.nextService!),
        ),
      if (vehicle?.insuranceExpiry != null)
        _VehicleStat(
          icon: Icons.shield_outlined,
          label: 'Insurance',
          value: _formatDate(context, vehicle!.insuranceExpiry!),
        ),
      if (vehicle?.registrationExpiry != null)
        _VehicleStat(
          icon: Icons.assignment_turned_in_outlined,
          label: 'Registration',
          value: _formatDate(context, vehicle!.registrationExpiry!),
        ),
    ];

    if (stats.isEmpty) {
      return SizedBox(
        height: 110,
        child: Center(
          child: Text(
            'Service reminders will appear here once available.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemBuilder: (context, index) => _HomeStatCard(stat: stats[index]),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: stats.length,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatShortMonthDay(date);
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final VehicleEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _eventColors[event.type]!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(colors.icon, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      event.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (event.amount != null) ...[
            const SizedBox(width: 20),
            Text(
              event.amount!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleStat {
  const _VehicleStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({required this.stat});

  final _VehicleStat stat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      height: 132,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(stat.icon, color: AppColors.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventColors {
  const _EventColors({required this.background, required this.icon});

  final Color background;
  final IconData icon;
}

enum EventType { tires, accident, odometer, service, refuel }

class VehicleEvent {
  const VehicleEvent({
    required this.type,
    required this.title,
    required this.location,
    required this.kilometers,
    required this.description,
    required this.date,
    this.amount,
  });

  final EventType type;
  final String title;
  final String location;
  final String kilometers;
  final String description;
  final String date;
  final String? amount;
}

const _eventColors = {
  EventType.tires: _EventColors(
    background: Color(0xFFFFF59D),
    icon: Icons.construction,
  ),
  EventType.accident: _EventColors(
    background: Color(0xFFFFCDD2),
    icon: Icons.report_problem,
  ),
  EventType.odometer: _EventColors(
    background: Color(0xFFB2FF59),
    icon: Icons.av_timer,
  ),
  EventType.service: _EventColors(
    background: Color(0xFF90CAF9),
    icon: Icons.build,
  ),
  EventType.refuel: _EventColors(
    background: Color(0xFFFFE082),
    icon: Icons.local_gas_station,
  ),
};

const _demoEvents = [
  VehicleEvent(
    type: EventType.tires,
    title: 'New winter tires',
    location: 'Praska',
    kilometers: '174,318 km',
    description: 'Installed Bridgestone Blizzak set.',
    date: 'Nov 10',
    amount: 'PLN 350.00',
  ),
  VehicleEvent(
    type: EventType.accident,
    title: 'Minor rear bumper dent',
    location: 'Zana parking',
    kilometers: '174,310 km',
    description: 'Reported a light bumper scratch after parking incident.',
    date: 'Nov 10',
    amount: 'PLN 0.00',
  ),
  VehicleEvent(
    type: EventType.odometer,
    title: 'Odometer check',
    location: 'Dashboard',
    kilometers: '174,261 km',
    description: 'Routine mileage capture for logs.',
    date: 'Nov 02',
  ),
  VehicleEvent(
    type: EventType.service,
    title: 'Spark plugs replacement',
    location: 'MK Service Center',
    kilometers: '174,209 km',
    description: 'Changed spark plugs and ignition cables.',
    date: 'Oct 26',
    amount: 'PLN 400.00',
  ),
];

extension<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
