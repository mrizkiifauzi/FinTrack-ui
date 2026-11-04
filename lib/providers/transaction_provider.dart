import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';

DateTime _daysAgo(int n) => DateTime.now().subtract(Duration(days: n));

class TransactionProvider extends ChangeNotifier {
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
