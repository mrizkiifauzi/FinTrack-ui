import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_tile.dart';

const _allCategories = 'Semua kategori';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TransactionProvider>();
    final text = Theme.of(context).textTheme;
    final rows = _groupByDate(data.filteredItems);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'Transaksi',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: data.filterCategory == null
                  ? Colors.white
                  : AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list_rounded),
              tooltip: 'Filter kategori',
              onSelected: (value) => data.setFilterCategory(
                value == _allCategories ? null : value,
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _allCategories,
                  child: Text(_allCategories),
                ),
                for (final c in data.categories)
                  PopupMenuItem(value: c, child: Text(c)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _TypeFilter(
              selected: data.filterType,
              onChanged: data.setFilterType,
            ),
          ),
          if (data.filterCategory != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(data.filterCategory!),
                  backgroundColor: AppColors.primary,
                  side: BorderSide.none,
                  onDeleted: () => data.setFilterCategory(null),
                ),
              ),
            ),
          Expanded(
            child: rows.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final row = rows[i];
                      if (row is String) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            row,
                            style: text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DismissibleTile(
                          transaction: row as TransactionModel,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Menyisipkan judul tanggal di antara transaksi yang beda hari.
List<Object> _groupByDate(List<TransactionModel> items) {
  final rows = <Object>[];
  String? lastLabel;
  for (final t in items) {
    final label = _dateLabel(t.date);
    if (label != lastLabel) {
      rows.add(label);
      lastLabel = label;
    }
    rows.add(t);
  }
  return rows;
}

String _dateLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return DateFormat('EEEE, d MMMM y', 'id_ID').format(d);
}

class _TypeFilter extends StatelessWidget {
  final TransactionType? selected;
  final ValueChanged<TransactionType?> onChanged;

  const _TypeFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <(String, TransactionType?)>[
      ('Semua', null),
      ('Pemasukan', TransactionType.income),
      ('Pengeluaran', TransactionType.expense),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final (label, type) in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == type
                        ? AppColors.dark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected == type ? Colors.white : AppColors.dark,
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

class _DismissibleTile extends StatelessWidget {
  final TransactionModel transaction;
  const _DismissibleTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final t = transaction;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Dismissible(
        key: ValueKey(t.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: AppColors.danger,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        onDismissed: (_) {
          provider.removeTransaction(t.id);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('"${t.title}" dihapus'),
                action: SnackBarAction(
                  label: 'Batalkan',
                  onPressed: () => provider.addTransaction(t),
                ),
              ),
            );
        },
        child: TransactionTile(transaction: t),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada transaksi',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Ubah filter atau tambahkan transaksi baru dengan tombol +',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
