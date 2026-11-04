import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

DateTime _daysAgo(int n) => DateTime.now().subtract(Duration(days: n));

enum ReportPeriod { week, month, year }

class ReportBucket {
  final String label;
  final double income;
  final double expense;
  const ReportBucket(this.label, this.income, this.expense);
}

class TransactionProvider extends ChangeNotifier {
  // ---- Filter ----
  TransactionType? _filterType; // null = semua jenis
  String? _filterCategory; // null = semua kategori

  TransactionType? get filterType => _filterType;
  String? get filterCategory => _filterCategory;

  List<String> get categories =>
      (_items.map((t) => t.category).toSet().toList()..sort());

  List<TransactionModel> get filteredItems => items
      .where(
        (t) =>
            (_filterType == null || t.type == _filterType) &&
            (_filterCategory == null || t.category == _filterCategory),
      )
      .toList();

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    notifyListeners();
  }

  // ---- Tambah dan hapus ----
  void addTransaction(TransactionModel t) {
    _items.add(t);
    notifyListeners();
  }

  void removeTransaction(String id) {
    _items.removeWhere((t) => t.id == id);
    // Jika kategori yang sedang difilter sudah kosong, filter dilepas
    if (_filterCategory != null &&
        !_items.any((t) => t.category == _filterCategory)) {
      _filterCategory = null;
    }
    notifyListeners();
  }

  // ---- Laporan ----
  ReportPeriod _period = ReportPeriod.week;
  ReportPeriod get period => _period;

  void setPeriod(ReportPeriod p) {
    _period = p;
    notifyListeners();
  }

  DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Tanggal awal periode yang sedang dipilih.
  DateTime get _periodStart {
    final now = DateTime.now();
    final today = _dayOf(now);
    return switch (_period) {
      ReportPeriod.week => today.subtract(const Duration(days: 6)),
      ReportPeriod.month => today.subtract(const Duration(days: 27)),
      ReportPeriod.year => DateTime(now.year, now.month - 11, 1),
    };
  }

  List<TransactionModel> get _periodItems {
    final start = _periodStart;
    return _items.where((t) => !_dayOf(t.date).isBefore(start)).toList();
  }

  double get periodIncome => _periodItems
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get periodExpense => _periodItems
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Data untuk grafik: 7 hari, 4 minggu, atau 12 bulan.
  List<ReportBucket> get periodBuckets {
    final start = _periodStart;
    final count = switch (_period) {
      ReportPeriod.week => 7,
      ReportPeriod.month => 4,
      ReportPeriod.year => 12,
    };
    final income = List<double>.filled(count, 0);
    final expense = List<double>.filled(count, 0);

    for (final t in _periodItems) {
      final day = _dayOf(t.date);
      final idx = switch (_period) {
        ReportPeriod.week => day.difference(start).inDays,
        ReportPeriod.month => day.difference(start).inDays ~/ 7,
        ReportPeriod.year =>
          (day.year - start.year) * 12 + day.month - start.month,
      };
      if (idx < 0 || idx >= count) continue;
      if (t.isIncome) {
        income[idx] += t.amount;
      } else {
        expense[idx] += t.amount;
      }
    }

    return List.generate(count, (i) {
      final label = switch (_period) {
        ReportPeriod.week => DateFormat(
          'E',
          'id_ID',
        ).format(start.add(Duration(days: i))),
        ReportPeriod.month => 'Mgg ${i + 1}',
        ReportPeriod.year => DateFormat(
          'MMM',
          'id_ID',
        ).format(DateTime(start.year, start.month + i, 1)),
      };
      return ReportBucket(label, income[i], expense[i]);
    });
  }

  /// Pengeluaran per kategori, dari yang terbesar.
  List<MapEntry<String, double>> get periodExpenseByCategory {
    final totals = <String, double>{};
    for (final t in _periodItems.where((t) => !t.isIncome)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  final List<TransactionModel> _items = [
    TransactionModel(
      id: '1',
      title: 'Gaji Bulanan',
      amount: 5000000,
      category: 'Gaji',
      date: _daysAgo(10),
      type: TransactionType.income,
    ),
    TransactionModel(
      id: '2',
      title: 'Proyek Desain',
      amount: 1200000,
      category: 'Pekerjaan',
      date: _daysAgo(4),
      type: TransactionType.income,
    ),
    TransactionModel(
      id: '3',
      title: 'Makan Siang',
      amount: 35000,
      category: 'Makanan',
      date: _daysAgo(0),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '4',
      title: 'Kopi Pagi',
      amount: 28000,
      category: 'Makanan',
      date: _daysAgo(0),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '5',
      title: 'Ojek Online',
      amount: 22000,
      category: 'Transportasi',
      date: _daysAgo(1),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '6',
      title: 'Belanja Bulanan',
      amount: 450000,
      category: 'Belanja',
      date: _daysAgo(2),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '7',
      title: 'Internet Rumah',
      amount: 300000,
      category: 'Tagihan',
      date: _daysAgo(3),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '8',
      title: 'Bensin',
      amount: 50000,
      category: 'Transportasi',
      date: _daysAgo(4),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '9',
      title: 'Nonton Bioskop',
      amount: 75000,
      category: 'Hiburan',
      date: _daysAgo(5),
      type: TransactionType.expense,
    ),
    TransactionModel(
      id: '10',
      title: 'Makan Malam',
      amount: 60000,
      category: 'Makanan',
      date: _daysAgo(6),
      type: TransactionType.expense,
    ),
  ];

  List<TransactionModel> get items {
    final sorted = [..._items];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<TransactionModel> get recent => items.take(3).toList();

  double get totalIncome =>
      _items.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense =>
      _items.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  /// Total pengeluaran per hari, urutan dari hari terlama ke hari ini.
  List<double> expenseLastDays(int days) {
    final today = DateTime.now();
    return List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      return _items
          .where(
            (t) =>
                !t.isIncome &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
    });
  }
}
