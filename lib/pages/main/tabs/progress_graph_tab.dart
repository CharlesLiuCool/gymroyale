import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymroyale/models/user_point_entry.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/models/user.dart';
import 'package:gymroyale/models/user_history.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'dart:math';

class ProgressGraphTab extends StatelessWidget {
  final String userId;
  final leaderboardRepo = LeaderboardRepository();

  ProgressGraphTab({super.key, required this.userId});

  DateTime toPST(DateTime dt) {
    return dt.toUtc().subtract(const Duration(hours: 8));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: leaderboardRepo.topUsers(limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final topUsers = snapshot.data!;

        return StreamBuilder<List<UserHistory>>(
          stream: leaderboardRepo.watchTopUserHistory(topUsers),
          builder: (context, historySnap) {
            if (!historySnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final histories = historySnap.data!;

            final colors = [
              AppColors.accent,
              Colors.orange,
              Colors.greenAccent,
              Colors.purpleAccent,
              Colors.yellowAccent,
            ];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Title
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Progress",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Vertical "Points" label
                        const RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            "Points",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Graph + X-axis label
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.4,
                                  child: Transform.translate(
                                    offset: const Offset(-18, 0),
                                    child: LineChart(
                                      LineChartData(
                                        minY: 0,
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index < 0 || index > 6)
                                                  return const SizedBox();

                                                final nonEmpty = histories
                                                    .where(
                                                      (h) =>
                                                          h.history.isNotEmpty,
                                                    );

                                                final referenceHistory =
                                                    nonEmpty.isNotEmpty
                                                        ? nonEmpty.first.history
                                                        : <UserPointEntry>[];

                                                final sorted = [
                                                  ...referenceHistory,
                                                ]..sort(
                                                  (a, b) => a.timestamp
                                                      .compareTo(b.timestamp),
                                                );

                                                final lastSeven =
                                                    sorted
                                                        .skip(
                                                          max(
                                                            0,
                                                            sorted.length - 7,
                                                          ),
                                                        )
                                                        .toList();

                                                if (index >= lastSeven.length)
                                                  return const SizedBox();

                                                final date = toPST(
                                                  lastSeven[index].timestamp,
                                                );
                                                final label =
                                                    "${date.month}/${date.day}";

                                                return Transform.translate(
                                                  offset: const Offset(-10, 0),
                                                  child: SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: Text(
                                                      label,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            AppColors
                                                                .textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return SideTitleWidget(
                                                  axisSide: meta.axisSide,
                                                  child: Text(
                                                    value.toInt().toString(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: true,
                                          horizontalInterval: 10,
                                          getDrawingHorizontalLine:
                                              (value) => FlLine(
                                                color: AppColors.textSecondary
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                          getDrawingVerticalLine:
                                              (value) => FlLine(
                                                color: AppColors.textSecondary
                                                    .withOpacity(0.2),
                                                strokeWidth: 1,
                                              ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: const Border(
                                            left: BorderSide(
                                              color: AppColors.textPrimary,
                                            ),
                                            bottom: BorderSide(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        lineBarsData:
                                            histories.asMap().entries.map((
                                              entry,
                                            ) {
                                              final index = entry.key;
                                              final userHistory = entry.value;

                                              final sortedHistory = [
                                                ...userHistory.history,
                                              ]..sort(
                                                (a, b) => a.timestamp.compareTo(
                                                  b.timestamp,
                                                ),
                                              );

                                              final lastSeven =
                                                  sortedHistory
                                                      .skip(
                                                        max(
                                                          0,
                                                          sortedHistory.length -
                                                              7,
                                                        ),
                                                      )
                                                      .toList();

                                              final spots = List.generate(
                                                lastSeven.length,
                                                (i) => FlSpot(
                                                  i.toDouble(),
                                                  lastSeven[i].points
                                                      .toDouble(),
                                                ),
                                              );

                                              final userColor =
                                                  colors[index % colors.length];

                                              return LineChartBarData(
                                                isCurved: true,
                                                barWidth: 2,
                                                dotData: FlDotData(
                                                  show: true,
                                                  getDotPainter:
                                                      (
                                                        spot,
                                                        percent,
                                                        barData,
                                                        i,
                                                      ) => FlDotCirclePainter(
                                                        radius: 3,
                                                        color: userColor,
                                                        strokeWidth: 0,
                                                      ),
                                                ),
                                                spots: spots,
                                                color: userColor,
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // X-axis label
                              const Text(
                                "Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Legend
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children:
                        histories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final history = entry.value;

                          final user = topUsers.firstWhere(
                            (u) => u.id == history.userId,
                            orElse:
                                () => User(
                                  id: history.userId,
                                  name: "Unknown",
                                  points: 0,
                                ),
                          );

                          final color = colors[index % colors.length];

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
