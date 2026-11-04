import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const incomeCategories = ['Gaji', 'Pekerjaan', 'Lainnya'];

const expenseCategories = [
  'Makanan',
  'Transportasi',
  'Belanja',
  'Tagihan',
  'Hiburan',
  'Lainnya',
];

String rupiah(num value) => NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
).format(value);

IconData categoryIcon(String category) {
  switch (category) {
    case 'Gaji':
      return Icons.payments_rounded;
    case 'Pekerjaan':
      return Icons.work_rounded;
    case 'Makanan':
      return Icons.restaurant_rounded;
    case 'Transportasi':
      return Icons.directions_car_rounded;
    case 'Belanja':
      return Icons.shopping_bag_rounded;
    case 'Tagihan':
      return Icons.receipt_long_rounded;
    case 'Hiburan':
      return Icons.movie_rounded;
    default:
      return Icons.category_rounded;
  }
}
