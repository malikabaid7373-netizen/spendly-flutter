import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters/money_formatter.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/finance_category.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/finance_view_model.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/section_header.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final breakdown = finance.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final trend = finance.expenseTrend();
    final weekTrend = finance.lastSevenDayExpenseTrend;
    final maxY = trend.isEmpty
        ? 1000.0
        : (trend.reduce((a, b) => a > b ? a : b) * 1.25)
            .clamp(500, double.infinity)
            .toDouble();
    final weekMax = weekTrend.isEmpty
        ? 100.0
        : (weekTrend.reduce((a, b) => a > b ? a : b) * 1.3)
            .clamp(100, double.infinity)
            .toDouble();
    final largest = finance.largestExpenseCategory;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          AnimatedReveal(
            child: Text(
              context.t('spendingInsights'),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedReveal(
            delay: const Duration(milliseconds: 40),
            child: Text(
              context.t('analyticsSubtitle'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedReveal(
            delay: const Duration(milliseconds: 90),
            child: _FinancialHealthHero(finance: finance),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AnimatedReveal(
                  delay: const Duration(milliseconds: 140),
                  child: _HealthCard(
                    icon: Icons.savings_rounded,
                    label: context.t('savingsRate'),
                    value: '${finance.savingsRate.toStringAsFixed(0)}%',
                    color: AppPalette.emerald,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedReveal(
                  delay: const Duration(milliseconds: 180),
                  child: _HealthCard(
                    icon: Icons.pie_chart_rounded,
                    label: context.t('largestCategory'),
                    value: largest == null ? '—' : context.t(largest),
                    color: AppPalette.cyan,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HealthCard(
                  icon: Icons.query_stats_rounded,
                  label: context.t('projectedSpend'),
                  value: formatMoney(context, finance.projectedMonthExpenses),
                  color: AppPalette.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HealthCard(
                  icon: Icons.autorenew_rounded,
                  label: context.t('recurringExpenses'),
                  value: formatMoney(context, finance.recurringExpenses),
                  color: const Color(0xFF9C7CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(title: context.t('cashflowPulse')),
          const SizedBox(height: 10),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t('weeklySpend'),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formatMoney(context, finance.weeklyExpenses),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.emerald.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${finance.noSpendDaysThisWeek} ${context.t('noSpendDays')}',
                        style: const TextStyle(
                          color: AppPalette.emerald,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: weekMax,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: weekMax / 3,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: Theme.of(context).dividerColor,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            weekTrend.length,
                            (index) => FlSpot(index.toDouble(), weekTrend[index]),
                          ),
                          isCurved: true,
                          curveSmoothness: .32,
                          barWidth: 3,
                          gradient: const LinearGradient(
                            colors: [AppPalette.emerald, AppPalette.cyan],
                          ),
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppPalette.emerald.withValues(alpha: .18),
                                AppPalette.cyan.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: context.t('sixMonthTrend')),
          const SizedBox(height: 10),
          PremiumCard(
            child: SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = ['-5', '-4', '-3', '-2', '-1', 'Now'];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    trend.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: trend[index],
                          width: 18,
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppPalette.emerald, AppPalette.cyan],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: context.t('categoryBreakdown')),
          const SizedBox(height: 10),
          PremiumCard(
            child: breakdown.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text(context.t('noTransactions'))),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 190,
                        child: PieChart(
                          PieChartData(
                            centerSpaceRadius: 50,
                            sectionsSpace: 3,
                            sections: breakdown.take(6).map((entry) {
                              final category = FinanceCategory.byKey(entry.key);
                              final total = finance.monthExpenses <= 0
                                  ? 1.0
                                  : finance.monthExpenses;
                              return PieChartSectionData(
                                value: entry.value,
                                color: category.color,
                                radius: 24,
                                showTitle: entry.value / total > .12,
                                title:
                                    '${(entry.value / total * 100).round()}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...breakdown.take(6).map((entry) {
                        final category = FinanceCategory.byKey(entry.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  context.t(category.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                formatMoney(context, entry.value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FinancialHealthHero extends StatelessWidget {
  const _FinancialHealthHero({required this.finance});
  final FinanceViewModel finance;

  @override
  Widget build(BuildContext context) {
    final score = finance.financialHealthScore;
    final tone = score >= 70 ? AppPalette.emerald : AppPalette.warning;
    final label = score >= 75
        ? context.t('healthyCashflow')
        : score >= 50
            ? context.t('steadyCashflow')
            : context.t('needsAttention');

    return PremiumCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF112F2B), Color(0xFF0D2032)],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 560),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: .08),
                    color: tone,
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('financialScore'),
                  style: const TextStyle(
                    color: Color(0xFFAEC3C4),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t(finance.healthLevelKey),
                  style: TextStyle(
                    color: tone,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
