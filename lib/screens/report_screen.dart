import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/helpers.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TransactionProvider>();
    final text = Theme.of(context).textTheme;
    final categories = data.periodExpenseByCategory;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'Laporan',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _PeriodSwitch(selected: data.period, onChanged: data.setPeriod),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TotalCard(
                  label: 'Pemasukan',
                  amount: data.periodIncome,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TotalCard(
                  label: 'Pengeluaran',
                  amount: data.periodExpense,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Pemasukan vs Pengeluaran',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ComparisonChart(buckets: data.periodBuckets),
          const SizedBox(height: 24),
          Text(
            'Pengeluaran per Kategori',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (categories.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Belum ada pengeluaran pada periode ini',
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            _CategoryBreakdown(entries: categories, total: data.periodExpense),
        ],
      ),
    );
  }
}

class _PeriodSwitch extends StatelessWidget {
  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onChanged;

  const _PeriodSwitch({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <(String, ReportPeriod)>[
      ('Minggu', ReportPeriod.week),
      ('Bulan', ReportPeriod.month),
      ('Tahun', ReportPeriod.year),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final (label, period) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == period
                        ? AppColors.dark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected == period ? Colors.white : AppColors.dark,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall?.copyWith(color: AppColors.dark)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rupiah(amount),
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonChart extends StatelessWidget {
  final List<ReportBucket> buckets;
  const _ComparisonChart({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final maxValue = buckets.fold<double>(
      0,
      (m, b) => math.max(m, math.max(b.income, b.expense)),
    );
    final barWidth = buckets.length > 8
        ? 6.0
        : buckets.length > 4
        ? 9.0
        : 16.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 1 : maxValue * 1.2,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                        BarTooltipItem(
                          rupiah(rod.toY),
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  ),
                ),
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
                        final i = value.toInt();
                        if (i < 0 || i >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            buckets[i].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < buckets.length; i++)
                    BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: buckets[i].income,
                          width: barWidth,
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: buckets[i].expense,
                          width: barWidth,
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: AppColors.primary,
                label: 'Pemasukan',
                style: text.bodySmall,
              ),
              const SizedBox(width: 20),
              _LegendDot(
                color: AppColors.secondary,
                label: 'Pengeluaran',
                style: text.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final TextStyle? style;

  const _LegendDot({required this.color, required this.label, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  final List<MapEntry<String, double>> entries;
  final double total;

  const _CategoryBreakdown({required this.entries, required this.total});

  static const _colors = [
    AppColors.accent,
    AppColors.secondary,
    AppColors.primary,
    AppColors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == entries.length - 1 ? 0 : 16,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        categoryIcon(entries[i].key),
                        size: 20,
                        color: AppColors.dark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${rupiah(entries[i].value)} · '
                        '${total == 0 ? 0 : (entries[i].value / total * 100).round()}%',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : entries[i].value / total,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation(
                      _colors[i % _colors.length],
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
