import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/state/app_state.dart';
import 'package:expense_tracker/utils/currency_formatter.dart';
import 'package:expense_tracker/widgets/common/custom_card.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategorySpending> distribution;
  final String currencySymbol;

  const CategoryPieChart({
    super.key,
    required this.distribution,
    required this.currencySymbol,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.distribution.isEmpty) {
      return CustomCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expense data available for this period',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    final totalAmount = widget.distribution.fold(0.0, (sum, item) => sum + item.totalAmount);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),

          // Donut Chart Container
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 55,
                    sections: _buildSections(),
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _touchedIndex != -1 && _touchedIndex < widget.distribution.length
                          ? widget.distribution[_touchedIndex].category.name
                          : 'Total Spent',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _touchedIndex != -1 && _touchedIndex < widget.distribution.length
                          ? CurrencyFormatter.format(
                              widget.distribution[_touchedIndex].totalAmount,
                              symbol: widget.currencySymbol,
                            )
                          : CurrencyFormatter.format(totalAmount, symbol: widget.currencySymbol),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category Legend Breakdown List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.distribution.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.distribution[index];
              final isSelected = _touchedIndex == index;

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    _touchedIndex = _touchedIndex == index ? -1 : index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.category.color.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: item.category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(item.category.icon, size: 16, color: item.category.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.category.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(item.totalAmount, symbol: widget.currencySymbol),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatPercent(item.percentage),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return List.generate(widget.distribution.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 14.0 : 11.0;
      final radius = isTouched ? 42.0 : 34.0;
      final item = widget.distribution[i];

      return PieChartSectionData(
        color: item.category.color,
        value: item.totalAmount,
        title: item.percentage > 0.05 ? '${(item.percentage * 100).toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }
}
