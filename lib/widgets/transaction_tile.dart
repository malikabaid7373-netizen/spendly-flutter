import 'package:flutter/material.dart';

import '../core/formatters/money_formatter.dart';
import '../core/i18n/app_strings.dart';
import '../core/models/finance_category.dart';
import '../core/theme/app_theme.dart';
import '../data/models/finance_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final FinanceTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final category = FinanceCategory.byKey(transaction.categoryKey);
    final isIncome = transaction.type == TransactionType.income;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(category.icon, color: category.color, size: 22),
      ),
      title: Text(
        transaction.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${context.t(category.key)}  •  ${formatDate(context, transaction.date)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 105),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            '${isIncome ? '+' : '-'}${formatMoney(context, transaction.amount)}',
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isIncome
                  ? AppPalette.income
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }
}
