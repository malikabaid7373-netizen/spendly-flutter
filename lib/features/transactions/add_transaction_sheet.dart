import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/models/finance_category.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/finance_transaction.dart';
import '../../view_models/finance_view_model.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key, this.transaction, this.initialIncome = false});
  final FinanceTransaction? transaction;
  final bool initialIncome;

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late TransactionType _type;
  late String _categoryKey;
  late DateTime _date;
  late bool _recurring;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = widget.transaction;
    _title = TextEditingController(text: current?.title ?? '');
    _amount = TextEditingController(text: current == null ? '' : current.amount.toStringAsFixed(0));
    _note = TextEditingController(text: current?.note ?? '');
    _type = current?.type ?? (widget.initialIncome ? TransactionType.income : TransactionType.expense);
    _categoryKey = current?.categoryKey ?? (_type == TransactionType.income ? 'salary' : 'food');
    _date = current?.date ?? DateTime.now();
    _recurring = current?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final transaction = FinanceTransaction(
      id: widget.transaction?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      amount: double.parse(_amount.text.trim()),
      type: _type,
      categoryKey: _categoryKey,
      date: _date,
      note: _note.text.trim(),
      isRecurring: _recurring,
    );
    await context.read<FinanceViewModel>().saveTransaction(transaction);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.income ? FinanceCategory.incomes : FinanceCategory.expenses;
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(20)))),
              const SizedBox(height: 22),
              Text(widget.transaction == null ? context.t('addTransaction') : context.t('editTransaction'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(value: TransactionType.expense, label: Text(context.t('expenses')), icon: const Icon(Icons.north_east_rounded)),
                  ButtonSegment(value: TransactionType.income, label: Text(context.t('income')), icon: const Icon(Icons.south_west_rounded)),
                ],
                selected: {_type},
                onSelectionChanged: (value) => setState(() { _type = value.first; _categoryKey = _type == TransactionType.income ? 'salary' : 'food'; }),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: context.t('amount'), prefixIcon: const Icon(Icons.payments_outlined), suffixText: 'SAR'),
                validator: (value) { final parsed = double.tryParse(value?.trim() ?? ''); return parsed == null || parsed <= 0 ? context.t('amountInvalid') : null; },
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _title, textInputAction: TextInputAction.next, decoration: InputDecoration(labelText: context.t('title'), prefixIcon: const Icon(Icons.edit_note_rounded)), validator: (value) => value == null || value.trim().isEmpty ? context.t('requiredField') : null),
              const SizedBox(height: 16),
              Text(context.t('category'), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final selected = _categoryKey == category.key;
                  return ChoiceChip(selected: selected, onSelected: (_) => setState(() => _categoryKey = category.key), avatar: Icon(category.icon, color: category.color, size: 17), label: Text(context.t(category.key)));
                }).toList(),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(context: context, firstDate: DateTime(DateTime.now().year - 3), lastDate: DateTime(DateTime.now().year + 1), initialDate: _date);
                  if (!mounted) return;
                  if (picked != null) setState(() => _date = picked);
                },
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(decoration: InputDecoration(labelText: context.t('date'), prefixIcon: const Icon(Icons.calendar_month_rounded)), child: Text('${_date.day}/${_date.month}/${_date.year}')),
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _note, maxLines: 2, decoration: InputDecoration(labelText: '${context.t('note')} (${context.t('optional')})', prefixIcon: const Icon(Icons.notes_rounded))),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(value: _recurring, onChanged: (value) => setState(() => _recurring = value), contentPadding: EdgeInsets.zero, title: Text(context.t('recurring'), style: const TextStyle(fontWeight: FontWeight.w700)), activeTrackColor: AppPalette.emerald.withValues(alpha: .55)),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator(strokeWidth: 2) : Text(context.t('save'), style: const TextStyle(fontWeight: FontWeight.w900)))),
            ]),
          ),
        ),
      ),
    );
  }
}
