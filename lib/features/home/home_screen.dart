import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters/money_formatter.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/models/finance_category.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/finance_view_model.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/transaction_tile.dart';
import '../transactions/add_transaction_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _add(BuildContext context, bool income) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(initialIncome: income),
    );
  }

  Future<void> _showSnapshot(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _SnapshotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final settings = context.watch<AppSettingsViewModel>();
    final name = settings.profile?.name.split(' ').first ?? 'Friend';
    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'goodMorning'
        : (hour < 18 ? 'goodAfternoon' : 'goodEvening');
    final recent = finance.transactions.take(5).toList();
    final top = finance.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: finance.load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AnimatedReveal(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.t(greetingKey)},',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).hintColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: context.t('monthlySnapshot'),
                          onPressed: () => _showSnapshot(context),
                          icon: const Icon(Icons.insights_rounded),
                        ),
                        const SizedBox(width: 8),
                        Hero(
                          tag: 'profile-avatar',
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: AppPalette.emerald,
                            child: Text(
                              settings.profile?.initials ?? 'S',
                              style: const TextStyle(
                                color: AppPalette.navy,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 70),
                    child: _BalanceCard(finance: finance),
                  ),
                  const SizedBox(height: 16),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 130),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 320;
                        final expense = _QuickAction(
                          icon: Icons.arrow_upward_rounded,
                          label: context.t('addExpense'),
                          color: AppPalette.danger,
                          onTap: () => _add(context, false),
                        );
                        final income = _QuickAction(
                          icon: Icons.arrow_downward_rounded,
                          label: context.t('addIncome'),
                          color: AppPalette.emerald,
                          onTap: () => _add(context, true),
                        );

                        if (narrow) {
                          return Column(
                            children: [
                              expense,
                              const SizedBox(height: 10),
                              income,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: expense),
                            const SizedBox(width: 12),
                            Expanded(child: income),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 180),
                    child: _PulseStrip(finance: finance),
                  ),
                  const SizedBox(height: 18),
                  AnimatedReveal(
                    delay: const Duration(milliseconds: 230),
                    child: _SmartInsightCard(finance: finance),
                  ),
                  const SizedBox(height: 26),
                  SectionHeader(
                    title: context.t('monthlyBudget'),
                    actionLabel: context.t('budgets'),
                    onAction: () => context.go('/budgets'),
                  ),
                  const SizedBox(height: 10),
                  _BudgetCard(finance: finance),
                  const SizedBox(height: 26),
                  SectionHeader(
                    title: context.t('topSpending'),
                    actionLabel: context.t('analytics'),
                    onAction: () => context.go('/analytics'),
                  ),
                  const SizedBox(height: 10),
                  if (top.isEmpty)
                    PremiumCard(
                      child: Text(
                        context.t('noTransactions'),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    SizedBox(
                      height: 112,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: top.take(4).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final entry = top[index];
                          final category = FinanceCategory.byKey(entry.key);
                          return AnimatedReveal(
                            delay: Duration(milliseconds: 60 * index),
                            child: Container(
                              width: 142,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    category.color.withValues(alpha: .16),
                                    category.color.withValues(alpha: .06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: category.color.withValues(alpha: .20),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: category.color.withValues(alpha: .14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      category.icon,
                                      color: category.color,
                                      size: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    context.t(category.key),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formatMoney(context, entry.value),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 26),
                  SectionHeader(
                    title: context.t('recentTransactions'),
                    actionLabel: context.t('seeAll'),
                    onAction: () => context.go('/transactions'),
                  ),
                  const SizedBox(height: 6),
                  PremiumCard(
                    child: recent.isEmpty
                        ? EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: context.t('noTransactions'),
                      body: context.t('noTransactionsBody'),
                      actionLabel: context.t('addTransaction'),
                      onAction: () => _add(context, false),
                    )
                        : Column(
                      children: [
                        for (var i = 0; i < recent.length; i++) ...[
                          AnimatedReveal(
                            delay: Duration(milliseconds: 40 * i),
                            offset: const Offset(.04, 0),
                            child: TransactionTile(transaction: recent[i]),
                          ),
                          if (i != recent.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.finance});
  final FinanceViewModel finance;

  @override
  Widget build(BuildContext context) {
    final score = finance.financialHealthScore;
    return PremiumCard(
      padding: EdgeInsets.zero,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF12382F), Color(0xFF0D2630), Color(0xFF11223A)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -44,
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
          Positioned(
            bottom: -62,
            left: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.emerald.withValues(alpha: .06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.t('availableBalance'),
                        style: const TextStyle(
                          color: Color(0xFFB7CAC8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 13,
                            color: AppPalette.mint,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: finance.balance),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        formatMoney(context, value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _Metric(
                        label: context.t('income'),
                        value: formatMoney(context, finance.monthIncome),
                        icon: Icons.south_west_rounded,
                        color: AppPalette.emerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metric(
                        label: context.t('expenses'),
                        value: formatMoney(context, finance.monthExpenses),
                        icon: Icons.north_east_rounded,
                        color: AppPalette.danger,
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9FB2BC),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: .18),
                  color.withValues(alpha: .08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseStrip extends StatelessWidget {
  const _PulseStrip({required this.finance});
  final FinanceViewModel finance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final weekly = _PulseMetric(
          icon: Icons.calendar_view_week_rounded,
          label: context.t('weeklySpend'),
          value: formatMoney(context, finance.weeklyExpenses),
          color: AppPalette.cyan,
        );
        final noSpend = _PulseMetric(
          icon: Icons.self_improvement_rounded,
          label: context.t('noSpendDays'),
          value: '${finance.noSpendDaysThisWeek} ${context.t('days')}',
          color: AppPalette.emerald,
        );

        if (constraints.maxWidth < 320) {
          return Column(
            children: [
              weekly,
              const SizedBox(height: 10),
              noSpend,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: weekly),
            const SizedBox(width: 10),
            Expanded(child: noSpend),
          ],
        );
      },
    );
  }
}

class _PulseMetric extends StatelessWidget {
  const _PulseMetric({
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            label,
            maxLines: 1,
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
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SmartInsightCard extends StatelessWidget {
  const _SmartInsightCard({required this.finance});
  final FinanceViewModel finance;

  String _message(BuildContext context) {
    if (finance.transactions.isEmpty) return context.t('insightNoData');
    if (finance.totalBudget > 0 && finance.budgetProgress >= .82) {
      return context.t('insightBudgetNear');
    }
    if (finance.savingsRate >= 25) return context.t('insightSaveStrong');
    final top = finance.largestExpenseCategory;
    if (top != null) {
      return context
          .t('insightTopCategory')
          .replaceFirst('{category}', context.t(top));
    }
    return context.t('insightNoData');
  }

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppPalette.emerald.withValues(alpha: .13),
          AppPalette.cyan.withValues(alpha: .06),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppPalette.emerald.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppPalette.emerald,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('smartInsight'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  _message(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    height: 1.5,
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

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.finance});
  final FinanceViewModel finance;

  @override
  Widget build(BuildContext context) {
    final hasBudget = finance.totalBudget > 0;
    final progress =
    hasBudget ? finance.budgetProgress.clamp(0, 1).toDouble() : 0.0;
    final color = progress > .9 ? AppPalette.warning : AppPalette.emerald;

    return PremiumCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          final spentBlock = _BudgetMetricBlock(
            label: context.t('spent'),
            value: hasBudget
                ? formatMoney(context, finance.monthExpenses)
                : context.t('setBudget'),
            valueColor: Theme.of(context).textTheme.bodyLarge?.color,
          );

          final remainingBlock = _BudgetMetricBlock(
            label: context.t('remaining'),
            value: hasBudget
                ? formatMoney(context, finance.budgetRemaining)
                : '—',
            valueColor: AppPalette.emerald,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                spentBlock,
                const SizedBox(height: 12),
                remainingBlock,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: spentBlock),
                    const SizedBox(width: 12),
                    Expanded(child: remainingBlock),
                  ],
                ),
              const SizedBox(height: 16),
              AnimatedProgressBar(
                value: progress,
                color: color,
                height: 9,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).round()}% ${context.t('monthUsed')}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    '${finance.activeBudgetCount} ${context.t('categoriesSet')}',
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BudgetMetricBlock extends StatelessWidget {
  const _BudgetMetricBlock({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotSheet extends StatelessWidget {
  const _SnapshotSheet();

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final change = finance.monthOverMonthChange;
    final improving = change <= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('monthlySnapshot'),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('analyticsSubtitle'),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SnapshotMetric(
                  label: context.t('projectedSpend'),
                  value: formatMoney(context, finance.projectedMonthExpenses),
                  icon: Icons.trending_up_rounded,
                  color: AppPalette.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SnapshotMetric(
                  label: context.t('recurringExpenses'),
                  value: formatMoney(context, finance.recurringExpenses),
                  icon: Icons.autorenew_rounded,
                  color: AppPalette.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PremiumCard(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (improving ? AppPalette.emerald : AppPalette.danger)
                        .withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    improving
                        ? Icons.south_east_rounded
                        : Icons.north_east_rounded,
                    color: improving ? AppPalette.emerald : AppPalette.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('monthVsLast'),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color:
                          improving ? AppPalette.emerald : AppPalette.danger,
                        ),
                      ),
                    ],
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

class _SnapshotMetric extends StatelessWidget {
  const _SnapshotMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
