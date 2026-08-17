import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters/money_formatter.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/finance_category.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/finance_view_model.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/premium_card.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    FinanceCategory category,
    double current,
  ) async {
    var enteredValue = current > 0 ? current.toStringAsFixed(0) : '';

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            current > 0
                ? dialogContext.t('editBudget')
                : dialogContext.t('setBudget'),
          ),
          content: TextFormField(
            initialValue: enteredValue,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => enteredValue = value,
            decoration: InputDecoration(
              labelText: dialogContext.t('limit'),
              prefixIcon: Icon(category.icon, color: category.color),
              suffixText: 'SAR',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.t('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(enteredValue.trim());
                if (parsed == null || parsed <= 0) return;
                Navigator.of(dialogContext).pop(parsed);
              },
              child: Text(dialogContext.t('save')),
            ),
          ],
        );
      },
    );

    if (value != null && context.mounted) {
      await context.read<FinanceViewModel>().saveBudget(category.key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          AnimatedReveal(
            child: Text(
              context.t('budgetOverview'),
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
              context.t('budgetSubtitle'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    height: 1.5,
                  ),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedReveal(
            delay: const Duration(milliseconds: 90),
            child: _BudgetHero(finance: finance),
          ),
          const SizedBox(height: 12),
          Text(
            context.t('tapToEdit'),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 14),
          ...FinanceCategory.expenses.indexed.map((entry) {
            final index = entry.$1;
            final category = entry.$2;
            final limit = finance.budgetFor(category.key);
            final spent = finance.categorySpent(category.key);
            final ratio = limit <= 0
                ? 0.0
                : (spent / limit).clamp(0, 1.4).toDouble();
            final statusKey = ratio > 1
                ? 'overBudget'
                : (ratio >= .8 ? 'nearLimit' : 'onTrack');
            final statusColor = ratio > 1
                ? AppPalette.danger
                : (ratio >= .8 ? AppPalette.warning : AppPalette.emerald);
            return AnimatedReveal(
              delay: Duration(milliseconds: 35 * index),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PremiumCard(
                  onTap: () => _edit(context, category, limit),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  category.color.withValues(alpha: .18),
                                  category.color.withValues(alpha: .08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.t(category.key),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  limit > 0
                                      ? '${formatMoney(context, spent)} / ${formatMoney(context, limit)}'
                                      : context.t('setBudget'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.t(statusKey),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 19,
                            color: Theme.of(context).hintColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      AnimatedProgressBar(
                        value: ratio.clamp(0, 1).toDouble(),
                        color: statusColor,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BudgetHero extends StatelessWidget {
  const _BudgetHero({required this.finance});
  final FinanceViewModel finance;

  @override
  Widget build(BuildContext context) {
    final progress = finance.totalBudget <= 0
        ? 0.0
        : finance.budgetProgress.clamp(0, 1).toDouble();
    final progressColor = progress >= .9 ? AppPalette.warning : AppPalette.mint;

    return PremiumCard(
      padding: EdgeInsets.zero,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF12382F), Color(0xFF10243A)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -46,
            right: -38,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.cyan.withValues(alpha: .08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 520),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                backgroundColor:
                                    Colors.white.withValues(alpha: .08),
                                color: progressColor,
                              );
                            },
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
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
                            context.t('monthlyBudget'),
                            style: const TextStyle(
                              color: Color(0xFFB6C6C7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formatMoney(context, finance.totalBudget),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${finance.activeBudgetCount} ${context.t('categoriesSet')}',
                            style: const TextStyle(
                              color: Color(0xFF91ABA9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _Summary(
                        label: context.t('spent'),
                        value: formatMoney(context, finance.monthExpenses),
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: .12),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Summary(
                        label: context.t('remaining'),
                        value: formatMoney(context, finance.budgetRemaining),
                        color: AppPalette.mint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB6C6C7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
