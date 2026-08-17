import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters/money_formatter.dart';
import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/finance_transaction.dart';
import '../../view_models/finance_view_model.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/premium_card.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _search = TextEditingController();
  TransactionType? _filter;
  bool _recurringOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _edit(FinanceTransaction transaction) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final query = _search.text.trim().toLowerCase();
    final filtered = finance.transactions.where((item) {
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          context.t(item.categoryKey).toLowerCase().contains(query);
      final matchesType = _filter == null || item.type == _filter;
      final matchesRecurring = !_recurringOnly || item.isRecurring;
      return matchesQuery && matchesType && matchesRecurring;
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedReveal(
                  child: Text(
                    context.t('transactions'),
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
                    context.t('thisMonth'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedReveal(
                  delay: const Duration(milliseconds: 80),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryMetric(
                          icon: Icons.south_west_rounded,
                          label: context.t('income'),
                          value: formatMoney(context, finance.monthIncome),
                          color: AppPalette.emerald,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryMetric(
                          icon: Icons.north_east_rounded,
                          label: context.t('expenses'),
                          value: formatMoney(context, finance.monthExpenses),
                          color: AppPalette.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: context.t('searchTransactions'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(
                          context.t('all'),
                          style: TextStyle(
                            color: _filter == null && !_recurringOnly
                                ? AppPalette.emerald
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        selected: _filter == null && !_recurringOnly,
                        onSelected: (_) => setState(() {
                          _filter = null;
                          _recurringOnly = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(
                          context.t('expenses'),
                          style: TextStyle(
                            color: _filter == TransactionType.expense && !_recurringOnly
                                ? AppPalette.emerald
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        selected: _filter == TransactionType.expense &&
                            !_recurringOnly,
                        onSelected: (_) => setState(() {
                          _filter = TransactionType.expense;
                          _recurringOnly = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(
                          context.t('income'),
                          style: TextStyle(
                            color: _filter == TransactionType.income && !_recurringOnly
                                ? AppPalette.emerald
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        selected:
                            _filter == TransactionType.income && !_recurringOnly,
                        onSelected: (_) => setState(() {
                          _filter = TransactionType.income;
                          _recurringOnly = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Icon(Icons.autorenew_rounded, size: 17),
                        label: Text(
                          context.t('recurringOnly'),
                          style: TextStyle(
                            color: _recurringOnly
                                ? AppPalette.emerald
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        selected: _recurringOnly,
                        onSelected: (value) => setState(() {
                          _recurringOnly = value;
                          if (value) _filter = null;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: PremiumCard(
                    key: ValueKey(
                      '${_filter?.name}-${_recurringOnly}-${query}-${filtered.length}',
                    ),
                    child: filtered.isEmpty
                        ? EmptyState(
                            icon: Icons.receipt_long_rounded,
                            title: context.t('noTransactions'),
                            body: context.t('noTransactionsBody'),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < filtered.length; i++) ...[
                                Dismissible(
                                    key: ValueKey(filtered[i].id),
                                    background: Container(
                                      alignment: AlignmentDirectional.centerStart,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withValues(alpha: .12),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    confirmDismiss: (_) async {
                                      return await showDialog<bool>(
                                            context: context,
                                            builder: (dialogContext) =>
                                                AlertDialog(
                                              title: Text(
                                                context.t('delete'),
                                              ),
                                              content: Text(filtered[i].title),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(
                                                    dialogContext,
                                                    false,
                                                  ),
                                                  child:
                                                      Text(context.t('cancel')),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.pop(
                                                    dialogContext,
                                                    true,
                                                  ),
                                                  child:
                                                      Text(context.t('delete')),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;
                                    },
                                    onDismissed: (_) => finance
                                        .deleteTransaction(filtered[i].id),
                                    child: TransactionTile(
                                      transaction: filtered[i],
                                      onTap: () => _edit(filtered[i]),
                                    ),
                                  ),
                                if (i != filtered.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
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
