class CounterFormatter {
  static String format(int count) {
    return 'Count: $count';
  }

  static String formatCount(int count) {
    return 'Current Count: $count';
  }

  static String formatAsOrdinal(int count) {
    switch (count) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${count}th';
    }
  }
}
