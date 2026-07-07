class Formatters {
  Formatters._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String longDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_months[date.month - 1]} ${date.year}';
  }

  static String shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static String rupees(double value) {
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    return '₹ $text';
  }
}
