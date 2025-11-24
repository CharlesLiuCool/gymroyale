import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymroyale/repositories/leaderboard_repository.dart';
import 'package:gymroyale/models/user.dart';
import 'package:gymroyale/models/user_history.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'dart:math';

class ProgressGraphTab extends StatelessWidget {
  final String userId;
  final leaderboardRepo = LeaderboardRepository();

  ProgressGraphTab({super.key, required this.userId});

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

            // Small color palette for multiple users
            final colors = [
              AppColors.accent,
              Colors.orange,
              Colors.greenAccent,
              Colors.purpleAccent,
              Colors.yellowAccent,
            ];

            return LineChart(
              LineChartData(
                minY: 0,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final int day = value.toInt() + 1;
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            'Day $day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textPrimary,
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: AppColors.textPrimary),
                    bottom: BorderSide(color: AppColors.textPrimary),
                  ),
                ),
                lineBarsData:
                    histories.map((userHistory) {
                      final sortedHistory =
                          userHistory.history..sort(
                            (a, b) => a.timestamp.compareTo(b.timestamp),
                          );

                      final spots = List.generate(
                        sortedHistory.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          sortedHistory[index].points.toDouble(),
                        ),
                      );

                      final userColor =
                          colors[userHistory.userId.hashCode % colors.length];

                      return LineChartBarData(
                        isCurved: true,
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 3,
                                    color: userColor, // your dot color here
                                    strokeWidth: 0,
                                  ),
                        ),
                        spots: spots,
                        color: userColor,
                      );
                    }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
